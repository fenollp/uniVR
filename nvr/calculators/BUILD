cc_library(
    name = "opencv_window_calculator",
    srcs = ["opencv_window_calculator.cc"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image_frame",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "@mediapipe//mediapipe/framework/port:opencv_highgui",
        "@mediapipe//mediapipe/framework/port:opencv_imgproc",
        "@mediapipe//mediapipe/framework/port:opencv_video",
        "@mediapipe//mediapipe/framework/port:ret_check",
        "@mediapipe//mediapipe/framework/port:source_location",
        "@mediapipe//mediapipe/framework/port:status",
        "@mediapipe//mediapipe/framework/tool:status_util",
    ] + select({
        "@mediapipe//mediapipe/gpu:disable_gpu": [],
        "//conditions:default": [
            "@mediapipe//mediapipe/gpu:gl_calculator_helper",
            "@mediapipe//mediapipe/gpu:gl_simple_shaders",
            "@mediapipe//mediapipe/gpu:gl_quad_renderer",
            "@mediapipe//mediapipe/gpu:shader_util",
        ],
    }),
    alwayslink = 1,
)

cc_library(
    name = "face_detection_to_nvr_calculator",
    srcs = ["face_detection_to_nvr_calculator.cc"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:detection_cc_proto",
        "@mediapipe//mediapipe/framework/formats:landmark_cc_proto",
        "@mediapipe//mediapipe/framework/port:ret_check",
        "@mediapipe//mediapipe/framework/port:source_location",
        "@mediapipe//mediapipe/framework/port:status",
        "@mediapipe//mediapipe/framework/tool:status_util",
    ],
    alwayslink = 1,
)
