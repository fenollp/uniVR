#define ALGO "algo_detection_based_tracker"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/objdetect/detection_based_tracker.hpp>
#include <opencv2/objdetect.hpp>

#include <iostream>

using namespace std;
using namespace cv;

class CascadeDetectorAdapter: public DetectionBasedTracker::IDetector
{
public:
    CascadeDetectorAdapter (cv::Ptr<cv::CascadeClassifier> detector)
        : IDetector(), Detector(detector) {
        CV_Assert(!detector.empty());
    }

    void detect (const cv::Mat &Image, std::vector<cv::Rect> &objects) {
        Detector->detectMultiScale(Image, objects, scaleFactor, minNeighbours,
                                   0, minObjSize, maxObjSize);
    }

    virtual ~CascadeDetectorAdapter () {}

private:
    CascadeDetectorAdapter ();
    cv::Ptr<cv::CascadeClassifier> Detector;
};

// Config
#define CASCADE_NAME "xml/lbpcascade_frontalface.xml"

int
main (int argc, const char* argv[])
{
    namedWindow(ALGO, 1);

    VideoCapture VideoStream(0);

    if (!VideoStream.isOpened()) {
        std::cerr << "!cap from webcam 0" << std::endl;
        return 2;
    }

    auto cascade =
        new cv::CascadeClassifier(CASCADE_NAME);
    cv::Ptr<DetectionBasedTracker::IDetector> MainDetector =
        new CascadeDetectorAdapter(cascade);

    cascade = new cv::CascadeClassifier(CASCADE_NAME);
    cv::Ptr<DetectionBasedTracker::IDetector> TrackingDetector =
        new CascadeDetectorAdapter(cascade);

    DetectionBasedTracker::Parameters params;
    DetectionBasedTracker Detector(MainDetector, TrackingDetector, params);

    if (!Detector.run()) {
        std::cerr << "!init" << std::endl;
        return 2;
    }

    cv::Mat ReferenceFrame, GrayFrame;
    std::vector<cv::Rect> Faces;

    while (true) {
        VideoStream >> ReferenceFrame;
        cv::cvtColor(ReferenceFrame, GrayFrame, COLOR_RGB2GRAY);
        Detector.process(GrayFrame);
        Detector.getObjects(Faces);

        for (const auto& face : Faces)
            rectangle(ReferenceFrame, face, cv::RGB(0,255,0));

        cv::imshow(ALGO, ReferenceFrame);

        if (cv::waitKey(10) >= 0) break;
    }

    Detector.stop();

    return 0;
}
