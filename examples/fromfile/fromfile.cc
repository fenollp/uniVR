#include <chrono>
#include "nvr.hh"

#define DEV std::cerr

int
main (int argc, const char* argv[]) {
    try {
        if (argc != (6 + 1)) {
            std::cout << "Call this program like this:" << std::endl
                      << "./$0 "
                      << " <path/to/video.mp4>"
                      << " <name of video.mp4>"
                      << " <$(git describe --abbrev --dirty --always --tags)>"
                      << " <$(git describe --abbrev --always)>"
                      << " <${$(git show --no-patch --format=%ci $commit)%%-*}>"
                      << " <$(hostname -f)>"
                      << std::endl;
            return 1;
        }
        auto ldmrks = "data/ldmrks68.dat";
        auto video = argv[1];
        auto vid = argv[2];
        auto gvv = argv[3];
        auto gv = argv[4];
        auto gdate = argv[5];
        auto fqdn = argv[6];

        DEV << '{' << std::endl
            << "\"vsn\": {" << std::endl
            <<   "\"gvv\": \"" << gvv << '"' << ',' << std::endl
            <<   "\"gv\": \"" << gv << '"' << ',' << std::endl
            <<   "\"gdate\": \"" << gdate << '"' << std::endl
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
