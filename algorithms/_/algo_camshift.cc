#include <opencv2/video/tracking.hpp>
#include "_.hh"

void create_tracked_object (cv::Mat& image, Face& face_rect);
void update_hue_image (cv::Mat& image);

cv::CascadeClassifier cascade;
Face trackWindow;
cv::Mat hsv;     //input image converted to HSV
cv::Mat hue;     //hue channel of HSV image
cv::Mat mask;    //image for masking pixels
cv::Mat prob;    //face probability estimates for each pixel
cv::Mat hist;    //histogram of hue in original face image
cv::Mat image;


bool
camshift_init (double SCALE, cv::VideoCapture& CAPTURE) {
    cv::Mat frame;
    Face face_rect;
    while (true) {
        CAPTURE >> frame;
        if (frame.empty())
            break;
        frame.copyTo(image);

        Faces faces;
        cascade.detectMultiScale(image, faces,
            1.1,  //increase search scale by 10% each pass
            6,    //require 6 neighbors
            cv::CASCADE_SCALE_IMAGE, //skip regions unlikely to contain a face
            cv::Size(0, 0));         //use default face size from xml

        if (!faces.empty()) {
            face_rect = faces[0];
            break;
        }
    }

    create_tracked_object(image, face_rect);

    trackWindow = face_rect;
    std::cout << "Detected face. CAMSHIFT tracking…" << std::endl;
    return true;
}

void
camshift_find (cv::Mat& frame, Faces& faces, double SCALE) {
    frame.copyTo(image);

    //create a new hue image
    update_hue_image(image);

    float ranges[] = {0, 180};
    const float* hranges = ranges;  //histogram range
    //create a probability image based on the face histogram
    cv::calcBackProject(&hue, 1, 0, hist, prob, &hranges);
    prob &= mask;

    //use CamShift to find the center of the new face probability
    cv::RotatedRect tracked =
        cv::CamShift(prob, trackWindow, cv::TermCriteria(
                         cv::TermCriteria::EPS|cv::TermCriteria::COUNT,10,1) );

    //tracking window
//github.com/Itseez/opencv/blob/master/samples/cpp/camshiftdemo.cpp#L159-L165
    if (trackWindow.area() <= 1) {
        int cols = prob.cols,
            rows = prob.rows,
            r = (MIN(cols, rows) + 5) / 6;
        trackWindow = cv::Rect(trackWindow.x - r, trackWindow.y - r,
                               trackWindow.x + r, trackWindow.y + r)
            & cv::Rect(0, 0, cols, rows);
    }

    faces.push_back(tracked.boundingRect());
}

void
camshift_stop () {
}





void
create_tracked_object (cv::Mat& image, Face& face_rect) {
    //create-image: size(w,h), bit depth, channels
    auto sz = image.size();
    hsv  = cv::Mat(sz, CV_8UC3);
    mask = cv::Mat(sz, CV_8UC1);
    hue  = cv::Mat(sz, CV_8UC1);
    prob = cv::Mat(sz, CV_8UC1);

    int hist_bins = 30;               //number of histogram bins
    float ranges[] = {0, 180};
    const float* hranges = ranges;  //histogram range
    cv::Mat roi(hue, face_rect);
    cv::Mat maskroi(mask, face_rect);
    cv::calcHist(&roi, 1, 0, maskroi, hist, 1, &hist_bins, &hranges);
    // hist = cvCreateHist(1,             //number of hist dimensions
    //                     &hist_bins,    //array of dimension sizes
    //                     CV_HIST_ARRAY, //representation format
    //                     &hranges,      //array of ranges for bins
    //                     1);            //uniformity flag
    cv::normalize(hist, hist, 0, 255, cv::NORM_MINMAX);

    update_hue_image(image);
}



void
update_hue_image (cv::Mat& image) {
    //limits for calculating hue
    int vmin = 65, vmax = 256, smin = 55;

    //convert to HSV color model
    cv::cvtColor(image, hsv, CV_BGR2HSV);

    //mask out-of-range values
    cv::inRange(hsv,                                     //source
                cv::Scalar(0,  smin, MIN(vmin,vmax), 0), //lower bound
                cv::Scalar(180, 256, MAX(vmin,vmax), 0), //upper bound
                mask);                                   //destination

    //extract the hue channel, split: src, dest channels
    cv::split(hsv, &hue);
}
