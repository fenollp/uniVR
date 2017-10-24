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
                      << " <$(git rev-parse --short HEAD)>"
                      << " <${$(git show --no-patch --format=%ci $commit)%%-*}>"
                      << " <$(hostname -f)>"
                      << std::endl;
            return 1;
        }
        auto ldmrks = nvr::LANDMARKS_DAT;
        auto video = argv[1];
        auto vid = argv[2];
        auto gvv = argv[3];
        auto gv = argv[4];
        auto gdate = argv[5];
        auto fqdn = argv[6];

        DEV << '{' << std::endl
            << "\"version\": 2," << std::endl
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

        auto video_opener = [&](nvr::FrameStream& capture) {
            return capture.open(video) && capture.isOpened();
        };
        nvr::UniVR ovr;
        ovr.init(video_opener);

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

            const auto& face_box_t = ovr.face_zone_top();
            const auto& face_box_b = ovr.face_zone_bottom();
            const auto& face_box_l = ovr.face_zone_left();
            const auto& face_box_r = ovr.face_zone_right();
            const auto& face_box_w = ovr.face_zone_width();
            const auto& face_box_h = ovr.face_zone_height();
            const auto& face_box_a = ovr.face_zone_area();
            const auto& face_box_e = ovr.face_zone_is_empty();

            const auto& mgi_whole = ovr.MGI_whole_img();
            const auto& mgi_whole_hz = ovr.MGI_horizontal_whole_img();
            const auto& mgi_whole_lr = ovr.MGI_left_right_difference_whole_img();
            const auto& mgi_face = ovr.MGI_face_img();
            const auto& mgi_face_hz = ovr.MGI_horizontal_face_img();
            const auto& mgi_face_lr = ovr.MGI_left_right_difference_face_img();

            DEV << '"' << i++ << "\":{"
                <<   "\"nanos\":" << t.count() << ',' << std::endl
                <<   "\"face\":" << face << std::endl
                <<   ',' << std::flush

                <<   "\"face_box\": {"
                <<     "\"t\": " << face_box_t << ','
                <<     "\"b\": " << face_box_b << ','
                <<     "\"l\": " << face_box_l << ','
                <<     "\"r\": " << face_box_r << ','
                <<     "\"w\": " << face_box_w << ','
                <<     "\"h\": " << face_box_h << ','
                <<     "\"a\": " << face_box_a << ','
                <<     "\"e\": " << face_box_e
                <<   "}," << std::flush

                <<   "\"mgi\": {"
                <<     "\"whole\": " << mgi_whole << ','
                <<     "\"whole_hz\": " << mgi_whole_hz << ','
                <<     "\"whole_lr\": " << mgi_whole_lr << ','
                <<     "\"face\": " << mgi_face << ','
                <<     "\"face_hz\": " << mgi_face_hz << ','
                <<     "\"face_lr\": " << mgi_face_lr
                <<   "}," << std::flush

                <<   "\"ldmrks\": {" << std::endl
                <<     "\"file\": \"" << ldmrks << '"' << ',' << std::endl
                <<     "\"count\": " << LANDMARKS_COUNT << ',' << std::endl
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
                <<   '}' << std::flush; // Closes "ldmrks"

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
