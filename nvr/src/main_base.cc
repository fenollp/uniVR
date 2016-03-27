#include "nvr.hh"

int
main (int argc, const char* argv[]) {
    try {
        std::string trained("data/ldmrks68.dat");
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
