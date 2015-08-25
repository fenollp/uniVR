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
        size_t i = 0;
        while (true) { // GAME LOOP
            auto s = std::chrono::high_resolution_clock::now();
            bool ret = ovr.step(face);
            auto f = std::chrono::high_resolution_clock::now();
            auto t = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);
            if (!ret)
                break;

            std::cout << i++       << ','
                      << t.count() << ','
                      << face.gx   << ','
                      << face.gy   << ','
                      << face.chin << ','

                      << face.eyeX << ','
                      << face.eyeY << ','
                      << face.eyeZ << ','

                      << face.n << ','
                      << face.er << ','
                      << face.el << ','
                      << face.ar << ','
                      << face.al << ','
                      << face.das << ','
                      << face.w << ','
                      << face.h << ','
                      << face.headWidth << ','
                      << face.headHeight << ','
                      << face.upperHeadX << ','
                      << face.upperHeadY << ','
                      << face.headX << ','
                      << face.headY << ','
                      << face.headDist
                      << std::endl;

            if (cv::waitKey(5) == 'q')
                break;
        }

    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
        return 2;
    }

    return 0;
}
