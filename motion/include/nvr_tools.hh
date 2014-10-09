#ifndef NVR_TOOLS_HH
# define NVR_TOOLS_HH

# include <opencv2/opencv.hpp>
# include <opencv2/core/core.hpp>
# include <opencv2/highgui/highgui.hpp>

# include <dlib/opencv.h> // Right after OpenCV's includes
# include <dlib/image_processing/frontal_face_detector.h>
# include <dlib/image_processing/render_face_detections.h>
# include <dlib/image_processing.h>
# include <dlib/image_io.h>

# include <iostream>

//namespace nvr {

    typedef cv::Mat Frame;

    void
    rectangle (Frame& img, const dlib::rectangle& rect, size_t thickness);

    void
    dot (Frame& img, const dlib::point& p, size_t thickness);

    void
    dots (Frame& img, const dlib::full_object_detection& face, size_t thick);

    void
    text (Frame& img, size_t pos, const std::string& str);

    void
    textr (Frame& img, size_t pos, const std::string& str);

    dlib::rectangle
    biggest_rectangle (const std::vector<dlib::rectangle>& rs);

    dlib::rectangle  // Get a square box centered on the nose
    head_hull (const dlib::full_object_detection& face);

    size_t
    landmark_energy (const std::deque<dlib::full_object_detection>& faces);

    bool
    find_movement (const Frame& motion, std::vector<dlib::rectangle>& found);

//} // namespace nvr

#endif /* !NVR_TOOLS_HH */
