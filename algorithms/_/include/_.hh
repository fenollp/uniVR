#ifndef __HH
# define __HH

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

# include <iostream>
# include <fstream>

typedef cv::Rect_<int> Face; //dbtracker
typedef std::vector<Face> Faces;

typedef bool (*f_init)(double, cv::VideoCapture&);
typedef void (*f_find)(cv::Mat&, Faces&, double);
typedef void (*f_stop)();

// CAMSHIFT
bool camshift_init (double SCALE, cv::VideoCapture& CAPTURE);
void camshift_find (cv::Mat& frame, Faces& faces, double);
void camshift_stop ();

// Detection-Based Tracker
bool dbt_init (double SCALE, cv::VideoCapture& CAPTURE);
void dbt_find (cv::Mat& frame, Faces& faces, double);
void dbt_stop ();

// Haar
bool haar_init (double SCALE, cv::VideoCapture& CAPTURE);
void haar_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_stop ();

// Haar OCL
bool haar_ocl_init (double SCALE, cv::VideoCapture& CAPTURE);
void haar_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_ocl_stop ();

// HoG
bool hog_init (double SCALE, cv::VideoCapture& CAPTURE);
void hog_find (cv::Mat& frame, Faces& faces, double SCALE);
void hog_stop ();

// SURF OCL
bool surf_ocl_init (double SCALE, cv::VideoCapture& CAPTURE);
void surf_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void surf_ocl_stop ();


extern cv::CascadeClassifier cascade;


#endif /* !__HH */
