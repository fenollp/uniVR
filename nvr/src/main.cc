#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <dlib/opencv.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>

#include <iostream>

#define WINDOW "nvr"


int
main (int argc, char** argv) {
    try {
        // Takes in a shape model file and then a list of images to
        // process.  We will take these filenames in as command line arguments.
        // Dlib comes with example images in the examples/faces folder so give
        // those as arguments to this program.
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }

        // We need a face detector.  We will use this to get bounding boxes for
        // each face in an image.
        dlib::frontal_face_detector detector =
            dlib::get_frontal_face_detector();
        // We also need a shape_predictor. It will predict face landmark
        // positions given an image and face bounding box.  Here we are loading
        // the model from the 68_face_landmarks.dat file given.
        dlib::shape_predictor sp;
        dlib::deserialize(argv[1]) >> sp;

        cv::VideoCapture capture;
        if (!capture.open(0) || !capture.isOpened()) {
            std::cerr << "!cap from webcam 0" << std::endl;
            return 2;
        }

        cv::namedWindow(WINDOW, 1);

        while (true) {
            cv::Mat frame;
            capture >> frame;
            if (frame.empty())
                break;

            // Can also pass cv_image objects into the detector directly & that
            // will work fine as well. More generally, you can pass a cv_image
            // object to any dlib image processing function that doesn't try to
            // resize the image.
            // Note: cv::Mat -> BGR, dlib's -> RGB.
            dlib::array2d<dlib::rgb_pixel> img;
            dlib::assign_image(img, dlib::cv_image<dlib::bgr_pixel>(frame));
            // Make the image larger so we can detect small faces.
            ///dlib::pyramid_up(img);

            // Now tell the face detector to give us a list of bounding boxes
            // around all the faces in the image.
            std::vector<dlib::rectangle> dets = detector(img);
            std::cout << "# Faces detected: " << dets.size() << std::endl;

            // Now we will go ask the shape_predictor to tell us the pose of
            // each face we detected.
            for (size_t j = 0; j < dets.size(); ++j) {
                dlib::full_object_detection face = sp(img, dets[j]);
                size_t num_parts = face.num_parts();
                for (size_t k = 0; k < num_parts; ++k) {
                    const dlib::point p = face.part(k);
                    if (p == dlib::OBJECT_PART_NOT_PRESENT)
                        continue;
                    cv::Point pcv(p.x(), p.y());
                    cv::line(frame, pcv,pcv, cv::Scalar(255,255,255), 4, 8,0);
                }
            }

            cv::imshow(WINDOW, frame);
            //std::cin.get();
        }
    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!" << std::endl
                  << e.what() << std::endl;
    }
}
