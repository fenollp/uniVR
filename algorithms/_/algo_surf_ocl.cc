#include <opencv2/core/core.hpp>
#include <opencv2/ocl/ocl.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include "_.hh"


using namespace cv;
using namespace cv::ocl;

const int LOOP_NUM = 10;
const int GOOD_PTS_MAX = 50;
const float GOOD_PORTION = 0.15f;

template<class KPDetector>
struct SURFDetector {
    KPDetector surf;
    SURFDetector (double hessian = 800.0)
        : surf(hessian) {}
    template<class T>
    void operator() (const T& in, const T& mask,
                         std::vector<cv::KeyPoint>& pts, T& descriptors,
                         bool useProvided = false) {
        surf(in, mask, pts, descriptors, useProvided);
    }
};

template<class KPMatcher>
struct SURFMatcher
{
    KPMatcher matcher;
    template<class T>
    void match (const T& in1, const T& in2, std::vector<cv::DMatch>& matches) {
        matcher.match(in1, in2, matches);
    }
};


void
surf_ocl_init (const std::string& CASCADE_NAME, double SCALE) {
}

void
surf_ocl_find (cv::Mat& frame, Faces& faces, double SCALE) {
}

void
surf_ocl_stop () {
}
