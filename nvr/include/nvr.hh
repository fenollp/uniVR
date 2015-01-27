#ifndef NVR_HH
# define NVR_HH

# include <opencv2/opencv.hpp>
# include <opencv2/core/core.hpp>
# include <opencv2/highgui/highgui.hpp>

# include <dlib/opencv.h> // Right after OpenCV's includes
# include <dlib/image_processing/frontal_face_detector.h>
# include <dlib/image_processing/render_face_detections.h>
# include <dlib/image_processing.h>
# include <dlib/image_io.h>

# include <cmath>
# include <iostream>

namespace nvr {

# define HEAD_HIST_SZ_ 5
    /// Data exchanged with the 3rd-party application
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
    } data;

    std::ostream& operator<< (std::ostream& o, const data& rhs);

    /// Redefine the following types and capture_opener (in init/2)
    ///  so as to use your own video capturing technology

    // Somewhat public types
    typedef cv::VideoCapture FrameStream;
    typedef cv::Mat          Frame;

    // Somewhat private types
    typedef dlib::full_object_detection Landmarks;
    typedef std::deque<Landmarks>       Faces;


    /// Heuristics on input data and its processing

    static constexpr double SMOOTHING = 0.000000001;
    static constexpr size_t DROP_AMOUNT = 10; //5
    static constexpr size_t BACKLOG_SZ = 3;

# define WINWIDTH  640 // Try 1280x720
# define WINHEIGHT 480
    static constexpr size_t HEAD_HIST_SZ = HEAD_HIST_SZ_;
    // Number of graduations per pixel (horizontal)
    static constexpr double HGPP = 53.0 / (1.0*WINWIDTH);
    // Number of graduations per pixel (vertical)
    static constexpr double VGPP = 40.0 / (1.0*WINHEIGHT);
    static constexpr double PI180 = 3.141592654 / 180;
    static constexpr double MEAN_HEAD_WIDTH = 0.12; // 12cm

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


    class UniVR {
    private:
        FrameStream capture_; // Stream from webcam
        Frame       frame_;   // Frame from webcam
        dlib::frontal_face_detector detector_;  // HoG face detector
        dlib::shape_predictor       extractor_; // Landmarks extractor
        dlib::array2d<dlib::rgb_pixel> img_; // dlib's input image
        dlib::rectangle rect_found_; // ≈ zones_.last()
        std::deque<Frame> rects_found_; // Frames of past rect_found_s
        std::deque<dlib::rectangle> zones_; // Last BACKLOG_SZ zones detected
        size_t I_, Ds_; // I_: counter to drop detections
        bool inited_; // Set to true after a call to init/1
        int rc_, rr_; // Ratio of camera frame over pyramied-down img

    public:
        UniVR ();
        ~UniVR ();
        /// init/1,2: builds the capture & loads trained landmarks
        void init (const std::string& trained_data);
        void init (const std::string& trained_data,
                   std::function<bool(FrameStream&)> capture_opener);
        /// step/1: calls next_frame/0 for new data then collect_data/3 &
        ///  updates face with newly processed data
        bool step (data& face);
    protected:
        bool next_frame (); // Extracts new frame from the capture device
    private:
        dlib::rectangle scaled (const dlib::rectangle& r);
        dlib::point     scaled (const dlib::point& p);
    private:
        int norm (const Landmarks& face, int part1, int part2);
        double angle (const Landmarks& face,
                      int part1, int part2, int Part1, int Part2);
        /// Does all the math to extract new data
        void collect_data (data& data, const Landmarks& face,
                           const dlib::rectangle& face_zone);

    };

} // namespace nvr

#endif /* !NVR_HH */
