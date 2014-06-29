#define ALGO "algo_haar"

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <opencv2/highgui/highgui_c.h>

#include <iostream>

// Config
#define CASCADE_NAME "xml/haarcascade_frontalface_alt.xml"
#define SCALE 1.3

int
main (int argc, const char* argv[])
{
    CvCapture* capture = NULL;
    cv::Mat frameIn, frameCopy;
    cv::CascadeClassifier cascade;

    if (!cascade.load(CASCADE_NAME)) {
        std::cerr << "!load " CASCADE_NAME << std::endl;
        return 1;
    }

    if (!(capture = cvCaptureFromCAM(0))) {
        std::cerr << "!cap from webcam 0" << std::endl;
        return 2;
    }
//capture = cvCaptureFromAVI("file.avi");

    cvNamedWindow(ALGO, 1);

    while (true) {
        IplImage* iplImg = cvQueryFrame(capture);
        frameIn = cv::cvarrToMat(iplImg);
        if (frameIn.empty())
            break;
        if (iplImg->origin == IPL_ORIGIN_TL)
            frameIn.copyTo(frameCopy);
        else
            cv::flip(frameIn, frameCopy, 0);

        std::vector<cv::Rect> faces;
        cv::Mat gray, thumb(cvRound(frameCopy.rows / SCALE),
                            cvRound(frameCopy.cols / SCALE), CV_8UC1);

        cv::cvtColor(frameCopy, gray, cv::COLOR_BGR2GRAY);
        cv::resize(gray, thumb, thumb.size(), 0, 0, cv::INTER_LINEAR);
        cv::equalizeHist(thumb, thumb);

        auto s = std::chrono::high_resolution_clock::now();
        cascade.detectMultiScale(thumb, faces,
                                 1.1, 2, 0
                                 //| cv::CASCADE_FIND_BIGGEST_OBJECT
                                 //|cv::CASCADE_DO_ROUGH_SEARCH
                                 | cv::CASCADE_SCALE_IMAGE,
                                 cv::Size(30, 30));
        auto f = std::chrono::high_resolution_clock::now();
        auto lapse = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);
        std::cout << "\t" << lapse.count() << "ns" << std::endl;

        for (const cv::Rect& f : faces) {
            cv::Point center(cvRound((f.x + f.width * 0.5) * SCALE),
                             cvRound((f.y + f.height * 0.5) * SCALE));
            int r = cvRound((f.width + f.height) * 0.5 * 0.5 * SCALE);
            cv::circle(frameCopy, center, r, CV_RGB(0,128,255), 3, 8, 0);
        }
        cv::imshow(ALGO, frameCopy);

        if (cv::waitKey(10) >= 0)
            break;
    }
    cvReleaseCapture(&capture);
    cvDestroyWindow(ALGO);

    return 0;
}
