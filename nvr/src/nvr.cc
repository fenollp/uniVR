#include "nvr.hh"

#define WINDOW "nvr"

namespace nvr {

    void
    rectangle (Frame& img, const dlib::rectangle& rect, size_t thickness) {
        auto zone =
            cv::Rect(rect.left(), rect.top(), rect.width(), rect.height());
        cv::rectangle(img, zone, cv::Scalar(255,255,255), thickness, 8, 0);
    }

    void
    dot (Frame& img, const dlib::point& p, size_t thickness) {
        cv::Point pcv(p.x(), p.y());
        auto color = cv::Scalar(255,0,0);
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

    void // private
    text_ (Frame& img, const cv::Point& o, const std::string& str) {
        int fface = cv::FONT_HERSHEY_SIMPLEX;
        double fscale = 0.73;
        int thick = 1;
        auto color = cv::Scalar::all(255);
        int baseline = 0;
        auto text = cv::getTextSize(str, fface, fscale, thick, &baseline);
        cv::rectangle(img, o + cv::Point(0, baseline)
                      ,    o + cv::Point(text.width, -text.height),
                      cv::Scalar::all(0), CV_FILLED);
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

#if 0  // DEPRECATED
    size_t
    landmark_energy (size_t rows, size_t cols, const Faces& faces) { //stddev?
        size_t E = 0;
        for (size_t i = 0; i < 68; ++i) {
            int ler = rows, lec = cols;
            for (const auto& face : faces) {
                lec -= face.part(i).x();
                ler -= face.part(i).y();
            }
            E += std::pow(ler, 2) + std::pow(lec, 2);
        }
        return E;
    }
#endif

    ///////////////////////////////////////////////////////////////////////////

    cv::Mat
    erosion_kernel () {
        static const cv::Mat erosionKernel =
            cv::getStructuringElement(cv::MORPH_RECT, cv::Size(9,9));
        return erosionKernel;
    }

#if 0  // DEPRECATED
    bool
    find_movement (const Frame& motion, std::vector<dlib::rectangle>& found) {
        //Check whether stddev[0] < Threshold?
        size_t numberOfChanges = 0;
        size_t minX = motion.cols, maxX = 0;
        size_t minY = motion.rows, maxY = 0;
        for (size_t y = 0; y < motion.rows; y += 2)
            for (size_t x = 0; x < motion.cols; x += 2)
                if (motion.at<uchar>(y, x) == 255) {
                    if (x < minX)  minX = x;
                    if (y < minY)  minY = y;
                    if (maxX < x)  maxX = x;
                    if (maxY < y)  maxY = y;
                    ++numberOfChanges;
                }
        if (numberOfChanges != 0) { // Place within boundaries
            if (minX - 10 > 0)                minX -= 10; // left
            if (minY - 10 > 0)                minY -= 10; // bottom
            if (maxX + 10 < motion.cols - 1)  maxX += 10; // right
            if (maxY + 10 < motion.rows - 1)  maxY += 10; // top
            auto zone = dlib::rectangle(minX, maxY, maxX, minY);
            found.push_back(zone);
            return true;
        }
        return false;
    }
#endif

#if 0  // DEPRECATED
    dlib::rectangle
    UniVR::detect_motion (std::deque<Frame>& frames_) {
        if (I % DROP_AMOUNT == 0) {
            cv::Mat gray(frame_);
            cv::cvtColor(frame_, gray, CV_RGB2GRAY);
            frames_.push_back(gray);
        }
        while (frames_.size() > 3)
            frames_.pop_front();
        if (frames_.size() == 3) {
            cv::Mat d1, d2, motion;
            cv::absdiff(frames_[0], frames_[1], d1);
            cv::absdiff(frames_[1], frames_[2], d2);
            cv::bitwise_and(d1, d2, motion);
            // Note: 15 is a static threshold…
            cv::threshold(motion, motion, 15, 255, CV_THRESH_BINARY);
            cv::erode(motion, motion, erosion_kernel());
            std::vector<dlib::rectangle> zones;
            bool foundSomething = find_movement(motion, zones);
            if (!zones.empty()) {
                const auto& found = zones.back();
                rectangle(frame_, found, 1);
                if (foundSomething) {
                    auto r = dlib::centered_rect(found,
                                                 motion.rows / 2,
                                                 motion.cols / 3);
                    zones.pop_back();
                    zones.push_back(r);
                    return r;
                    rectangle(frame_, r, 5);
                }
            }
            // cv::imshow(WINDOW, motion);
        }
        return dlib::rectangle();
    }
#endif

    ///////////////////////////////////////////////////////////////////////////

    int
    UniVR::motion_energy (const dlib::rectangle& prev_rect) {
        if (prev_rect.is_empty())
            return -1;
        cv::Mat gray(frame_);
        cv::cvtColor(frame_, gray, CV_RGB2GRAY);
        rects_found_.push_back(gray);
        while (rects_found_.size() > 3)
            rects_found_.pop_front();
        if (rects_found_.size() == 3) {
            cv::Mat d1, d2, motion;
            cv::absdiff(rects_found_[0], rects_found_[1], d1);
            cv::absdiff(rects_found_[1], rects_found_[2], d2);
            cv::bitwise_and(d1, d2, motion);
            // Note: static threshold of 1…
            cv::threshold(motion, motion, 1, 255, CV_THRESH_BINARY);
            cv::erode(motion, motion, erosion_kernel());
            rectangle(frame_, prev_rect, 1);//

            int rc = frame_.cols / img_.nc();
            int rr = frame_.rows / img_.nr();
            auto x = prev_rect.left();
            auto y = prev_rect.top();
            auto sx = x * rc;
            auto sy = y * rr;
            auto sw = (x + prev_rect.width()) * rc;
            auto sh = (y + prev_rect.height()) * rr;

            int E = 0;
            for (size_t yy = sy; yy < sh; ++yy) // -> rows
                for (size_t xx = sy; xx < sw; ++xx) // -> cols
                    if (motion.at<uchar>(yy, xx) == 255)
                        ++E;
            auto r = dlib::rectangle(sx,sy,sw,sh);//
            rectangle(frame_, r, 10);//
            // rectangle(motion, r, 1);//
            cv::imshow("motion",
                       motion(cv::Rect(sx, sy,
                                       prev_rect.width() * rc,
                                       prev_rect.height() * rr)));//
            return E;
        }
        return -1;
    }

    dlib::rectangle
    UniVR::scaled (const dlib::rectangle& r) {
        static const int rc = frame_.cols / img_.nc();
        static const int rr = frame_.rows / img_.nr();
        auto x = r.left();
        auto y = r.top();
        auto sx = x * rc;
        auto sy = y * rr;
        auto sw = (x + r.width()) * rc;
        auto sh = (y + r.height()) * rr;
        // Keep away from the edges
        if (sw > frame_.cols)
            sw = frame_.cols - 5;
        if (sh > frame_.rows)
            sh = frame_.rows - 5;
        auto r2 = dlib::rectangle(sx, sy, sw, sh);
        //std::cout << r << " -> " << r2 << std::endl;
        return r2;
    }

    ///////////////////////////////////////////////////////////////////////////

    int
    norm (const Landmarks& face, int part1, int part2) {
        const auto& p1 = face.part(part1);
        const auto& p2 = face.part(part2);
        int x = p1.x() - p2.x();
        int y = p1.y() - p2.y();
        return std::pow(x, 2) + std::pow(y, 2);
    }

    double
    angle (const Landmarks& face, int part1, int part2, int Part1, int Part2) {
        const auto& p1 = face.part(part1);
        const auto& p2 = face.part(part2);
        const auto& P1 = face.part(Part1);
        const auto& P2 = face.part(Part2);
        double m1 = (p2.y() - p1.y()) / (p2.x() - p1.x() + SMOOTHING);
        double m2 = (P2.y() - P1.y()) / (P2.x() - P1.x() + SMOOTHING);
        return std::atan2(1 + m2*m1, m2 - m1);
    }

    void
    collect_data (data& data, Frame& frame_, const Landmarks& face) {
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
        auto g = center(face.get_rect());
        data.gx = g.x();
        data.gy = g.y();

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
    }

    ///////////////////////////////////////////////////////////////////////////

    std::ostream&
    operator<< (std::ostream& o, const UniVR& rhs) {
        //FIXME
    }

    std::ostream&
    operator<< (std::ostream& o, const data& rhs) {
        return o << "data"
                 << " n:" << rhs.n
                 << " er:" << rhs.er << " el:" << rhs.el
                 << " ar:" << rhs.ar << " al:" << rhs.al << " das:" << rhs.das
                 << " chin:" << rhs.chin
                 << " ears:" << rhs.ears
                 << " gx:" << rhs.gx << " gy:" << rhs.gy << std::endl;
    }

    ///////////////////////////////////////////////////////////////////////////

    UniVR::UniVR (const std::string& trained_data) {
        detector_ = dlib::get_frontal_face_detector();
        dlib::deserialize(trained_data) >> extractor_;

        if (!open_capture())
            throw std::string("!cap from webcam 0");
        I = 0;
        Ds = 0;

        cv::namedWindow(WINDOW, 1);//
        cv::namedWindow("motion", 1);//
    }

    UniVR::~UniVR () {
    }

    ///////////////////////////////////////////////////////////////////////////

    bool  /// Specialize this to your FrameStream
    UniVR::open_capture () {
        return capture_.open(0) && capture_.isOpened();
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

        // The detection is far and away the slowest part, so as long as
        // you don't do it that often you should be fine.
        // As for changing the detector, that is not so easy and would
        // require a deep understanding of a lot of things so I wouldn't
        // recommend it (except for changing the pyramid down part which
        // you can play with and see how it changes things. You can also
        // downsample an image using pyramid_down<2> pyr; pyr(img); and
        // it will make it smaller than therefore faster for the detector
        // to run. But you won't be able to detect small faces.
        dlib::pyramid_down<2> pyr;
        pyr(img_);

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////

    bool
    UniVR::step (data& data) {
        if (!next_frame()) // Sets frame_
            return false;

        auto E = motion_energy(rect_found_);

        if (E != 0)
            rect_found_ = dlib::rectangle();

        if (I % DROP_AMOUNT == 0) {
            /// Detection
            auto dets = detector_(img_);
            for (const auto& det : dets)
                rectangle(frame_, det, 1);
            if (!dets.empty()) {
                rect_found_ = biggest_rectangle(dets);
                rectangle(frame_, rect_found_, 4);
                ++Ds;
            }
        }
        if (rect_found_.is_empty())
            if (!zones_.empty())
                rect_found_ = zones_.back();

        if (!rect_found_.is_empty()) {
            if (E != 0) { ///
                /// Extraction
                const auto& face_found = extractor_(img_, rect_found_);
                dots(frame_, face_found, 1);

                collect_data(data, frame_, face_found);
                zones_.push_back(head_hull(face_found));
            } ///
            else ///
                zones_.push_back(rect_found_);
        }
        while (zones_.size() > BACKLOG_SZ)
            zones_.pop_front();

        for (const auto& zone : zones_)//
            rectangle(frame_, scaled(zone), 1);//

        text(frame_, 30, "Ds: " + std::to_string(Ds));
        text(frame_, 60, std::to_string(img_.nc())
             +     "x" + std::to_string(img_.nr()));
        text(frame_, 90, "I: " + std::to_string(I));
        text(frame_, 120, "DROP_AMOUNT: "+std::to_string(DROP_AMOUNT));
        text(frame_, 150, "BACKLOG_SZ: "+std::to_string(BACKLOG_SZ));
        text(frame_, 180, "motion:"+std::to_string(E));

        cv::imshow(WINDOW, frame_);

        ++I;
        return true;
    }

    ///////////////////////////////////////////////////////////////////////////

}
