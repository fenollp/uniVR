# load("@mediapipe//framework/tool:mediapipe_graph.bzl", "mediapipe_binary_graph")

cc_library(
    name = "mediapipe_xpu",
    hdrs = ["mediapipe_xpu.h"],
)

cc_library(
    name = "opencv_window_calculator",
    srcs = ["opencv_window_calculator.cc"],
    # visibility = ["//visibility:public"],
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

[
    [
        cc_binary(
            name = "boxes" + suffix,
            srcs = ["boxes.cc"],
            # data = [":boxes_graph" + suffix],
            deps = xpu_deps + [
                ":mediapipe_xpu",
                ":opencv_window_calculator",
                # ":boxes_graph" + suffix,
                "@mediapipe//mediapipe/framework/formats:classification_cc_proto",
                "@mediapipe//mediapipe/framework/formats:detection_cc_proto",
                "@mediapipe//mediapipe/framework/formats:image_frame",
                "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
                "@mediapipe//mediapipe/framework/formats:landmark_cc_proto",
                "@mediapipe//mediapipe/framework/formats:rect_cc_proto",
                "@mediapipe//mediapipe/framework/port:commandlineflags",
                "@mediapipe//mediapipe/framework/port:file_helpers",
                "@mediapipe//mediapipe/framework/port:opencv_highgui",
                "@mediapipe//mediapipe/framework/port:opencv_imgproc",
                "@mediapipe//mediapipe/framework/port:opencv_video",
                "@mediapipe//mediapipe/framework/port:parse_text_proto",
                "@mediapipe//mediapipe/framework/port:status",
                "@mediapipe//mediapipe/framework:calculator_framework",
                #     ],
                # ),
                # mediapipe_binary_graph(
                #     name = "boxes_graph" + suffix,
                #     graph = "boxes" + suffix + ".pbtxt",
                #     output_name = "boxes" + suffix + ".binarypb",
                #     deps = [
                "@mediapipe//mediapipe/calculators/core:flow_limiter_calculator",
                "@mediapipe//mediapipe/calculators/image:image_transformation_calculator",
                "@mediapipe//mediapipe/calculators/tflite:ssd_anchors_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_converter_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_inference_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_tensors_to_detections_calculator",
                "@mediapipe//mediapipe/calculators/util:annotation_overlay_calculator",
                "@mediapipe//mediapipe/calculators/util:detection_label_id_to_text_calculator",
                "@mediapipe//mediapipe/calculators/util:detection_letterbox_removal_calculator",
                "@mediapipe//mediapipe/calculators/util:detections_to_render_data_calculator",
                "@mediapipe//mediapipe/calculators/util:non_max_suppression_calculator",
            ],
        ),
    ]
    for suffix, xpu_deps in {
        "_cpu": [],
        "_gpu": [
            # Linux only.
            # Must have a GPU with EGL support:
            # ex: sudo aptitude install mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev
            # (or similar nvidia/amd equivalent)
            "@mediapipe//mediapipe/gpu:gl_calculator_helper",
            "@mediapipe//mediapipe/gpu:gpu_buffer",
            "@mediapipe//mediapipe/gpu:gpu_shared_data_internal",
        ],
    }.items()
]
