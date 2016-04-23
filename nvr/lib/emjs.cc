#include "nvr.hh"

namespace nvr {

    bool  // Used by biggest_rectangle.
    cmp_areas (const dlib::rectangle& lr, const dlib::rectangle& rr) {
        return lr.area() < rr.area();
    }

    dlib::rectangle
    biggest_rectangle (const std::vector<dlib::rectangle>& rs) {
        return *std::max_element(std::begin(rs), std::end(rs), cmp_areas);
    }

    dlib::rectangle  // Get a square box centered on the nose
    head_hull (const Landmarks& face) {
        dlib::rectangle rect;
        for (size_t j = 0; j < face.num_parts(); ++j)
            rect += face.part(j);  // Enlarges rect's area
        const auto& nose = face.part(30);
        // FIXME use front-menton distance as rect's height/width
        return dlib::centered_rect(nose, rect.width(), rect.height());
    }

    ///////////////////////////////////////////////////////////////////////////

    dlib::rectangle
    UniVR::scaled (const dlib::rectangle& r) {
        auto x = r.left();
        auto y = r.top();
        auto sx = x * rc_;
        auto sy = y * rr_;
        int sw = (x + r.width()) * rc_;
        int sh = (y + r.height()) * rr_;
        // Keep away from the edges
        if (sw > frame_cols_)
            sw = frame_cols_ - 5;
        if (sh > frame_rows_)
            sh = frame_rows_ - 5;
        auto r2 = dlib::rectangle(sx, sy, sw, sh);
        //std::cout << r << " -> " << r2 << std::endl;
        return r2;
    }

    dlib::point
    UniVR::scaled (const dlib::point& p) {
        return dlib::point(p.x() * rc_,  p.y() * rr_);
    }

    ///////////////////////////////////////////////////////////////////////////

    int
    UniVR::norm (const Landmarks& face, int part1, int part2) {
        const auto& p1 = scaled(face.part(part1));
        const auto& p2 = scaled(face.part(part2));
        int x = p1.x() - p2.x();
        int y = p1.y() - p2.y();
        return std::pow(x, 2) + std::pow(y, 2);
    }

    double
    UniVR::angle (const Landmarks& face,
                  int part1, int part2, int Part1, int Part2) {
        const auto& p1 = scaled(face.part(part1));
        const auto& p2 = scaled(face.part(part2));
        const auto& P1 = scaled(face.part(Part1));
        const auto& P2 = scaled(face.part(Part2));
        double m1 = (p2.y()-p1.y() + SMOOTHING) / (p2.x()-p1.x() + SMOOTHING);
        double m2 = (P2.y()-P1.y() + SMOOTHING) / (P2.x()-P1.x() + SMOOTHING);
        return std::atan2(1 + m2 * m1, m2 - m1);
    }

    double
    select_stable (double Old, double New) {
        double threshold = 0.009;//
        return (std::abs(Old - New) < threshold) ? Old : New;
    }

#define SZEYE 5
    typedef struct { double x,y,z; } Eye;
    Eye
    average (const Eye eyes[SZEYE]) {
        Eye e = {};
        for (int i = 0; i < SZEYE; ++i) {
            e.x += eyes[i].x;
            e.y += eyes[i].y;
            e.z += eyes[i].z;
        }
        return Eye{e.x / SZEYE, e.y / SZEYE, e.z / SZEYE};
    }

    void
    UniVR::collect_data (data& data, const Landmarks& face,
                         const dlib::rectangle& face_zone) {
        data.w = frame_cols_;
        data.h = frame_rows_;
        data.n  = norm(face, LANDMARK_NT, LANDMARK_NB);
        data.er = norm(face, LANDMARK_RER, LANDMARK_REL);
        data.el = norm(face, LANDMARK_LER, LANDMARK_LEL);
        data.ar = std::abs(angle(face, LANDMARK_NT, LANDMARK_NB
                                 ,     LANDMARK_RER, LANDMARK_REL));
        data.al = std::abs(angle(face, LANDMARK_LER, LANDMARK_LEL
                                 ,     LANDMARK_NT, LANDMARK_NB));
        data.das = std::abs(data.ar - data.al);
        data.chin = norm(face, LANDMARK_CR, LANDMARK_CL);
        data.ears = norm(face, LANDMARK_JR, LANDMARK_JL);
        auto g = scaled(center(face.get_rect()));
        data.gx = g.x();
        data.gy = g.y();
        // --
        data.headWidth  = face_zone.width();
        data.headHeight = face_zone.height();
        data.upperHeadX = face_zone.left();
        data.upperHeadY = face_zone.top();

        // --
        double angle = data.headWidth * HGPP * PI180;
        data.headDist = (MEAN_HEAD_WIDTH/2) / tan(angle/2); // in meters
        for (int i = HEAD_HIST_SZ -1; i > 0; i--)
            data.headHist[i] = data.headHist[i - 1];
        data.headHist[0] = data.headDist;
        double sumHeadDist = 0.0;
        for (size_t i = 0; i < HEAD_HIST_SZ; ++i)
            sumHeadDist += data.headHist[i];
        data.headDist = sumHeadDist / HEAD_HIST_SZ;
        double xAngle = HGPP * PI180 *
            (WINWIDTH /2 - (data.upperHeadX + data.headWidth /2));
        double yAngle = VGPP * PI180 *
            (WINHEIGHT/2 - (data.upperHeadY + data.headHeight/2));
        data.headX = tan(xAngle) * data.headDist;
        data.headY = tan(yAngle) * data.headDist;

        // -- (This and below uses things modified just above)
        double normX = 3 * data.headX;//(float) (( headX - 320)/320.0);
        double normY = 3 * data.headY;//(float) (( headY - 240)/320.0);
        Eye e0 = Eye{5 * normX, 7 * normY, 1 + 5 * data.headDist};

        // ---
        // data.eyeX = select_stable(data.eyeX, e0.x);
        // data.eyeY = select_stable(data.eyeY, e0.y);
        // data.eyeZ = select_stable(data.eyeZ, e0.z);

        // ---
        static Eye eyes[SZEYE];
        static int count = 1;
        for (int i = SZEYE -1; i > 0; i--)
            eyes[i] = eyes[i -1];
        eyes[0] = e0;
        Eye e = average(eyes);
        if (count > SZEYE) {
            data.eyeX = e.x;
            data.eyeY = e.y;
            data.eyeZ = e.z;
            printf("  %lf\t  %lf\t  %lf\n",
                   std::abs(e.x - eyes[0].x),
                   std::abs(e.y - eyes[0].y),
                   std::abs(e.z - eyes[0].z));
        } else {
            data.eyeX = eyes[0].x;
            data.eyeY = eyes[0].y;
            data.eyeZ = eyes[0].z;
            ++count;
        }
    }

    ///////////////////////////////////////////////////////////////////////////

    std::ostream&
    operator<< (std::ostream& o, const data& rhs) {
        static size_t i = 0;
        return o << "data " << i++
                 << " w:" << rhs.w << " h:" << rhs.h
                 << " n:" << rhs.n
                 << " er:" << rhs.er << " el:" << rhs.el
                 << " ar:" << rhs.ar << " al:" << rhs.al << " das:" << rhs.das
                 << " chin:" << rhs.chin
                 << " ears:" << rhs.ears
                 << " gx:" << rhs.gx << " gy:" << rhs.gy << std::endl;
    }

    ///////////////////////////////////////////////////////////////////////////

    UniVR::UniVR () {
        I_ = 0;
        Ds_ = 0;
        rc_ = 0;
        rr_ = 0;
        inited_ = false;
        detected_ = false;
    }

    UniVR::~UniVR () {
    }

    void
    UniVR::init (const std::string& trained_data,
                 std::function<bool(nvr::FrameStream&)> capture_opener) {
        detector_ = dlib::get_frontal_face_detector();
        dlib::deserialize(trained_data) >> extractor_;

        if (!capture_opener(capture_))
            throw std::string("!cap from webcam 0");

        inited_ = true;
    }

    ///////////////////////////////////////////////////////////////////////////

    int
    count_nonzero (Frame data, int size) {
        int sum = 0;
        for (int i=0; i < size; ++i)
            if (data[i] != 0)
                ++sum;
        return sum;
    }

    bool
    UniVR::next_frame () {
        frame_rows_ = 720;
        frame_cols_ = 1280;
        int sz = frame_cols_ * frame_rows_ * 3;
        std::cout << count_nonzero(frame_, sz) << std::endl;
        bool usePixels = true;
        html5video_grabber_update(capture_, usePixels, frame_);
        int updated = count_nonzero(frame_, sz);
        if (0 == updated)
            return false;

        img_.set_size(frame_rows_, frame_cols_);
        for (long row = 0; row < frame_rows_ * 3; ++row) {
            for (unsigned long col = 0; col < frame_cols_; col += 3) {
                auto ix = row * frame_cols_ + col;
                dlib::rgb_pixel p;
                p.red   = frame_[ix + 0];
                p.green = frame_[ix + 1];
                p.blue  = frame_[ix + 2];
                dlib::assign_pixel(img_[row][col], p);
            }
        }

#define MAGIC__MINIMUM_CAMERA_HEIGHT  (300)
        if (frame_rows_ / 2 > MAGIC__MINIMUM_CAMERA_HEIGHT) {
            dlib::pyramid_down<2> pyr;
            pyr(img_);
            //FIXME: compute ideal ratio given frame_.rows?
        }

        if (rc_ == 0 || rr_ == 0) {
            rc_ = frame_cols_ / img_.nc();
            rr_ = frame_rows_ / img_.nr();
        }

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////

    void
    UniVR::detect_now () {
        detected_ = true;
    }

    void
    UniVR::detect_then_track () {
        if (detected_)
            std::cout << "detected_" << std::endl;
        else
            std::cout << "!detected_" << std::endl;

        if (detected_) {
            /// Tracking
            tracker_.update(img_); // Returns confidence as a double
            rect_found_ = tracker_.get_position();
            if (rect_found_.is_empty())
                detected_ = false;
        }

        if (!detected_) {
            /// Detection
            ++I_;
            if (I_ % DROP_AMOUNT == 0)
                std::cout << "could detect only now" << std::endl;
            std::cout << "Detection" << std::endl;
            auto dets = detector_(img_);
            std::cout << "#faces: " << dets.size() << std::endl;

            if (dets.empty())
                return;
            rect_found_ = biggest_rectangle(dets);
            tracker_.start_track(img_, rect_found_);
            ++Ds_;
            detected_ = true;
        }
    }

    bool
    UniVR::step (data& data) {
        if (!inited_)
            std::cerr << "nvr: init/1 was not called!" << std::endl;

        if (!next_frame()) // Sets frame_
            return false;

        rect_found_ = dlib::rectangle();
        detect_then_track(); // Sets rect_found_
        if (rect_found_.is_empty())
            std::cout << "!rect_found_" << std::endl;
        else
            std::cout << "!rect_found_" << std::endl;
        if (rect_found_.is_empty())
            if (!zones_.empty())
                rect_found_ = zones_.back();
            else
                return false;

        if (!rect_found_.is_empty()) {
            /// Extraction
            const auto& face_found = extractor_(img_, rect_found_);

            const auto& reconstructed_zone = head_hull(face_found);
            collect_data(data, face_found, scaled(reconstructed_zone));
            zones_.push_back(reconstructed_zone);
        }
        while (zones_.size() > BACKLOG_SZ)
            zones_.pop_front();

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////

}
