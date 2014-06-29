#define ALGO "algo_haar_ocl"

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/ocl.hpp>

#include <iostream>

// Config
#define CASCADE_NAME "xml/haarcascade_frontalface_alt.xml"
#define SCALE 1.3

void
detectAndDraw (cv::UMat& img, cv::Mat& canvas, cv::CascadeClassifier& cascade);

int
main (int argc, const char* argv[])
{
    cv::VideoCapture capture;
    cv::UMat frame, image;
    cv::Mat canvas;
    cv::CascadeClassifier cascade;

    if (!cascade.load(CASCADE_NAME)) {
        std::cerr << "!load " CASCADE_NAME << std::endl;
        return 1;
    }

    if (!capture.open(0) || !capture.isOpened()) {
        std::cerr << "!cap from webcam 0" << std::endl;
        return 2;
    }

    cv::namedWindow(ALGO, 1);
    std::cout << "Using OpenCL? " << cv::ocl::useOpenCL() << std::endl;

    while (true) {
        capture >> frame;
        if (frame.empty())
            break;

        detectAndDraw(frame, canvas, cascade);

        if (cv::waitKey(10) >= 0)
            break;
    }

    return 0;
}

void
detectAndDraw (cv::UMat& img, cv::Mat& canvas, cv::CascadeClassifier& cascade)
{
    std::vector<cv::Rect> faces;
    static cv::UMat gray, smallImg(cvRound(img.rows / SCALE),
                                   cvRound(img.cols / SCALE), CV_8UC1);

    cv::resize(img, smallImg, smallImg.size(), SCALE, SCALE, cv::INTER_LINEAR);
    cv::cvtColor(smallImg, gray, cv::COLOR_BGR2GRAY);
    cv::equalizeHist(gray, gray);

    auto s = std::chrono::high_resolution_clock::now();
    cascade.detectMultiScale(gray, faces,
                             1.1, 3, 0
                             //| cv::CASCADE_FIND_BIGGEST_OBJECT
                             //|cv::CASCADE_DO_ROUGH_SEARCH
                             | cv::CASCADE_SCALE_IMAGE,
                             cv::Size(30, 30));
    auto f = std::chrono::high_resolution_clock::now();
    auto lapse = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);
    std::cout << "\t" << lapse.count() << "ns" << std::endl;

    smallImg.copyTo(canvas);

    for (const cv::Rect& f : faces) {
        cv::Point center(cvRound((f.x + f.width * 0.5) * SCALE),
                         cvRound((f.y + f.height * 0.5) * SCALE));
        int r = cvRound((f.width + f.height) * 0.5 * 0.5 * SCALE);
        cv::circle(canvas, center, r, cv::Scalar(0,128,255), 3, 8, 0);
    }
    cv::imshow(ALGO, canvas);
}
