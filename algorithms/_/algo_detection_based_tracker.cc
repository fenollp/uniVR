#include <opencv2/objdetect/detection_based_tracker.hpp> // = EXPERIMENTAL
#include "_.hh"

auto obj;

void
dbt_init (const std::string& CASCADE_NAME, double SCALE) {
    cv::DetectionBasedTracker::Parameters param;
    param.maxObjectSize = 400;
    param.maxTrackLifetime = 20;
    param.minDetectionPeriod = 7;
    param.minNeighbors = 3;
    param.minObjectSize = 20;
    param.scaleFactor = SCALE;

    obj = cv::DetectionBasedTracker(CASCADE_NAME, param);
    obj.run();
}

void
dbt_find (cv::Mat& frame, Faces& faces) {
    cv::Mat gray;
    cv::cvtColor(img, gray, cv::COLOR_RGB2GRAY);

    obj.process(gray);
    obj.getObjects(faces);
}

void
dbt_stop () {
    obj.stop();
}
