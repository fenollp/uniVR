#include "_.hh"

#if CV_VERSION_EPOCH != 3

bool
haar_ocl_init (double SCALE, cv::VideoCapture&) {
    std::cerr << "!version: haarocl needs OpenCV 3" << std::endl;
    return false;
}

void
haar_ocl_find (cv::Mat& frame, Faces& faces, double SCALE) {
}

#else
# include <opencv2/core/ocl.hpp>

cv::CascadeClassifier cascade;

bool
haar_ocl_init (double SCALE, cv::VideoCapture&) {
    return true;
}

void
haar_ocl_find (cv::Mat& frame, Faces& faces, double SCALE) {
    cv::UMat img = frame;
    static cv::UMat gray, smallImg(cvRound(img.rows / SCALE),
                                   cvRound(img.cols / SCALE), CV_8UC1);

    cv::resize(img, smallImg, smallImg.size(), SCALE, SCALE, cv::INTER_LINEAR);
    cv::cvtColor(smallImg, gray, cv::COLOR_BGR2GRAY);
    cv::equalizeHist(gray, gray);

    cascade.detectMultiScale(gray, faces,
                             1.1, 3, 0
                             //| cv::CASCADE_FIND_BIGGEST_OBJECT
                             //|cv::CASCADE_DO_ROUGH_SEARCH
                             | cv::CASCADE_SCALE_IMAGE,
                             cv::Size(30, 30));
}

#endif

void
haar_ocl_stop () {
}
