#include "nvr.hh"

int
main (int argc, const char* argv[]) {
    try {
        if (argc != 3) {
            std::cout << "Call this program like this:" << std::endl
                      << "./$0 68_face_landmarks.dat video.mp4" << std::endl;
            return 1;
        }
        std::string trained(argv[1]);
        nvr::UniVR ovr;
        auto video_opener = [&](nvr::FrameStream& capture) {
            return capture.open(argv[2]) && capture.isOpened();
        };
        ovr.init(trained, video_opener);
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
