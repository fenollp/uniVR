#include <opencv2/core/ocl.hpp>
#include "_.hh"

cv::CascadeClassifier cascade;

void
haar_ocl_init (const std::string& CASCADE_NAME, double SCALE) {
    if (!cascade.load(CASCADE_NAME))
        std::cerr << "!load " << CASCADE_NAME << std::endl;
    std::cout << "Using OpenCL? " << cv::ocl::useOpenCL() << std::endl;
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

void
haar_ocl_stop () {
}
