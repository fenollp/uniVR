#include <chrono>
#include "nvr.hh"

int
main (int argc, const char* argv[]) {
    try {
        if (argc != (3 + 1)) {
            std::cout << "Call this program like this:" << std::endl
                      << "./$0 "
                      << " <$(git describe --abbrev --dirty --always --tags)>"
                      << " <$(hostname -f)>"
                      << " <video.mp4>"
                      << std::endl;
            return 1;
        }
        auto ldmrks = "data/ldmrks68.dat";
        auto gv = argv[1];
        auto fqdn = argv[2];
        auto vid = argv[3];

        std::cout << '{' << std::endl
                  << "\"vsn\":" << std::endl
                  << '{' << std::endl
                  <<   "\"gv\": \"" << gv << '"' << std::endl
                  << '}' << std::endl
                  << "\"machine\":" << std::endl
                  << '{' << std::endl
                  <<   "\"fqdn\": \"" << fqdn << '"' << std::endl
                  << '}' << std::endl
                  << "\"data\":" << std::endl
                  << '{' << std::endl;

        std::string trained(ldmrks);
        nvr::UniVR ovr;
        auto video_opener = [&](nvr::FrameStream& capture) {
            return capture.open(vid) && capture.isOpened();
        };
        ovr.init(trained, video_opener);

        nvr::data face;
        size_t i = 1;
        bool is_first = true;
        while (true) {
            auto s = std::chrono::steady_clock::now();
            bool ret = ovr.step(face);
            auto f = std::chrono::steady_clock::now();
            auto t = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);
            if (!ret)
                break;

            if (!is_first)
                std::cout << ',';
            else
                is_first = false;

            std::cout << "\"" << i++ << "\":{"
                      <<   "\"nanos\":" << t.count() << ','
                      <<   "\"face\":" << face
                      <<   "\"ldmrks\": {"
                      <<     "\"file\": \"" << ldmrks << '"' << ','
                      <<     "\"data\": {";
            bool is_first_ldmrk = true;
            for (int l = 0; l < 2 * LANDMARKS_COUNT; ++l) {
                if (!is_first_ldmrk)
                    std::cout << ',';
                else
                    is_first_ldmrk = false;
                std::cout << '"' << l << '"' << ':' << face.landmarks[l];
            }
            std::cout <<     '}'
                      <<   '}';

            for (int l = 0; l < LANDMARKS_COUNT * 2; ++l)
                std::cout << ',' << face.landmarks[l];
            std::cout << std::endl;

            std::cout << "}" << std::endl; // Closes i
        }
        std::cout << '}' << std::endl; // Closes "data"

    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
        return 2;
    }

    return 0;
}
