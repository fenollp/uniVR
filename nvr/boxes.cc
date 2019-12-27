#include "mediapipe/framework/formats/detection.pb.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/formats/rect.pb.h"
#include "mediapipe/framework/port/commandlineflags.h"
#include "mediapipe/framework/port/file_helpers.h"
#include "mediapipe/framework/port/opencv_highgui_inc.h"
#include "mediapipe/framework/port/opencv_imgproc_inc.h"
#include "mediapipe/framework/port/opencv_video_inc.h"
#include "mediapipe/framework/port/parse_text_proto.h"

#if !defined(MEDIAPIPE_DISABLE_GPU)
constexpr char kGraph[] = "nvr/boxes_gpu.pbtxt";
#else
constexpr char kGraph[] = "nvr/boxes_cpu.pbtxt";
#endif
#include "mediapipe_xpu.h"

DEFINE_string(input_video_path, "", "Full path of video to load.");
DEFINE_bool(without_window, false, "Do not setup opencv window.");

::mediapipe::Status RunMPPGraph() {
  std::string pbtxt;
  MP_RETURN_IF_ERROR(mediapipe::file::GetContents(kGraph, &pbtxt));
  auto config =
      mediapipe::ParseTextProtoOrDie<mediapipe::CalculatorGraphConfig>(pbtxt);
  LOG(INFO) << "Initialize the calculator graph.";
  std::string windowName;
  if (!FLAGS_without_window) windowName = "Gust.show's rocketleague";
  bool window_was_closed = false;
  std::map<std::string, ::mediapipe::Packet> input_side_packets = {
      {"window_name", ::mediapipe::MakePacket<std::string>(windowName)},
      {"window_was_closed", ::mediapipe::MakePacket<bool*>(&window_was_closed)},
  };
  mediapipe::CalculatorGraph graph;
  MP_RETURN_IF_ERROR(graph.Initialize(config, input_side_packets));
  MAYBE_INIT_GPU(graph);

  LOG(INFO) << "Load the video.";
  cv::VideoCapture capture;
  const bool load_video = !FLAGS_input_video_path.empty();
  if (load_video) {
    capture.open(FLAGS_input_video_path);
    capture.set(cv::CAP_PROP_FPS, 2);
  } else {
    capture.open(0);
  }
  RET_CHECK(capture.isOpened());

  LOG(INFO) << "Start running the calculator graph.";
  MP_RETURN_IF_ERROR(graph.StartRun({}));

  LOG(INFO) << "Start grabbing and processing frames.";
  size_t frame_timestamp = 0;
  while (!window_was_closed) {
    cv::Mat camera_frame_raw;
    capture >> camera_frame_raw;
    if (camera_frame_raw.empty()) {
      LOG(INFO) << "EOV";
      break;
    }
    cv::Mat input_frame;
    cv::cvtColor(camera_frame_raw, input_frame, cv::COLOR_BGR2RGB);
    if (!load_video) {
      cv::flip(input_frame, input_frame, /*flipcode=HORIZONTAL*/ 1);
    }

    auto ts = mediapipe::Timestamp(frame_timestamp++);
    ADD_INPUT_FRAME("input_frame", input_frame, ts);
  }

  LOG(INFO) << "Shutting down.";
  MP_RETURN_IF_ERROR(graph.CloseAllInputStreams());
  return graph.WaitUntilDone();
}

int main(int argc, char** argv) {
  google::InitGoogleLogging(argv[0]);
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  ::mediapipe::Status run_status = RunMPPGraph();
  if (!run_status.ok()) {
    LOG(ERROR) << "Failed to run the graph: " << run_status.message() << " !!";
  } else {
    LOG(INFO) << "Success!";
  }
  return 0;
}
