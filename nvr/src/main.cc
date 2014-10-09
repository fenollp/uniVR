#include "nvr_tools.hh"

#define WINDOW "nvr"
#define DROP_AMOUNT 10 //5
#define BACKLOG_SZ 3


int
main (int argc, const char* argv[]) {
    try {
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }

        // Gets bounding boxes for each face in an image.
        auto detector = dlib::get_frontal_face_detector();
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

        std::deque<dlib::full_object_detection> shapes;

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


            dlib::rectangle rect;
            if (i % DROP_AMOUNT == 0) {
                // Run the full detector every now and then
                // Tell the face detector to give us a list of bounding boxes
                // around all the faces in the image.
                auto dets = detector(img);
                for (const auto& det : dets)
                    rectangle(frame, det, 1);
                text(frame, 20, "#detected: " + std::to_string(dets.size()));
                if (!dets.empty()) {
                    rect = biggest_rectangle(dets);
                    rectangle(frame, rect, 4);
                }
            }
            if (rect.is_empty())
                if (!shapes.empty())
                    rect = head_hull(shapes.back());

            if (!rect.is_empty()) {
                const auto& face = sp(img, rect);
                dots(frame, face, 4);
                shapes.push_back(face);
            }
            while (shapes.size() > BACKLOG_SZ)
                shapes.pop_front();
            if (shapes.size() == BACKLOG_SZ) {
                auto nrg = landmark_energy(shapes);
                text(frame, 0, "energy: " + std::to_string(nrg));
            }


            text(frame, 40, std::to_string(img.nc()) +
                     "x" +  std::to_string(img.nr()));
            text(frame, 60, "i: " + std::to_string(i));
            text(frame, 80, "DROP_AMOUNT: "+std::to_string(DROP_AMOUNT));
            text(frame, 100, "BACKLOG_SZ: "+std::to_string(BACKLOG_SZ));

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
