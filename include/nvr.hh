#ifndef NVR_HH
# define NVR_HH

# include <cmath>
# include <iostream>

# ifdef __EMSCRIPTEN__
#  undef window_debug
#  include "emscripten/html5video.h"
//TODO: get around this maybe? Or find actual sensible maximal values
#  define FRAME_ROWS_ 720
#  define FRAME_COLS_ 1280
# else
#  include <opencv2/opencv.hpp>
#  include <opencv2/core/core.hpp>
#  include <opencv2/highgui/highgui.hpp>

#  include <dlib/opencv.h> // Right after OpenCV's includes
# endif

# include <dlib/image_processing/frontal_face_detector.h>
# include <dlib/image_processing/render_face_detections.h>
# include <dlib/image_processing.h>
# include <dlib/image_io.h>

namespace nvr {

# define LANDMARKS_COUNT 68
# if LANDMARKS_COUNT == 68
    /// For a 68-landmarks extractor: different points of interest
    static constexpr size_t LANDMARK_NT = 27;  // Nose
    static constexpr size_t LANDMARK_NB = 30;
    static constexpr size_t LANDMARK_LER = 42; // Left eye
    static constexpr size_t LANDMARK_LEL = 45;
    static constexpr size_t LANDMARK_RER = 36; // Right eye
    static constexpr size_t LANDMARK_REL = 39;
    static constexpr size_t LANDMARK_CL = 9; // Chin
    static constexpr size_t LANDMARK_CR = 7;
    static constexpr size_t LANDMARK_JL = 16; // Jaw
    static constexpr size_t LANDMARK_JR = 0;
# endif

# define HEAD_HIST_SZ_ 5
    /// Data exchanged with the 3rd-party application
    //MUST keep operator<< up to date with struct data
    typedef struct {
        size_t n;
        size_t er, el;
        double ar, al, das;
        size_t chin;
        size_t ears;
        size_t gx, gy;
        size_t w, h;
        // --
        int headWidth, headHeight;
        int upperHeadX, upperHeadY;
        // --
        double headX, headY, headDist;
        double headHist[HEAD_HIST_SZ_];
        // --
        double eyeX, eyeY, eyeZ;
        // --
        int landmarks[LANDMARKS_COUNT * 2];
    } data;
    //MUST keep operator<< up to date with struct data
    std::ostream& operator<< (std::ostream& o, const data& rhs);

    /// Redefine the following types and capture_opener (in init/2)
    ///  so as to use your own video capturing technology

    // Somewhat public types
# ifdef __EMSCRIPTEN__
    typedef int FrameStream;
    typedef uint8_t Pixel;
    typedef Pixel* Frame;
# else
    typedef cv::VideoCapture FrameStream;
    typedef cv::Mat          Frame;
# endif

    // Somewhat private types
    typedef dlib::full_object_detection Landmarks;
    typedef std::deque<Landmarks>       Faces;


    /// Heuristics on input data and its processing

    static constexpr double SMOOTHING = 0.000000001;
    static constexpr size_t DROP_AMOUNT = 10; //5
    static constexpr size_t BACKLOG_SZ = 3;

# define VIEW_WINDOW_WIDTH  640 // Try 1280x720
# define VIEW_WINDOW_HEIGHT 480
    static constexpr size_t HEAD_HIST_SZ = HEAD_HIST_SZ_;
    // Number of graduations per pixel (horizontal)
    static constexpr double HGPP = 53.0 / (1.0 * VIEW_WINDOW_WIDTH);
    // Number of graduations per pixel (vertical)
    static constexpr double VGPP = 40.0 / (1.0 * VIEW_WINDOW_HEIGHT);
    static constexpr double PI180 = 3.141592654 / 180;
    static constexpr double MEAN_HEAD_WIDTH = 0.12; // 12cm


    class UniVR {
    private:
        int frame_rows_;
        int frame_cols_;
        FrameStream capture_; // Stream from webcam
# ifndef __EMSCRIPTEN__
        Frame       frame_;   // Frame from webcam
# else
        Pixel       frame_[FRAME_ROWS_ * FRAME_COLS_ * 3];
# endif
        dlib::frontal_face_detector detector_;  // HoG face detector
        dlib::correlation_tracker   tracker_;   // Track the face found with HoG
        dlib::shape_predictor       extractor_; // Landmarks extractor
        dlib::array2d<dlib::rgb_pixel> img_; // dlib's input image
        dlib::rectangle rect_found_; // ≈ zones_.last()
        std::deque<Frame> rects_found_; // Frames of past rect_found_s
        std::deque<dlib::rectangle> zones_; // Last BACKLOG_SZ zones detected
        size_t I_, Ds_; // I_: counter to drop detections
        bool inited_; // Set to true after a call to init/1
        int rc_, rr_; // Ratio of camera frame over pyramied-down img
        bool detected_; // Whether detector_ successfully found something for tracker_

    public:
        UniVR ();
        ~UniVR ();
        /// init/1,2: builds the capture & loads trained landmarks
        void init (const std::string& trained_data,
                   std::function<bool(FrameStream&)> capture_opener);
#ifndef __EMSCRIPTEN__
        void init (const std::string& trained_data);
#endif
        /// step/1: calls next_frame/0 for new data then collect_data/3 &
        ///  updates face with newly processed data
        bool step (data& face);
        void detect_now (); // Force face detection then branches into detect_then_track/0
    private:
        bool next_frame (); // Extracts new frame from the capture device
        void maybe_update_rows_cols (); // Maybe downscale & update rr_ & rc_
    private:
        dlib::rectangle scaled (const dlib::rectangle& r);
        dlib::point     scaled (const dlib::point& p);
    private:
        int norm (const Landmarks& face, int part1, int part2);
        double angle (const Landmarks& face,
                      int part1, int part2, int Part1, int Part2);
        void detect_then_track ();
        /// Does all the math to extract new data
        void collect_data (data& data, const Landmarks& face,
                           const dlib::rectangle& face_zone);

    };

} // namespace nvr

#endif /* !NVR_HH */
