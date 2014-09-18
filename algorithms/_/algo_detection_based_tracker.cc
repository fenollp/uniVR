#include "_.hh"

#if CV_VERSION_EPOCH != 3

bool
dbt_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture&) {
    std::cerr << "!version: DBT needs OpenCV 3" << std::endl;
    return false;
}

void
dbt_find (cv::Mat& frame, Faces& faces, double SCALE) {
}

void
dbt_stop () {
}

#else
# include <opencv2/objdetect/detection_based_tracker.hpp> // = EXPERIMENTAL

auto obj;

bool
dbt_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture&) {
    cv::DetectionBasedTracker::Parameters param;
    param.maxObjectSize = 400;
    param.maxTrackLifetime = 20;
    param.minDetectionPeriod = 7;
    param.minNeighbors = 3;
    param.minObjectSize = 20;
    param.scaleFactor = SCALE;

    obj = cv::DetectionBasedTracker(CASCADE_NAME, param);
    obj.run();
    return true;
}

void
dbt_find (cv::Mat& frame, Faces& faces, double SCALE) {
    cv::Mat gray;
    cv::cvtColor(img, gray, cv::COLOR_RGB2GRAY);

    obj.process(gray);
    obj.getObjects(faces);
}

void
dbt_stop () {
    obj.stop();
}

#endif
