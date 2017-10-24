#include <emscripten.h>
#include "nvr.hh"

nvr::UniVR ovr;
nvr::data  data;


void
step () {
    ovr.step(data);
    // printf("X %lf\tY %lf\tZ %lf\n", data.eyeX,data.eyeY,data.eyeZ);
}

int
main (int argc, char *argv[]) {
    auto cap_opener = [](int& id) {
        id = html5video_grabber_create();
        std::cout << "id " << id << std::endl;
        int desiredFrameRate = -1;
        html5video_grabber_init(id, 1280, 720, desiredFrameRate);
        std::cout << "init" << std::endl;
        std::string format = html5video_grabber_pixel_format(id);
        std::cout << "format " << format << std::endl;
        int readyState = html5video_grabber_ready_state(id);
        std::cout << "readyState " << readyState << std::endl;
        return 0 == readyState;
    };
    ovr.init(cap_opener);

    int fps = -1;
    bool simulate_infinite_loop = true;
    emscripten_set_main_loop(step, fps, simulate_infinite_loop);
    std::cout << "out of the loop" << std::endl;

    return 0;
}
