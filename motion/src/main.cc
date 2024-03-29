#include "nvr_tools.hh"

#define WINDOW "nvr"
#define DROP_AMOUNT 3
#define BACKLOG_SZ 3


int
main (int argc, const char* argv[]) {
    try {
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }

        // A shape_predictor will predict face landmark positions given
        // an image and face bounding box. Here we are loading
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
        std::deque<dlib::full_object_detection> faces_in_zones;

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


            // Detect motion
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
                // Note: static threshold…
                cv::threshold(motion, motion, 15, 255, CV_THRESH_BINARY);
                cv::erode(motion, motion, erosionKernel);
                bool foundSomething = find_movement(motion, zones);
                if (!zones.empty()) {
                    const auto& found = zones.back();
                    rectangle(frame, found, 1);
                    if (foundSomething) {
                        auto r = dlib::centered_rect(found,
                                                     motion.rows / 2,
                                                     motion.cols / 3);
                        zones.pop_back();
                        zones.push_back(r);
                        rectangle(frame, r, 5);
                    }
                }
                // cv::imshow(WINDOW, motion);
            }

            while (faces_in_zones.size() > BACKLOG_SZ)
                faces_in_zones.pop_front();
            if (faces_in_zones.size() == BACKLOG_SZ) {
                auto nrg = landmark_energy(faces_in_zones);
                text(frame, 20, std::to_string(nrg));
            }

            // shape_predictor -> face landmark extraction
            /// for last of potential zones…
            if (!zones.empty()) {
                const auto& rect = zones.back();
                const auto& face = sp(imgcv, rect);
                faces_in_zones.push_back(face);
                // rectangle(frame, head_hull(face), 2);
                dots(frame, face, 4);
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
