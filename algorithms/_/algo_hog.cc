#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

#include <dlib/opencv.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include "_.hh"

dlib::frontal_face_detector detector;


bool
hog_init (double SCALE, cv::VideoCapture&) {
    detector = dlib::get_frontal_face_detector();
    return true;
}

void
hog_find (cv::Mat& frame, Faces& faces, double SCALE) {
    dlib::cv_image<dlib::bgr_pixel> imgcv(frame);
    std::vector<dlib::rectangle> dets = detector(imgcv);

    for (const auto& rect : dets) {
        Face cvface(rect.left(), rect.top(), rect.width(), rect.height());
        // Rect_(_Tp _x, _Tp _y, _Tp _width, _Tp _height);
        faces.push_back(cvface);
    }

    // for (const auto& face : shapes) {
    //     // Get a square box centered on the nose
    //     dlib::rectangle rect;
    //     for (size_t j = 0; j < face.num_parts(); ++j)
    //         rect += face.part(j);
    //     const auto& nose = face.part(30);
    //     dets.push_back( // ROI
    //         dlib::centered_rect(nose, rect.width(), rect.width()));
}

void
hog_stop () {
}
