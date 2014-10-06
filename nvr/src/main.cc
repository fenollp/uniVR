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
#define DROP_AMOUNT 5


int
main (int argc, const char* argv[]) {
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
        auto detector = dlib::get_frontal_face_detector();
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

        cv::Mat frame;
        cv::namedWindow(WINDOW, 1);

        std::deque<dlib::cv_image<dlib::bgr_pixel> > prevs;
        std::vector<dlib::rectangle> dets;
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
            dlib::array2d<dlib::rgb_pixel> img;
            dlib::assign_image(img, imgcv);
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
            dlib::pyramid_down<2> pyr;
            pyr(img);

            dets.clear();
            if (i % DROP_AMOUNT == 0) {
                // Run the full detector every now and then
                // Tell the face detector to give us a list of bounding boxes
                // around all the faces in the image.
                dets = detector(img);
                for (const auto& det : dets) {
                    auto r = cv::Rect(det.left(), det.top(),
                                         det.width(), det.height());
                    cv::rectangle(frame, r, cv::Scalar(255,255,255), 1, 8, 0);
                }
                std::cout << "# Faces detected: " << dets.size() << std::endl;
            } else {
                // For most frames just guess where the face is
                // based on the last one
                for (const auto& face : shapes) {
                    // Get a square box centered on the nose
                    dlib::rectangle rect;
                    for (size_t j = 0; j < face.num_parts(); ++j)
                        rect += face.part(j);
                    const auto& nose = face.part(30);
                    dets.push_back( // ROI
                        dlib::centered_rect(nose, rect.width(), rect.width()));
                }
                std::cout << "Dropped frame" << std::endl;
            }

            shapes.clear();
            // Now we will go ask the shape_predictor to tell us the pose of
            // each face we detected.
            for (const auto& det : dets) {
            // Say det is whole frame:
            // const auto det = dlib::rectangle(img.nc(), img.nr());
            std::cout << img.nc() << " " << img.nr() << std::endl;
                const auto& face = sp(img, det);
                for (size_t k = 0; k < face.num_parts(); ++k) {
                    const auto& p = face.part(k);
                    if (p == dlib::OBJECT_PART_NOT_PRESENT)
                        continue;
                    cv::Point pcv(p.x(), p.y());
                    cv::line(frame, pcv,pcv, cv::Scalar(255,255,255), 4, 8,0);
                }
                shapes.push_back(face);
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
