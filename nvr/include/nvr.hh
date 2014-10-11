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

    class UniVR {
    public:
        typedef cv::VideoCapture FrameStream;
        typedef cv::Mat Frame;
    private:
        typedef dlib::full_object_detection Landmarks;

    private:
        dlib::frontal_face_detector detector_; // HoG face detector
        dlib::shape_predictor extractor_; // Landmarks extractor
        FrameStream capture_; // Stream from webcam
        Frame       frame_;   // Frame from webcam
        dlib::array2d<dlib::rgb_pixel> img_; // Actual input image
        std::deque<Landmarks> shapes_;
        size_t I, Ds;

    private:
        static constexpr double SMOOTHING = 0.000000001;
        static constexpr size_t DROP_AMOUNT = 10; //5
        static constexpr size_t BACKLOG_SZ = 3;

    public:
        UniVR (const std::string& trained_data);
        ~UniVR ();

    public:
        bool step (data& face);
        bool open_capture ();
        bool next_frame ();

    private:
        void
        rectangle (Frame& img, const dlib::rectangle& rect,
                   size_t thickness);

        void
        dot (Frame& img, const dlib::point& p, size_t thickness);

        void
        dots (Frame& img, const Landmarks& face,
              size_t thickness);

        void
        text (Frame& img, size_t pos, const std::string& str);

        void
        textr (Frame& img, size_t pos, const std::string& str);

        dlib::rectangle
        biggest_rectangle (const std::vector<dlib::rectangle>& rs);

        dlib::rectangle  // Get a square box centered on the nose
        head_hull (const Landmarks& face);

        size_t
        landmark_energy (size_t rows, size_t cols,
                         const std::deque<Landmarks>& faces);

        bool
        find_movement (const Frame& motion,
                       std::vector<dlib::rectangle>& found);

        int
        norm (const Landmarks& face,
              int part1, int part2);

        double
        angle (const Landmarks& face,
               int part1, int part2, int Part1, int Part2);
    };

    std::ostream& operator<< (std::ostream& ostr, UniVR& rhs);

} // namespace nvr

#endif /* !NVR_HH */
