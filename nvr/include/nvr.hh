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
        //FIXME
    } data; //FIXME

    std::ostream& operator<< (std::ostream& ostr, data& rhs);


    typedef cv::VideoCapture FrameStream;
    typedef cv::Mat          Frame;

    typedef dlib::full_object_detection Landmarks;


    static constexpr double SMOOTHING = 0.000000001;
    static constexpr size_t DROP_AMOUNT = 10; //5
    static constexpr size_t BACKLOG_SZ = 3;


    class UniVR {
    private:
        dlib::frontal_face_detector detector_;  // HoG face detector
        dlib::shape_predictor       extractor_; // Landmarks extractor
        FrameStream capture_; // Stream from webcam
        Frame       frame_;   // Frame from webcam
        dlib::array2d<dlib::rgb_pixel> img_; // Actual input image
        std::deque<Landmarks> shapes_;
        size_t I, Ds;

    public:
        UniVR (const std::string& trained_data);
        ~UniVR ();
        bool step (data& face);
    protected:
        bool open_capture ();
        bool next_frame ();
    };

    std::ostream& operator<< (std::ostream& ostr, UniVR& rhs);

} // namespace nvr

#endif /* !NVR_HH */
