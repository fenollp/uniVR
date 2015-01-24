#include "nvr.hh"

int
main (int argc, const char* argv[]) {
    try {
        if (argc != 2) {
            std::cout << "Call this program like this:" << std::endl
                      << "./$0 68_face_landmarks.dat" << std::endl;
            return 1;
        }
        std::string trained(argv[1]);
        nvr::UniVR ovr;
        ovr.init(trained);
        nvr::data face;
        while (true) { // GAME LOOP
            if (!ovr.step(face))
                break;
            std::cout << face;//
            if (cv::waitKey(5) == 'q')
                break;
        }
    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
    }
}
