#include "nvr.hh"

int
main (int argc, const char* argv[]) {
    try {
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }

        std::string trained(argv[1]);
        nvr::UniVR univr(trained);

        nvr::data face;
        while (true) { // GAME LOOP
            if (!univr.step(face))
                break;

            std::cout << face;
        }
    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
    }
}
