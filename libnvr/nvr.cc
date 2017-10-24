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

    inline
    long
    rect_top (const dlib::rectangle& r) {
        return std::max(0L, r.top());
    }

    inline
    long
    rect_bottom (long nr, const dlib::rectangle& r) {
        return std::min(nr, r.bottom());
    }

    inline
    long
    rect_left (const dlib::rectangle& r) {
        return std::max(0L, r.left());
    }

    inline
    long
    rect_right (long nc, const dlib::rectangle& r) {
        return std::min(nc, r.right());
    }

    inline
    float
    RGB_to_Y (const dlib::rgb_pixel& p) {
        return 0.2126 * p.red
            + 0.7152 * p.green
            + 0.0722 * p.blue;
    }

// MGI := Mean Greyscale Intensity

    float
    UniVR::MGI_whole_img () const {
        float sum = 0;
        for (long row = 0; row < img_.nr(); ++row)
            for (long col = 0; col < img_.nc(); ++col)
                sum += RGB_to_Y(img_[row][col]);
        return sum / (img_.nr() * img_.nc());
    }

    float
    UniVR::MGI_horizontal_whole_img () const {
        float sum = 0;
        for (long row = 0; row < img_.nr(); ++row) {
            float hz_sum = 0;
            for (long col = 0; col < img_.nc(); ++col)
                hz_sum += RGB_to_Y(img_[row][col]);
            sum += hz_sum / img_.nc();
        }
        return sum / img_.nr();
    }

    float
    UniVR::MGI_left_right_difference_whole_img () const {
        float sum_left = 0;
        float sum_right = 0;
        for (long row = 0; row < img_.nr(); ++row)
            for (long col = 0; col < img_.nc(); ++col) {
                if (col <= img_.nc() / 2)
                    sum_left += RGB_to_Y(img_[row][col]);
                else
                    sum_right += RGB_to_Y(img_[row][col]);
            }
        return sum_left - sum_right;
    }

    float
    UniVR::MGI_face_img () const {
        const auto& r = rect_found_;
        if (r.is_empty())
            return -1;
        auto bottom = rect_bottom(img_.nr(), r);
        auto right = rect_right(img_.nc(), r);
        float sum = 0;
        for (auto row = rect_top(r); row < bottom; ++row)
            for (auto col = rect_left(r); col < right; ++col)
                sum += RGB_to_Y(img_[row][col]);
        return sum / (r.width() * r.height());
    }

    float
    UniVR::MGI_horizontal_face_img () const {
        const auto& r = rect_found_;
        if (r.is_empty())
            return -1;
        auto bottom = rect_bottom(img_.nr(), r);
        auto right = rect_right(img_.nc(), r);
        float sum = 0;
        for (auto row = rect_top(r); row < bottom; ++row) {
            float hz_sum = 0;
            for (auto col = rect_left(r); col < right; ++col)
                hz_sum += RGB_to_Y(img_[row][col]);
            sum += hz_sum / r.width();
        }
        return sum / r.height();
    }

    float
    UniVR::MGI_left_right_difference_face_img () const {
        const auto& r = rect_found_;
        if (r.is_empty())
            return -1;
        auto bottom = rect_bottom(img_.nr(), r);
        auto right = rect_right(img_.nc(), r);
        float sum_left = 0;
        float sum_right = 0;
        auto mid = static_cast<long>(r.width() / 2);
        for (auto row = rect_top(r); row < bottom; ++row)
            for (auto col = rect_left(r); col < right; ++col) {
                if (col <= mid)
                    sum_left += RGB_to_Y(img_[row][col]);
                else
                    sum_right += RGB_to_Y(img_[row][col]);
            }
        return sum_left - sum_right;
    }

    long
    UniVR::face_zone_top () const {
        return rect_top(rect_found_);
    }

    long
    UniVR::face_zone_bottom () const {
        return rect_bottom(img_.nr(), rect_found_);
    }

    long
    UniVR::face_zone_left () const {
        return rect_left(rect_found_);
    }

    long
    UniVR::face_zone_right () const {
        return rect_right(img_.nc(), rect_found_);
    }

    unsigned long
    UniVR::face_zone_width () const {
        return rect_found_.width();
    }

    unsigned long
    UniVR::face_zone_height () const {
        return rect_found_.height();
    }

    unsigned long
    UniVR::face_zone_area () const {
        return rect_found_.area();
    }

    bool
    UniVR::face_zone_is_empty () const {
        return rect_found_.is_empty();
    }

#ifdef window_debug

    cv::Rect
    rect_on_frame (const Frame& f, const dlib::rectangle& r) {
        auto left = rect_left(r);
        auto top = rect_top(r);
        auto w = std::min(static_cast<long>(r.width()), std::abs(f.cols - left));
        auto h = std::min(static_cast<long>(r.height()), std::abs(f.rows - top));
        return cv::Rect(left, top, w, h);
    }

    void
    rectangle (Frame& frame, const dlib::rectangle& rect, size_t thickness) {
        if (rect.is_empty())
            return;
        auto zone = rect_on_frame(frame, rect);
        cv::rectangle(frame, zone, WHITE, thickness, 8, 0);
    }

    void
    dot (Frame& frame, const dlib::point& p, size_t thickness) {
        cv::Point pcv(p.x(), p.y());
        auto color = BLUE;
        auto fface = cv::FONT_HERSHEY_SIMPLEX;
        cv::putText(frame, "+", pcv, fface, .37, color, thickness, 8);
    }

    void
    dots (Frame& frame, const Landmarks& face, size_t thickness) {
        for (size_t k = 0; k < LANDMARKS_COUNT; ++k) {
            const auto& p = face.part(k);
            if (p == dlib::OBJECT_PART_NOT_PRESENT)
                continue;
            dot(frame, p, thickness);
        }
    }

    void // Used by text & textr
    text_ (Frame& frame, const cv::Point& o, const std::string& str) {
        int fface = cv::FONT_HERSHEY_SIMPLEX;
        double fscale = 0.73;
        int thick = 1;
        auto color = WHITE;
        int baseline = 0;
        auto text = cv::getTextSize(str, fface, fscale, thick, &baseline);
        cv::rectangle(frame, o + cv::Point(0, baseline)
                      ,      o + cv::Point(text.width, - text.height)
                      ,BLACK, CV_FILLED);
        cv::putText(frame, str, o, fface, fscale, color, thick, 8);
    }

    void
    text (Frame& frame, size_t pos, const std::string& str) {
        auto origin = cv::Point(5, frame.rows - pos - 5);
        text_(frame, origin, str);
    }

    void
    textr (Frame& frame, size_t pos, const std::string& str) {
        auto origin = cv::Point(frame.cols - 15*str.size(), frame.rows - pos - 5);
        text_(frame, origin, str);
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
        for (size_t j = 0; j < LANDMARKS_COUNT; ++j)
            rect += face.part(j);  // Enlarges rect's area
        const auto& nose = face.part(30);
        // FIXME use front-menton distance as rect's height/width
        return dlib::centered_rect(nose, rect.width(), rect.height());
    }

    ///////////////////////////////////////////////////////////////////////////

    dlib::rectangle
    UniVR::scaled (const dlib::rectangle& r) const {
        auto x = rect_left(r);
        auto y = rect_top(r);
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
    UniVR::scaled (const dlib::point& p) const {
        return dlib::point(p.x() * rc_,  p.y() * rr_);
    }

    ///////////////////////////////////////////////////////////////////////////

    int
    UniVR::norm (const Landmarks& face, int part1, int part2) const {
        const auto& p1 = scaled(face.part(part1));
        const auto& p2 = scaled(face.part(part2));
        int x = p1.x() - p2.x();
        int y = p1.y() - p2.y();
        return std::pow(x, 2) + std::pow(y, 2);
    }

    double
    UniVR::angle (const Landmarks& face,
                  int part1, int part2, int Part1, int Part2) const {
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
    UniVR::collect_data (data& data,
                         const Landmarks& face,
                         const dlib::rectangle& face_zone) const {
        data.w = frame_cols_;
        data.h = frame_rows_;
#if LANDMARKS_COUNT == 68
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
#endif
        auto g = scaled(center(face.get_rect()));
        data.gx = g.x();
        data.gy = g.y();
        // --
        data.headWidth  = face_zone.width();
        data.headHeight = face_zone.height();
        data.upperHeadX = rect_left(face_zone);
        data.upperHeadY = rect_top(face_zone);

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

        for (int i = 0; i < LANDMARKS_COUNT_XY; i += 2) {
            const auto& landmark = face.part(i / 2);
            data.landmarks[i] = landmark.x();
            data.landmarks[i + 1] = landmark.y();
        }
    }

#ifdef window_debug

    void
    UniVR::project_coords (Frame& frame_, const data& data) {
        int w = frame_cols_;
        int h = frame_rows_;
        auto c = cv::Point(w / 2, h / 2);
        auto color = GREEN;
        auto a_x_l = cv::Point(c.x - w,  c.y);
        auto a_x_r = cv::Point(c.x + w,  c.y);
        auto a_y_t = cv::Point(c.x,      c.y - h);
        auto a_y_d = cv::Point(c.x,      c.y + h);
        cv::line(frame_, a_x_l, a_x_r, color, 1, 8, 0);
        cv::line(frame_, a_y_t, a_y_d, color, 1, 8, 0);
        auto p_x = cv::Point(data.gx, c.y);
        auto p_y = cv::Point(c.x, data.gy);
        cv::line(frame_, p_x,p_x, color, 4, 8, 0);
        cv::line(frame_, p_y,p_y, color, 4, 8, 0);
    }

    void
    UniVR::display_data (Frame& frame_, const data& data) {
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
        o << '{'
          << "\"gx\":" << rhs.gx << ','
          << "\"gy\":" << rhs.gy << ','
          << "\"chin\":" << rhs.chin << ','

          << "\"eyeX\":" << rhs.eyeX << ','
          << "\"eyeY\":" << rhs.eyeY << ','
          << "\"eyeZ\":" << rhs.eyeZ << ','

          << "\"n\":" << rhs.n << ','
          << "\"er\":" << rhs.er << ','
          << "\"el\":" << rhs.el << ','
          << "\"ar\":" << rhs.ar << ','
          << "\"al\":" << rhs.al << ','
          << "\"das\":" << rhs.das << ','
          << "\"w\":" << rhs.w << ','
          << "\"h\":" << rhs.h << ','
          << "\"headWidth\":" << rhs.headWidth << ','
          << "\"headHeight\":" << rhs.headHeight << ','
          << "\"upperHeadX\":" << rhs.upperHeadX << ','
          << "\"upperHeadY\":" << rhs.upperHeadY << ','
          << "\"headX\":" << rhs.headX << ','
          << "\"headY\":" << rhs.headY << ','
          << "\"headDist\":" << rhs.headDist
          << '}';
        return o;
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
    UniVR::init (std::function<bool(nvr::FrameStream&)> capture_opener) {
        detector_ = dlib::get_frontal_face_detector();
        dlib::deserialize(std::string(nvr::LANDMARKS_DAT)) >> extractor_;

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
    UniVR::init () {
        /// Specialize this to your FrameStream
        auto default_capture_opener = [](FrameStream& capture) {
            return capture.open(0) && capture.isOpened();
        };
        init(default_capture_opener);
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
        maybe_update_rows_cols();

        rect_found_ = dlib::rectangle();
        detect_then_track(); // Sets rect_found_
        if (rect_found_.is_empty())
            std::cout << "!rect_found_" << std::endl;
        else
            std::cout << "!rect_found_" << std::endl;
        if (rect_found_.is_empty()) {
            if (!zones_.empty())
                rect_found_ = zones_.back();
            else {
                std::cout << "!zones_" << std::endl;
                return false;
            }
        }

        if (!rect_found_.is_empty()) {
            /// Extraction
            const auto& face_found = extractor_(img_, rect_found_);
#ifdef window_debug
            dots(frame_, face_found, 1);
            do {
                auto cvrect = rect_on_frame(frame_, scaled(rect_found_));
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
