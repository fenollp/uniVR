#include "_.hh"

//cv::CascadeClassifier cascade;


bool
haar_init (double SCALE, cv::VideoCapture&) {
    return true;
}

void
haar_find (cv::Mat& frame, Faces& faces, double SCALE) {
    cv::Mat gray, thumb(cvRound(frame.rows / SCALE),
                        cvRound(frame.cols / SCALE), CV_8UC1);

    cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);
    cv::resize(gray, thumb, thumb.size(), 0, 0, cv::INTER_LINEAR);
    cv::equalizeHist(thumb, thumb);

    cascade.detectMultiScale(thumb, faces,
                             1.1, 2, 0
                             //| cv::CASCADE_FIND_BIGGEST_OBJECT
                             //|cv::CASCADE_DO_ROUGH_SEARCH
                             | cv::CASCADE_SCALE_IMAGE,
                             cv::Size(30, 30));
}

void
haar_stop () {
}
