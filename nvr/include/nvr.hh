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

    typedef struct {
        size_t n;
        size_t er, el;
        double ar, al, das;
        size_t chin;
        size_t ears;
        size_t gx, gy;
    } data;

    std::ostream& operator<< (std::ostream& o, const data& rhs);


    // Somewhat public types
    typedef cv::VideoCapture FrameStream;
    typedef cv::Mat          Frame;

    // Somewhat private types
    typedef dlib::full_object_detection Landmarks;
    typedef std::deque<Landmarks>       Faces;


    static constexpr double SMOOTHING = 0.000000001;
    static constexpr size_t DROP_AMOUNT = 10; //5
    static constexpr size_t BACKLOG_SZ = 3;

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
        size_t I, Ds;
        bool inited;

    public:
        UniVR ();
        ~UniVR ();
        void init (const std::string& trained_data);
        bool step (data& face);
    protected:
        bool open_capture ();
        bool next_frame ();
        int motion_energy (const dlib::rectangle& rect_found);
    private:
        dlib::rectangle scaled (const dlib::rectangle& r);
    };

} // namespace nvr

#endif /* !NVR_HH */
