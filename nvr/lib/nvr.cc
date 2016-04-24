#include "nvr.hh"

#ifdef window_debug
# define WINDOW   "nvr"
# define WINDOW_3 "face"

# define WHITE  (cv::Scalar::all(255))
# define BLACK  (cv::Scalar::all(0))
# define BLUE   (cv::Scalar(255, 0, 0))
# define GREEN  (cv::Scalar(0, 255, 0))
#endif

namespace nvr {

#ifdef window_debug

    void
    rectangle (Frame& img, const dlib::rectangle& rect, size_t thickness) {
        if ((  0 >= rect.left() - thickness)
            || 0 >= rect.top() - thickness
            || 0 >= rect.right() - thickness
            || 0 >= rect.bottom() - thickness)
            // FIXME: a segfault hides deeper than here…
            return;
        auto zone =
            cv::Rect(rect.left(), rect.top(), rect.width(), rect.height());
        cv::rectangle(img, zone, WHITE, thickness, 8, 0);
    }

    void
    dot (Frame& img, const dlib::point& p, size_t thickness) {
        cv::Point pcv(p.x(), p.y());
        auto color = BLUE;
        auto fface = cv::FONT_HERSHEY_SIMPLEX;
        cv::putText(img, "+", pcv, fface, .37, color, thickness, 8);
    }

    void
    dots (Frame& img, const Landmarks& face, size_t thickness) {
        for (size_t k = 0; k < face.num_parts(); ++k) {
            const auto& p = face.part(k);
            if (p == dlib::OBJECT_PART_NOT_PRESENT)
                continue;
            dot(img, p, thickness);
        }
    }

    void // Used by text & textr
    text_ (Frame& img, const cv::Point& o, const std::string& str) {
        int fface = cv::FONT_HERSHEY_SIMPLEX;
        double fscale = 0.73;
        int thick = 1;
        auto color = WHITE;
        int baseline = 0;
        auto text = cv::getTextSize(str, fface, fscale, thick, &baseline);
        cv::rectangle(img, o + cv::Point(0, baseline)
                      ,    o + cv::Point(text.width, -text.height),
                      BLACK, CV_FILLED);
        cv::putText(img, str, o, fface, fscale, color, thick, 8);
    }

    void
    text (Frame& img, size_t pos, const std::string& str) {
        auto origin = cv::Point(5, img.rows - pos - 5);
        text_(img, origin, str);
    }

    void
    textr (Frame& img, size_t pos, const std::string& str) {
        auto origin = cv::Point(img.cols - 15*str.size(), img.rows - pos - 5);
        text_(img, origin, str);
    }

#endif

    ///////////////////////////////////////////////////////////////////////////

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
            (VIEW_WINDOW_WIDTH / 2 - (data.upperHeadX + data.headWidth / 2));
        double yAngle = VGPP * PI180 *
            (VIEW_WINDOW_HEIGHT / 2 - (data.upperHeadY + data.headHeight / 2));
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

#ifdef window_debug

    void
    project_coords (Frame& frame_, const data& data) {
        int w = frame_cols_, h = frame_rows_;
        auto c = cv::Point(w/2, h/2);
        auto color = GREEN;
        auto  a_x_l = cv::Point(c.x - w,  c.y)
            , a_x_r = cv::Point(c.x + w,  c.y)
            , a_y_t = cv::Point(c.x,      c.y - h)
            , a_y_d = cv::Point(c.x,      c.y + h);
        cv::line(frame_, a_x_l, a_x_r, color, 1, 8, 0);
        cv::line(frame_, a_y_t, a_y_d, color, 1, 8, 0);
        auto  p_x = cv::Point(data.gx, c.y)
            , p_y = cv::Point(c.x,     data.gy);
        cv::line(frame_, p_x,p_x, color, 4, 8, 0);
        cv::line(frame_, p_y,p_y, color, 4, 8, 0);
    }

    void
    display_data (Frame& frame_, const data& data) {
        textr(frame_, 270, std::to_string(data.gy) + " :gy");
        textr(frame_, 240, std::to_string(data.gx) + " :gx");
        textr(frame_, 210, std::to_string(data.ears) + " :ears");
        textr(frame_, 180, std::to_string(data.chin) + " :chin");
        textr(frame_, 150, std::to_string(data.das) + " :das");
        textr(frame_, 120, std::to_string(data.al) + " :al");
        textr(frame_, 90,  std::to_string(data.ar) + " :ar");
        textr(frame_, 60,  std::to_string(data.el) + " :el");
        textr(frame_, 30,  std::to_string(data.er) + " :er");
        textr(frame_,  0,  std::to_string(data.n)  + " :n");
        project_coords(frame_, data);
    }

#endif

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

#ifdef window_debug
        cv::namedWindow(WINDOW, 1);
        cv::namedWindow(WINDOW_3, 1);
#endif
        inited_ = true;
    }

#ifndef __EMSCRIPTEN__

    void
    UniVR::init (const std::string& trained_data) {
        /// Specialize this to your FrameStream
        auto default_capture_opener = [](FrameStream& capture) {
            return capture.open(0) && capture.isOpened();
        };
        init(trained_data, default_capture_opener);
    }

    ///////////////////////////////////////////////////////////////////////////

    bool  /// Specialize this to your FrameStream
    UniVR::next_frame () {
        capture_ >> frame_;
        if (frame_.empty())
            return false;

        // Can also pass cv_image objects into the detector directly & that
        // will work fine as well. More generally, you can pass a cv_image
        // object to any dlib image processing function that doesn't try to
        // resize the image.
        // Note: cv::Mat -> BGR, dlib's -> RGB.
        dlib::cv_image<dlib::bgr_pixel> imgcv((frame_));
        dlib::assign_image(img_, imgcv);
        // Make the image larger so we can detect small faces.
        ///dlib::pyramid_up(img); // Resizes image (use array2d with that)

        frame_rows_ = frame_.rows;
        frame_cols_ = frame_.cols;

        return true;
    }

#else

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
        frame_rows_ = FRAME_ROWS_;
        frame_cols_ = FRAME_COLS_;

        int sz = frame_cols_ * frame_rows_ * 3;
        std::cout << count_nonzero(frame_, sz) << std::endl;
        bool usePixels = true;
        html5video_grabber_update(capture_, usePixels, frame_);
        int updated = count_nonzero(frame_, sz);
        if (0 == updated)
            return false;

        img_.set_size(frame_rows_, frame_cols_);
        for (int row = 0; row < frame_rows_ * 3; ++row) {
            for (int col = 0; col < frame_cols_; col += 3) {
                auto ix = row * frame_cols_ + col;
                dlib::rgb_pixel p;
                p.red   = frame_[ix + 0];
                p.green = frame_[ix + 1];
                p.blue  = frame_[ix + 2];
                dlib::assign_pixel(img_[row][col], p);
            }
        }
    }

#endif

    void
    UniVR::maybe_update_rows_cols () {
        // As for changing the detector, that is not so easy and would
        // require a deep understanding of a lot of things so I wouldn't
        // recommend it (except for changing the pyramid down part which
        // you can play with and see how it changes things. You can also
        // downsample an image using pyramid_down<2> pyr; pyr(img); and
        // it will make it smaller than therefore faster for the detector
        // to run. But you won't be able to detect small faces.
#define MAGIC__MINIMUM_CAMERA_HEIGHT  (300)
        if (frame_rows_ / 2 > MAGIC__MINIMUM_CAMERA_HEIGHT) {
            dlib::pyramid_down<2> pyr;
            pyr(img_);
            //FIXME: compute ideal ratio given frame_rows_?
        }

        if (rc_ == 0 || rr_ == 0) {
            rc_ = frame_cols_ / img_.nc();
            rr_ = frame_rows_ / img_.nr();
        }
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
#ifdef window_debug
            rectangle(frame_, rect_found_, 2);
#endif
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
#ifdef window_debug
            for (const auto& det : dets)
                rectangle(frame_, det, 1);
#endif
            if (!dets.empty()) {
                rect_found_ = biggest_rectangle(dets);
#ifdef window_debug
                rectangle(frame_, rect_found_, 4);
#endif
                tracker_.start_track(img_, rect_found_);
                ++Ds_;
                detected_ = true;
            }
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
            if (!zones_.empty())
                rect_found_ = zones_.back();

        if (!rect_found_.is_empty()) {
            /// Extraction
            const auto& face_found = extractor_(img_, rect_found_);
#ifdef window_debug
            dots(frame_, face_found, 1);
            do {
                auto sr = scaled(rect_found_);
                auto cvrect = cv::Rect(sr.left(), sr.top(),
                                       sr.width(), sr.height());
                cv::Mat face_img = frame_(cvrect);
                cv::imshow(WINDOW_3, face_img);
            } while (0);
#endif

            const auto& reconstructed_zone = head_hull(face_found);
            collect_data(data, face_found, scaled(reconstructed_zone));
            zones_.push_back(reconstructed_zone);
        }
        while (zones_.size() > BACKLOG_SZ)
            zones_.pop_front();

#ifdef window_debug
        display_data(frame_, data);
        for (const auto& zone : zones_)
            rectangle(frame_, scaled(zone), 1);
        text(frame_, 30, "Ds: " + std::to_string(Ds_));
        text(frame_, 60, std::to_string(img_.nc())
             +     "x" + std::to_string(img_.nr()));
        text(frame_, 90, std::to_string(frame_cols_)
             +     "x" + std::to_string(frame_rows_));
        text(frame_, 120, "I: " + std::to_string(I_));
        text(frame_, 150, "DROP_AMOUNT: "+std::to_string(DROP_AMOUNT));
        text(frame_, 180, "BACKLOG_SZ: "+std::to_string(BACKLOG_SZ));

        cv::imshow(WINDOW, frame_);
#endif

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////

}
