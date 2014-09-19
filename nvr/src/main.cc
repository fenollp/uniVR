#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <iostream>

using namespace dlib;

int
main (int argc, char** argv) {
    try {
        // Takes in a shape model file and then a list of images to
        // process.  We will take these filenames in as command line arguments.
        // Dlib comes with example images in the examples/faces folder so give
        // those as arguments to this program.
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl;
            std::cout << "./nvr 68_face_landmarks.dat face.jpg" << std::endl;
            return 0;
        }

        // We need a face detector.  We will use this to get bounding boxes for
        // each face in an image.
        frontal_face_detector detector = get_frontal_face_detector();
        // We also need a shape_predictor. It will predict face landmark
        // positions given an image and face bounding box.  Here we are loading
        // the model from the 68_face_landmarks.dat file given via CLI.
        shape_predictor sp;
        deserialize(argv[1]) >> sp;


        image_window win;
        // Loop over all the images provided on the command line.
        for (int i = 2; i < argc; ++i) {
            std::cout << "processing image " << argv[i] << std::endl;
            array2d<rgb_pixel> img;
            load_image(img, argv[i]);
            // Make the image larger so we can detect small faces.
            pyramid_up(img);

            // Now tell the face detector to give us a list of bounding boxes
            // around all the faces in the image.
            std::vector<rectangle> dets = detector(img);
            std::cout << "# Faces detected: " << dets.size() << std::endl;

            // Now we will go ask the shape_predictor to tell us the pose of
            // each face we detected.
            std::vector<full_object_detection> shapes;
            for (size_t j = 0; j < dets.size(); ++j) {
                full_object_detection shape = sp(img, dets[j]);
                std::cout << "# Parts: "<< shape.num_parts()
                          << std::endl << "pixel position of first part:  "
                          << shape.part(0)
                          << std::endl << "pixel position of second part: "
                          << shape.part(1) << std::endl;
                // You get the idea, you can get all the face part locations if
                // you want them.  Here we just store them in shapes so we can
                // put them on the screen.
                shapes.push_back(shape);
            }

            // Now lets view our face poses on the screen.
            win.clear_overlay();
            win.set_image(img);
            win.add_overlay(render_face_detections(shapes));

            std::cout << "Hit enter to process the next image..." << std::endl;
            std::cin.get();
        }
    }
    catch (std::exception& e)
    {
        std::cout << "\nexception thrown!" << std::endl;
        std::cout << e.what() << std::endl;
    }
}
