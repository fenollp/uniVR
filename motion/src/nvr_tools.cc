#include "nvr_tools.hh"

//namespace nvr {

    void
    rectangle (Frame& img, const dlib::rectangle& rect, size_t thickness) {
        auto zone =
            cv::Rect(rect.left(), rect.top(), rect.width(), rect.height());
        cv::rectangle(img, zone, cv::Scalar(255,255,255), thickness, 8, 0);
    }

    void
    dot (Frame& img, const dlib::point& p, size_t thickness) {
        cv::Point pcv(p.x(), p.y());
        cv::line(img, pcv,pcv, cv::Scalar::all(255), thickness, 8, 0);
    }

    void
    dots (Frame& img, const dlib::full_object_detection& face, size_t thick) {
        for (size_t k = 0; k < face.num_parts(); ++k) {
            const auto& p = face.part(k);
            if (p == dlib::OBJECT_PART_NOT_PRESENT)
                continue;
            dot(img, p, thick);
        }
    }

    void
    text (Frame& img, const std::string& str, size_t pos) {
        int fface = cv::FONT_HERSHEY_SIMPLEX;
        double fscale = 1;
        int thick = 2;
        auto color = cv::Scalar::all(255);
        auto origin = cv::Point(0, img.rows - pos);
        cv::putText(img, str, origin, fface, fscale, color, thick, 8);
    }

    bool  // Used by biggest_rectangle.
    cmp_areas (const dlib::rectangle& lr, const dlib::rectangle& rr) {
        return lr.area() < rr.area();
    }

    dlib::rectangle
    biggest_rectangle (const std::vector<dlib::rectangle>& rs) {
        return *std::max_element(std::begin(rs), std::end(rs), cmp_areas);
    }

    dlib::rectangle  // Get a square box centered on the nose
    head_hull (const dlib::full_object_detection& face) {
        dlib::rectangle rect;
        for (size_t j = 0; j < face.num_parts(); ++j)
            rect += face.part(j);  // Enlarges rect's area
        const auto& nose = face.part(30);
        // FIXME use front-menton distance as rect's height/width
        return dlib::centered_rect(nose, rect.width(), rect.height());
    }

    size_t
    landmark_energy (const std::deque<dlib::full_object_detection>& faces) {
        size_t E = 0;
        for (size_t i = 0; i < 68; ++i) {
            const auto& part2i = faces[2].part(i);
            const auto& part1i = faces[1].part(i);
            const auto& part0i = faces[0].part(i);
            E  += std::pow(part2i.x() - part1i.x() - part0i.x(), 2)
                + std::pow(part2i.y() - part1i.y() - part0i.y(), 2);
        }
        return E;
    }

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

//}
