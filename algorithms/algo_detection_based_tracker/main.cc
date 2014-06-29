#define ALGO "algo_detection_based_tracker"

#include <opencv2/objdetect/detection_based_tracker.hpp> // = EXPERIMENTAL
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>

// Config
#define CASCADE_NAME "xml/haarcascade_frontalface_alt.xml"
#define SCALE 1.1

int
main (int argc, const char* argv[])
{
    std::vector<cv::Rect_<int> > faces; // Note "Rect_"
    cv::DetectionBasedTracker::Parameters param;
    param.maxObjectSize = 400;
    param.maxTrackLifetime = 20;
    param.minDetectionPeriod = 7;
    param.minNeighbors = 3;
    param.minObjectSize = 20;
    param.scaleFactor = SCALE;

    auto obj = cv::DetectionBasedTracker(CASCADE_NAME, param);
    obj.run();
    cv::VideoCapture cap(0);
    cv::Mat img, gray;
    cv::namedWindow(ALGO, 1);

    while (true) {
        cap >> img;
        cv::cvtColor(img, gray, cv::COLOR_RGB2GRAY);

        auto s = std::chrono::high_resolution_clock::now();
        obj.process(gray);
        obj.getObjects(faces);
        auto f = std::chrono::high_resolution_clock::now();
        auto lapse = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);
        std::cout << "\t" << lapse.count() << "ns" << std::endl;

        // if(faces.size() == 0) obj.resetTracking();
        for (const auto& face : faces)
            cv::rectangle(img, face, cv::Scalar(0,255,0), 3);
        cv::imshow(ALGO, img);
        if (cv::waitKey(10) >= 0)
            break;
    }
    obj.stop();

    return 0;
}
