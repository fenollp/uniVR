#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
//#include <opencv2/core/utility.hpp>

#include <opencv2/highgui/highgui_c.h>

#include <cctype>
#include <iostream>
#include <iterator>
#include <stdio.h>

using namespace std;
using namespace cv;

#define CASCADE_NAME "xml/haarcascade_frontalface_alt.xml"
#define NESTED_CASCADE_NAME "xml/haarcascade_eye_tree_eyeglasses.xml"
#define SCALE 1.3
#define ALGO "algo_basic_haar"

void detectAndDraw(Mat& img, CascadeClassifier& cascade,
                    CascadeClassifier& nestedCascade);

int
main ( int argc, const char** argv )
{
    CvCapture* capture = NULL;
    Mat frame, frameCopy, image;

    CascadeClassifier cascade, nestedCascade;

    if (!nestedCascade.load(NESTED_CASCADE_NAME))
        std::cerr << "!load " NESTED_CASCADE_NAME << std::endl;
    if (!cascade.load(CASCADE_NAME)) {
        std::cerr << "!load " CASCADE_NAME << std::endl;
        return 1;
    }

    if (!(capture = cvCaptureFromCAM(0)))
        std::cerr << "!cap from webcam 0" << std::endl;
//capture = cvCaptureFromAVI( inputName.c_str() );

    cvNamedWindow(ALGO, 1);

    if (capture) {
        std::cout << "In capture ..." << std::endl;

        for (;;) {
            IplImage* iplImg = cvQueryFrame(capture);
            frame = cv::cvarrToMat(iplImg);
            if (frame.empty())
                break;
            if (iplImg->origin == IPL_ORIGIN_TL)
                frame.copyTo(frameCopy);
            else
                flip(frame, frameCopy, 0);

            detectAndDraw(frameCopy, cascade, nestedCascade);

            if (waitKey(10) >= 0)
                cvReleaseCapture(&capture);
        }

        waitKey(0);
        cvReleaseCapture(&capture);
    }
    cvDestroyWindow(ALGO);

    return 0;
}

void
detectAndDraw(Mat& img,
              CascadeClassifier& cascade,
              CascadeClassifier& nestedCascade)
{
    double scale = SCALE;
    int i = 0;
    double t = 0;
    vector<Rect> faces, faces2;
    const static Scalar colors[] =  { CV_RGB(0,0,255),
                                      CV_RGB(0,128,255),
                                      CV_RGB(0,255,255),
                                      CV_RGB(0,255,0),
                                      CV_RGB(255,128,0),
                                      CV_RGB(255,255,0),
                                      CV_RGB(255,0,0),
                                      CV_RGB(255,0,255) };
    Mat gray, smallImg(cvRound(img.rows / scale),
                       cvRound(img.cols / scale), CV_8UC1);

    cvtColor(img, gray, COLOR_BGR2GRAY);
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
    equalizeHist(smallImg, smallImg);

    t = (double)cvGetTickCount();
    cascade.detectMultiScale(smallImg, faces,
                             1.1, 2, 0
                             //|CASCADE_FIND_BIGGEST_OBJECT
                             //|CASCADE_DO_ROUGH_SEARCH
                             |CASCADE_SCALE_IMAGE,
                             Size(30, 30));
    t = (double)cvGetTickCount() - t;
    printf( "detection time = %g ms\n", t/((double)cvGetTickFrequency()*1000.) );
    for (vector<Rect>::const_iterator r = faces.begin(); r != faces.end(); r++, i++ ) {
        Mat smallImgROI;
        vector<Rect> nestedObjects;
        Point center;
        Scalar color = colors[i%8];
        int radius;

        double aspect_ratio = (double)r->width/r->height;
        if (0.75 < aspect_ratio && aspect_ratio < 1.3) {
            center.x = cvRound((r->x + r->width*0.5)*scale);
            center.y = cvRound((r->y + r->height*0.5)*scale);
            radius = cvRound((r->width + r->height)*0.25*scale);
            circle( img, center, radius, color, 3, 8, 0 );
        }
        else
            rectangle(img,
                      cvPoint(cvRound(r->x * scale),
                              cvRound(r->y * scale)),
                      cvPoint(cvRound((r->x + r->width - 1) * scale),
                              cvRound((r->y + r->height - 1) * scale)),
                      color, 3, 8, 0);
        if (nestedCascade.empty())
            continue;
        smallImgROI = smallImg(*r);
        nestedCascade.detectMultiScale(smallImgROI, nestedObjects,
                                       1.1, 2, 0
                                       //|CASCADE_FIND_BIGGEST_OBJECT
                                       //|CASCADE_DO_ROUGH_SEARCH
                                       //|CASCADE_DO_CANNY_PRUNING
                                       |CASCADE_SCALE_IMAGE,
                                       Size(30, 30));
        for ( vector<Rect>::const_iterator nr = nestedObjects.begin(); nr != nestedObjects.end(); nr++ ) {
            center.x = cvRound((r->x + nr->x + nr->width * 0.5) * scale);
            center.y = cvRound((r->y + nr->y + nr->height * 0.5) * scale);
            radius = cvRound((nr->width + nr->height) * 0.25 * scale);
            circle(img, center, radius, color, 3, 8, 0);
        }
    }
    cv::imshow(ALGO, img);
}
