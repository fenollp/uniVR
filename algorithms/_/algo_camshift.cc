#include <opencv/cv.h>
#include "_.hh"


cv::CascadeClassifier cascade;
cv::Mat hsv;     //input image converted to HSV
cv::Mat hue;     //hue channel of HSV image
cv::Mat mask;    //image for masking pixels
cv::Mat prob;    //face probability estimates for each pixel
Face   prev_rect;  //location of face in previous frame
CvHistogram* hist; //histogram of hue in original face image
CvBox2D curr_box;  //current face location estimate


void create_tracked_object (cv::Mat& frame, Face& face_rect);
void update_hue_image (cv::Mat& image);


bool
camshift_init (const std::string& CASCADE_NAME, double SCALE,
               cv::VideoCapture& CAPTURE) {
    if (!cascade.load(CASCADE_NAME)) {
        std::cerr << "!load " << CASCADE_NAME << std::endl;
        return false;
    }

    cv::Mat frame;
    Face face_rect;
    while (true) {
        CAPTURE >> frame;
        if (frame.empty())
            break;

        Faces faces;
        cascade.detectMultiScale(frame, faces,
            1.1,  //increase search scale by 10% each pass
            6,    //require 6 neighbors
            cv::CASCADE_SCALE_IMAGE, //skip regions unlikely to contain a face
            cv::Size(0, 0));         //use default face size from xml

        if (!faces.empty()) {
            face_rect = faces[0];
            break;
        }
    }

    create_tracked_object(frame, face_rect);

    std::cout << "Detected face. CAMSHIFT tracking…" << std::endl;
    return true;
}

void
camshift_find (cv::Mat& frame, Faces& faces, double SCALE) {
    CvConnectedComp components;

    //create a new hue image
    update_hue_image(frame);

    //create a probability image based on the face histogram
    cvCalcBackProject(&hue, prob, hist);
    cvAnd(prob, mask, prob, 0);

    //use CamShift to find the center of the new face probability
    cvCamShift(prob,
               prev_rect,
               cvTermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 10, 1),
               &components,
               &curr_box);

    //update face location and angle
    prev_rect = components.rect;
    curr_box.angle = - curr_box.angle;

    faces.push_back(curr_box);
}

void
camshift_stop () {
}





void
create_tracked_object (cv::Mat& frame, Face& face_rect) {
    //create-image: size(w,h), bit depth, channels
    auto sz = frame.size();
    cv::Mat hsv  = cv::Mat(sz, CV_8UC3);
    cv::Mat mask = cv::Mat(sz, CV_8UC1);
    cv::Mat hue  = cv::Mat(sz, CV_8UC1);
    cv::Mat prob = cv::Mat(sz, CV_8UC1);

    int hist_bins = 30;           //number of histogram bins
    float hist_range[] = {0,180}; //histogram range
    float* range = hist_range;
    hist = cvCreateHist(1,             //number of hist dimensions
                        &hist_bins,    //array of dimension sizes
                        CV_HIST_ARRAY, //representation format
                        &range,        //array of ranges for bins
                        1);            //uniformity flag

    update_hue_image(frame);

    float max_val = 0.f;

    //create a histogram representation for the face
    cvSetImageROI(hue, face_rect);
    cvSetImageROI(mask, face_rect);
    cvCalcHist(&hue, hist, 0, mask);
    cvGetMinMaxHistValue(hist, 0, &max_val, 0, 0);
    cvConvertScale(hist->bins,
                   hist->bins,
                   max_val ? 255.0/max_val : 0, 0);
    cvResetImageROI(hue);
    cvResetImageROI(mask);

    prev_rect = face_rect;
}



void
update_hue_image (cv::Mat& image) {
    //limits for calculating hue
    int vmin = 65, vmax = 256, smin = 55;

    //convert to HSV color model
    cv::cvtColor(image, hsv, CV_BGR2HSV);

    //mask out-of-range values
    cv::inRange(hsv,                                   //source
                cvScalar(0,  smin, MIN(vmin,vmax), 0), //lower bound
                cvScalar(180, 256, MAX(vmin,vmax), 0), //upper bound
                mask);                                 //destination

    //extract the hue channel, split: src, dest channels
    cv::split(hsv, &hue);
}
