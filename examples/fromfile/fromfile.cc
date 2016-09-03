#include <chrono>
#include "nvr.hh"

#define DEV std::cerr

int
main (int argc, const char* argv[]) {
    try {
        if (argc != (4 + 1)) {
            std::cout << "Call this program like this:" << std::endl
                      << "./$0 "
                      << " <path/to/video.mp4>"
                      << " <$(git describe --abbrev --dirty --always --tags)>"
                      << " <$(hostname -f)>"
                      << " <name of video.mp4>"
                      << std::endl;
            return 1;
        }
        auto ldmrks = "data/ldmrks68.dat";
        auto video = argv[1];
        auto gv = argv[2];
        auto fqdn = argv[3];
        auto vid = argv[4];

        DEV << '{' << std::endl
            << "\"vsn\": {" << std::endl
            <<   "\"gv\": \"" << gv << '"' << std::endl
            << "}," << std::endl
            << "\"machine\": {" << std::endl
            <<   "\"fqdn\": \"" << fqdn << '"' << std::endl
            << "}," << std::endl
            << "\"video\": {" << std::endl
            <<   "\"file\": \"" << vid << '"' << std::endl
            << "}," << std::endl
            << "\"data\": {" << std::endl;

        std::string trained(ldmrks);
        nvr::UniVR ovr;
        auto video_opener = [&](nvr::FrameStream& capture) {
            return capture.open(video) && capture.isOpened();
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
                DEV << ',';
            else
                is_first = false;

            DEV << '"' << i++ << "\":{"
                <<   "\"nanos\":" << t.count() << ','
                <<   "\"face\":" << face << ','
                <<   "\"ldmrks\": {"
                <<     "\"file\": \"" << ldmrks << '"' << ','
                <<     "\"count\": " << LANDMARKS_COUNT << ','
                <<     "\"data\": [";
            bool is_first_ldmrk = true;
            for (int l = 0; l < LANDMARKS_COUNT_XY; ++l) {
                if (!is_first_ldmrk)
                    DEV << ',';
                else
                    is_first_ldmrk = false;
                DEV << face.landmarks[l];
            }
            DEV <<     ']'
                <<   '}'; // Closes "ldmrks"

            DEV << '}' << std::endl; // Closes i
        }
        DEV << '}' << std::endl // Closes "data"
            << '}';

    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
        return 2;
    }

    return 0;
}
