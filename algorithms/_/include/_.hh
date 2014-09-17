#ifndef __HH
# define __HH

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

# include <iostream>
# include <fstream>

typedef cv::Rect_<int> Face; //dbtracker
typedef std::vector<Face> Faces;

// Detection-Based Tracker
void dbt_init (const std::string& CASCADE_NAME, double SCALE);
void dbt_find (cv::Mat& frame, Faces& faces, double);
void dbt_stop ();

// Haar
void haar_init (const std::string& CASCADE_NAME, double SCALE);
void haar_find (cv::Mat& frame, Faces& faces, double SCALE);
void haar_stop ();


#endif /* !__HH */
