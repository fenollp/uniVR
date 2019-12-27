#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_highgui_inc.h"
#include "mediapipe/framework/port/opencv_imgproc_inc.h"
#include "mediapipe/framework/port/opencv_video_inc.h"
#include "mediapipe/framework/port/ret_check.h"
#include "mediapipe/framework/port/source_location.h"
#include "mediapipe/framework/port/status.h"
#include "mediapipe/framework/port/status_builder.h"
#include "mediapipe/framework/tool/status_util.h"

#if !defined(MEDIAPIPE_DISABLE_GPU)
#include "mediapipe/gpu/gl_calculator_helper.h"
#include "mediapipe/gpu/gl_simple_shaders.h"
#include "mediapipe/gpu/shader_util.h"
#endif  //  !MEDIAPIPE_DISABLE_GPU

namespace mediapipe {

namespace {

constexpr char kWindowName[] = "NAME";
constexpr char kClosed[] = "CLOSED";

}  // namespace

// Sends input image stream to an OpenCV window.
//
// Input side packets:
//   NAME: window name as an std::string. If empty, no window is created.
//   CLOSED: Optional bool* set to true when a key is pressed.
//
// Example config to output rendered frames to some window:
//
// node {
//   calculator: "AnnotationOverlayCalculator"
//   input_stream: "INPUT_FRAME_GPU:input_frame"
//   input_stream: "some_rect_render_data"
//   output_stream: "OUTPUT_FRAME_GPU:output_frame"
// }
//
// node {
//   calculator: "OpenCvWindowCalculator"
//   input_side_packet: "NAME:window_name"
//   input_side_packet: "CLOSED:window_was_closed"
//   input_stream: "output_frame"
// }
class OpenCvWindowCalculator : public CalculatorBase {
 public:
  static ::mediapipe::Status GetContract(CalculatorContract* cc);
  ::mediapipe::Status Open(CalculatorContext* cc) override;
  ::mediapipe::Status Process(CalculatorContext* cc) override;
  ::mediapipe::Status Close(CalculatorContext* cc) override;

 private:
  std::string name_;
  bool* closed_ = nullptr;
#if !defined(MEDIAPIPE_DISABLE_GPU)
  mediapipe::GlCalculatorHelper gpu_helper_;
#endif  // MEDIAPIPE_DISABLE_GPU
};
REGISTER_CALCULATOR(OpenCvWindowCalculator);

::mediapipe::Status OpenCvWindowCalculator::GetContract(
    CalculatorContract* cc) {
  RET_CHECK_EQ(cc->Inputs().NumEntries(), 1);
  RET_CHECK_EQ(cc->Outputs().NumEntries(), 0);
  RET_CHECK(cc->InputSidePackets().HasTag(kWindowName));
  cc->InputSidePackets().Tag(kWindowName).Set<std::string>();

  if (cc->InputSidePackets().HasTag(kClosed))
    cc->InputSidePackets().Tag(kClosed).Set<bool*>();

#if !defined(MEDIAPIPE_DISABLE_GPU)
  cc->Inputs().Index(0).Set<mediapipe::GpuBuffer>();
#else
  cc->Inputs().Index(0).Set<mediapipe::ImageFrame>();
#endif

#if !defined(MEDIAPIPE_DISABLE_GPU)
  MP_RETURN_IF_ERROR(mediapipe::GlCalculatorHelper::UpdateContract(cc));
#endif  //  !MEDIAPIPE_DISABLE_GPU
  return ::mediapipe::OkStatus();
}

::mediapipe::Status OpenCvWindowCalculator::Open(CalculatorContext* cc) {
  cc->SetOffset(TimestampDiff(0));

#if !defined(MEDIAPIPE_DISABLE_GPU)
  MP_RETURN_IF_ERROR(gpu_helper_.Open(cc));
  LOG(INFO) << "GPU set up!";
#endif  //  !MEDIAPIPE_DISABLE_GPU

  name_ = cc->InputSidePackets().Tag(kWindowName).Get<std::string>();
  if (!name_.empty()) cv::namedWindow(name_, cv::WINDOW_AUTOSIZE);

  if (cc->InputSidePackets().HasTag(kClosed))
    closed_ = cc->InputSidePackets().Tag(kClosed).Get<bool*>();

  return ::mediapipe::OkStatus();
}

::mediapipe::Status OpenCvWindowCalculator::Close(CalculatorContext* cc) {
  return ::mediapipe::OkStatus();
}

::mediapipe::Status OpenCvWindowCalculator::Process(CalculatorContext* cc) {
  auto& packet = cc->Inputs().Index(0);
  if (name_.empty() || packet.IsEmpty()) {
    return ::mediapipe::OkStatus();
  }

#if !defined(MEDIAPIPE_DISABLE_GPU)
  std::unique_ptr<mediapipe::ImageFrame> output_frame;
  MP_RETURN_IF_ERROR(gpu_helper_.RunInGlContext(
      [&packet, &output_frame, this]() -> ::mediapipe::Status {
        auto& gpu_frame = packet.Get<mediapipe::GpuBuffer>();
        auto texture = gpu_helper_.CreateSourceTexture(gpu_frame);
        output_frame = absl::make_unique<mediapipe::ImageFrame>(
            mediapipe::ImageFormatForGpuBufferFormat(gpu_frame.format()),
            gpu_frame.width(), gpu_frame.height(),
            mediapipe::ImageFrame::kGlDefaultAlignmentBoundary);
        gpu_helper_.BindFramebuffer(texture);
        const auto info =
            mediapipe::GlTextureInfoForGpuBufferFormat(gpu_frame.format(), 0);
        glReadPixels(0, 0, texture.width(), texture.height(), info.gl_format,
                     info.gl_type, output_frame->MutablePixelData());
        glFlush();
        texture.Release();
        return ::mediapipe::OkStatus();
      }));
  const auto format = output_frame->Format();
  cv::Mat ofmat = mediapipe::formats::MatView(output_frame.get());
#else  //  !MEDIAPIPE_DISABLE_GPU
  auto& output_frame = packet.Get<mediapipe::ImageFrame>();
  const auto format = output_frame.Format();
  cv::Mat ofmat = mediapipe::formats::MatView(&output_frame);
#endif
  if (format == ImageFormat::SRGB)
    cv::cvtColor(ofmat, ofmat, cv::COLOR_RGB2BGR);
  else if (format == ImageFormat::SRGBA)
    cv::cvtColor(ofmat, ofmat, cv::COLOR_RGBA2BGR);
  else if (format != ImageFormat::GRAY8)
    RET_CHECK(format == ImageFormat::GRAY8)
        << "format: " << format << " channels: " << ofmat.channels() << ", "
        << ofmat.cols << "x" << ofmat.rows;

  cv::imshow(name_, ofmat);
  const int pressed_key = cv::waitKey(1);
  if (closed_) *closed_ = pressed_key == 'q' || pressed_key == 27;

  return ::mediapipe::OkStatus();
}

}  // namespace mediapipe
