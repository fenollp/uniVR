#include <utility>

#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/detection.pb.h"
#include "mediapipe/framework/formats/landmark.pb.h"
#include "mediapipe/framework/formats/location_data.pb.h"
#include "mediapipe/framework/port/logging.h"
#include "mediapipe/framework/port/status.h"

namespace mediapipe {

namespace {

constexpr char kDetectionsTag[] = "DETECTIONS";
constexpr char kNormLandmarksTag[] = "NORM_LANDMARKS";

typedef std::vector<Detection> Detections;

}  // namespace

class FaceDetectionsToNVRCalculator : public CalculatorBase {
 public:
  FaceDetectionsToNVRCalculator() = default;
  ~FaceDetectionsToNVRCalculator() override = default;

  static ::mediapipe::Status GetContract(CalculatorContract* cc) {
    RET_CHECK(cc->Inputs().HasTag(kDetectionsTag));
    cc->Inputs().Tag(kDetectionsTag).Set<Detections>();
    RET_CHECK(cc->Outputs().HasTag(kNormLandmarksTag));
    cc->Outputs().Tag(kNormLandmarksTag).Set<NormalizedLandmarkList>();
    return ::mediapipe::OkStatus();
  }

  ::mediapipe::Status Open(CalculatorContext* cc) override {
    cc->SetOffset(TimestampDiff(0));
    return ::mediapipe::OkStatus();
  }

  ::mediapipe::Status Process(CalculatorContext* cc) override {
    const auto& detections = cc->Inputs().Tag(kDetectionsTag).Get<Detections>();
    if (detections.empty()) return ::mediapipe::OkStatus();
    LOG(INFO) << "#detections: " << detections.size();

    int largest;
    auto face_width = std::numeric_limits<float>::min();
    auto face_height = std::numeric_limits<float>::min();
    for (int id = 0; id < detections.size(); ++id) {
      const auto& det = detections[id];
      const auto& loc = det.location_data();
      RET_CHECK_EQ(loc.format(), LocationData::RELATIVE_BOUNDING_BOX);
      const auto& rbb = loc.relative_bounding_box();
      if (rbb.width() > face_width && rbb.height() > face_height) {
        largest = id;
        LOG(INFO) << "detection[" << largest << "]: " << det.score(0);
      }
    }

    NormalizedLandmark landmark;
    {
      const auto& det = detections[largest];
      const auto& loc = det.location_data();
      const auto& rbb = loc.relative_bounding_box();
      LOG(INFO) << "rbb: " << rbb.DebugString();
      // const auto& rks = loc.relative_keypoints();
      // LOG(INFO) << "rks: " << rks.DebugString();

// #define VIEWPORT_WIDTH 640  // Try 1280x720
// #define VIEWPORT_HEIGHT 480
#define VIEWPORT_WIDTH 1
#define VIEWPORT_HEIGHT 1
      // Number of graduations per pixel (horizontal)
      static constexpr double HGPP = 53.0 / (1.0 * VIEWPORT_WIDTH);
      // Number of graduations per pixel (vertical)
      static constexpr double VGPP = 40.0 / (1.0 * VIEWPORT_HEIGHT);
      static constexpr double PI180 = 3.141592654 / 180;
      static constexpr double MEAN_HEAD_WIDTH = 0.12;  // 12cm

      double angle = rbb.width() * HGPP * PI180;
      double head_dist = (MEAN_HEAD_WIDTH / 2) / tan(angle / 2);  // in meters
      double xAngle = HGPP * PI180 * (rbb.xmin() + rbb.width() / 2);
      double yAngle = VGPP * PI180 * (rbb.ymin() + rbb.height() / 2);
      double headX = std::tan(xAngle) * head_dist;
      double headY = std::tan(yAngle) * head_dist;

      double normX = 3 * headX;  //(float) (( headX - 320)/320.0);
      double normY = 3 * headY;  //(float) (( headY - 240)/320.0);

      landmark.set_x(5 * normX);
      landmark.set_y(7 * normY);
      landmark.set_z(1 + 5 * head_dist);
    }
    LOG(INFO) << landmark.DebugString();

    auto nvr = absl::make_unique<NormalizedLandmarkList>();
    *nvr->add_landmark() = landmark;
    cc->Outputs()
        .Tag(kNormLandmarksTag)
        .Add(nvr.release(), cc->InputTimestamp());
    return ::mediapipe::OkStatus();
  }
};
REGISTER_CALCULATOR(FaceDetectionsToNVRCalculator);

}  // namespace mediapipe
