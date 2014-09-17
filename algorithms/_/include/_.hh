#ifndef __HH
# define __HH

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

# include <iostream>
# include <fstream>

typedef cv::Rect_<int> Face; //dbtracker
typedef std::vector<Face> Faces;

// CAMSHIFT
void camshift_init (const std::string& CASCADE_NAME, double SCALE);
void camshift_find (cv::Mat& frame, Faces& faces, double);
void camshift_stop ();

// Detection-Based Tracker
void dbt_init (const std::string& CASCADE_NAME, double SCALE);
void dbt_find (cv::Mat& frame, Faces& faces, double);
void dbt_stop ();

// Haar
void haar_init (const std::string& CASCADE_NAME, double SCALE);
void haar_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_stop ();

// Haar OCL
void haar_ocl_init (const std::string& CASCADE_NAME, double SCALE);
void haar_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_ocl_stop ();

// SURF OCL
void surf_ocl_init (const std::string& CASCADE_NAME, double SCALE);
void surf_ocl_find (cv::Mat& frame, Faces& faces, double SCALE);
void surf_ocl_stop ();


#endif /* !__HH */
