# load("@mediapipe//framework/tool:mediapipe_graph.bzl", "mediapipe_binary_graph")

cc_library(
    name = "mediapipe_xpu",
    hdrs = ["mediapipe_xpu.h"],
)

[
    [
        cc_binary(
            name = "boxes" + suffix,
            srcs = ["boxes.cc"],
            # data = [":boxes_graph" + suffix],
            deps = xpu_deps + [
                ":mediapipe_xpu",
                "//nvr/calculators:opencv_window_calculator",
                "//nvr/calculators:face_detection_to_nvr_calculator",
                "@mediapipe//mediapipe/calculators/util:landmarks_to_render_data_calculator",
                # ":boxes_graph" + suffix,
                "@mediapipe//mediapipe/framework/formats:image_frame",
                "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
                "@mediapipe//mediapipe/framework/formats:landmark_cc_proto",
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
                "@mediapipe//mediapipe/calculators/image:image_transformation_calculator",
                "@mediapipe//mediapipe/calculators/tflite:ssd_anchors_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_converter_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_inference_calculator",
                "@mediapipe//mediapipe/calculators/tflite:tflite_tensors_to_detections_calculator",
                "@mediapipe//mediapipe/calculators/util:detection_label_id_to_text_calculator",
                "@mediapipe//mediapipe/calculators/util:detection_letterbox_removal_calculator",
                "@mediapipe//mediapipe/calculators/util:non_max_suppression_calculator",
                "@mediapipe//mediapipe/calculators/core:packet_resampler_calculator",
                "@mediapipe//mediapipe/graphs/tracking/subgraphs:object_tracking",
                "@mediapipe//mediapipe/graphs/tracking/subgraphs:renderer_gpu",
                "@glfw",
                "@khronos_opengl_registry//:gl_headers",
            ],
        ),
    ]
    for suffix, xpu_deps in {
        "_cpu": [
            # Brings in GL headers & libs so we can get rid of GLEW
            "@mediapipe//mediapipe/gpu:gl_base",
        ],
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
