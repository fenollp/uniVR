#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <dlib/opencv.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>

#include <iostream>

#define WINDOW "nvr"
#define DROP_AMOUNT 1

typedef cv::Mat Frame;

void
rectangle (Frame& frame, const dlib::rectangle& rect, size_t thickness) {
    auto zone = cv::Rect(rect.left(), rect.top(), rect.width(), rect.height());
    cv::rectangle(frame, zone, cv::Scalar(255,255,255), thickness, 8, 0);
}

void
dot (Frame& frame, const dlib::point& p, size_t thickness) {
    cv::Point pcv(p.x(), p.y());
    cv::line(frame, pcv,pcv, cv::Scalar(255,255,255), thickness, 8, 0);
}

dlib::rectangle  // Get a square box centered on the nose
head_hull (const dlib::full_object_detection& face) {
    dlib::rectangle rect;
    for (size_t j = 0; j < face.num_parts(); ++j)
        rect += face.part(j);  // Enlarges rect's area
    const auto& nose = face.part(30);
    return dlib::centered_rect(nose, rect.width(), rect.width()); //MAY !square
}

bool
find_movement (const Frame& motion, std::vector<dlib::rectangle>& found) {
    //Check whether stddev[0] < Threshold?
    size_t numberOfChanges = 0;
    size_t minX = motion.cols, maxX = 0;
    size_t minY = motion.rows, maxY = 0;
    for (size_t y = 0; y < motion.rows; y += 2)
        for (size_t x = 0; x < motion.cols; x += 2)
            if (motion.at<uchar>(y, x) == 255) {
                if (x < minX)  minX = x;
                if (y < minY)  minY = y;
                if (maxX < x)  maxX = x;
                if (maxY < y)  maxY = y;
                ++numberOfChanges;
            }
    if (numberOfChanges != 0) {
        // Replace within boundaries
        if (minX - 10 > 0)  minX -= 10;
        if (minY - 10 > 0)  minY -= 10;
        if (maxX + 10 < motion.cols - 1)  maxX += 10;
        if (maxY + 10 < motion.rows - 1)  maxY += 10;
        // rectangle(left, top, right, bottom)
        auto zone = dlib::rectangle(minX, maxY, maxX, minY);
        found.push_back(zone);
        return true;
    }
    return false;
}


int
main (int argc, const char* argv[]) {
    try {
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }
        // A shape_predictor will predict face landmark positions given
        //  an image and face bounding box.  Here we are loading
        // the model from the 68_face_landmarks.dat file given.
        dlib::shape_predictor sp;
        dlib::deserialize(argv[1]) >> sp;

        Frame frame;
        cv::VideoCapture capture;
        if (!capture.open(0) || !capture.isOpened()) {
            std::cerr << "!cap from webcam 0" << std::endl;
            return 2;
        }

        cv::namedWindow(WINDOW, 1);

        cv::Mat erosionKernel =
            cv::getStructuringElement(cv::MORPH_RECT, cv::Size(9,9));
        std::deque<Frame> prevs;
        std::vector<dlib::rectangle> zones;

        std::vector<dlib::full_object_detection> shapes;
        size_t i = 0;
        while (true) {
            capture >> frame;
            if (frame.empty())
                break;

            // Can also pass cv_image objects into the detector directly & that
            // will work fine as well. More generally, you can pass a cv_image
            // object to any dlib image processing function that doesn't try to
            // resize the image.
            // Note: cv::Mat -> BGR, dlib's -> RGB.
            dlib::cv_image<dlib::bgr_pixel> imgcv(frame);
            // dlib::array2d<dlib::rgb_pixel> img;
            // dlib::assign_image(img, imgcv);
            // Make the image larger so we can detect small faces.
            ///dlib::pyramid_up(img); // Resizes image (use array2d with that)

            // The detection is far and away the slowest part, so as long as
            // you don't do it that often you should be fine.
            // As for changing the detector, that is not so easy and would
            // require a deep understanding of a lot of things so I wouldn't
            // recommend it (except for changing the pyramid down part which
            // you can play with and see how it changes things. You can also
            // downsample an image using pyramid_down<2> pyr; pyr(img); and
            // it will make it smaller than therefore faster for the detector
            // to run. But you won't be able to detect small faces.
            // dlib::pyramid_down<2> pyr;
            // pyr(img);

            if (i % DROP_AMOUNT == 0) {
                cv::Mat gray(frame);
                cv::cvtColor(frame, gray, CV_RGB2GRAY);
                prevs.push_back(gray);
            }
            while (prevs.size() > 3)
                prevs.pop_front();
            if (prevs.size() == 3) {
                cv::Mat d1, d2, motion;
                cv::absdiff(prevs[0], prevs[1], d1);
                cv::absdiff(prevs[1], prevs[2], d2);
                cv::bitwise_and(d1, d2, motion);
                cv::threshold(motion, motion, 15, 255, CV_THRESH_BINARY);
                cv::erode(motion, motion, erosionKernel);
                if (find_movement(motion, zones))
                    rectangle(frame, zones.back(), 5);
                //cv::imshow(WINDOW, motion);
            }

            // shape_predictor -> face landmark extraction
            /// for last of potential zones…
            if (!zones.empty())
                for (const auto& rect : {zones.back()}) {
                    const auto& face = sp(imgcv, rect);
                    for (size_t k = 0; k < face.num_parts(); ++k) {
                        const auto& p = face.part(k);
                        if (p == dlib::OBJECT_PART_NOT_PRESENT)
                            continue;
                        dot(frame, p, 4);
                    }
                }

            cv::imshow(WINDOW, frame);
            //std::cin.get();
            ++i;
        }
    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
    }
}
