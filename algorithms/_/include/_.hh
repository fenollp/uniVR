#ifndef __HH
# define __HH

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

# include <iostream>
# include <fstream>

typedef cv::Rect_<int> Face; //dbtracker
typedef std::vector<Face> Faces;

typedef bool (*f_init)(const std::string&, double, cv::VideoCapture&);
typedef void (*f_find)(cv::Mat&, Faces&, double);
typedef void (*f_stop)();

// CAMSHIFT
bool camshift_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture& CAPTURE);
void camshift_find (cv::Mat& frame, Faces& faces, double);
void camshift_stop ();

// Detection-Based Tracker
bool dbt_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture& CAPTURE);
void dbt_find (cv::Mat& frame, Faces& faces, double);
void dbt_stop ();

// Haar
bool haar_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture& CAPTURE);
void haar_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_stop ();

// Haar OCL
bool haar_ocl_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture& CAPTURE);
void haar_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_ocl_stop ();

// SURF OCL
bool surf_ocl_init (const std::string& CASCADE_NAME, double SCALE, cv::VideoCapture& CAPTURE);
void surf_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void surf_ocl_stop ();

#endif /* !__HH */
