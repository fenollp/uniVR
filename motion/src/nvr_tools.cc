#include "nvr_tools.hh"

//namespace nvr {

    void
    rectangle (Frame& img, const dlib::rectangle& rect, size_t thickness,
               int dx, int dy) {
        auto zone =
            cv::Rect(rect.left()  + dx, rect.top()    + dy,
                     rect.width() + dx, rect.height() + dy);
        cv::rectangle(img, zone, cv::Scalar(255,255,255), thickness, 8, 0);
    }

    void
    dot (Frame& img, const dlib::point& p, size_t thickness,
         int dx, int dy) {
        cv::Point pcv(p.x() + dx, p.y() + dy);
        cv::line(img, pcv,pcv, cv::Scalar::all(255), thickness, 8, 0);
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

    dlib::rectangle  // Get a square box centered on the nose
    head_hull (const dlib::full_object_detection& face) {
        dlib::rectangle rect;
        for (size_t j = 0; j < face.num_parts(); ++j)
            rect += face.part(j);  // Enlarges rect's area
        const auto& nose = face.part(30);
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
