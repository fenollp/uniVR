#pragma once

extern "C"{
    extern int html5video_grabber_create();
    extern void html5video_grabber_init(int id, int w, int h, int framerate=-1);
    extern const char* html5video_grabber_pixel_format(int it);
    extern void html5video_grabber_set_pixel_format(int it, const char* format);
    extern int html5video_grabber_update(int id, int update_pixels, unsigned char* pixels);
    extern int html5video_grabber_texture_id(int id);
    extern int html5video_grabber_width(int id);
    extern int html5video_grabber_height(int id);
    extern int html5video_grabber_ready_state(int id);
}
