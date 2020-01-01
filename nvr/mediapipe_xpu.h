#pragma once

#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/port/status.h"
#if !defined(MEDIAPIPE_DISABLE_GPU)
#include "mediapipe/gpu/gl_calculator_helper.h"
#include "mediapipe/gpu/gpu_buffer.h"
#include "mediapipe/gpu/gpu_shared_data_internal.h"
#endif

// MAYBE_INIT_GPU
#if !defined(MEDIAPIPE_DISABLE_GPU)
#define MAYBE_INIT_GPU(graph)                                              \
  LOG(INFO) << "Initialize the GPU.";                                      \
  ASSIGN_OR_RETURN(auto gpu_resources, mediapipe::GpuResources::Create()); \
  MP_RETURN_IF_ERROR(graph.SetGpuResources(std::move(gpu_resources)));     \
  mediapipe::GlCalculatorHelper gpu_helper;                                \
  gpu_helper.InitializeForTest(graph.GetGpuResources().get())
#else  //  !MEDIAPIPE_DISABLE_GPU
#define MAYBE_INIT_GPU(graph) LOG(INFO) << "Not built for GPU."
#endif

// ADD_INPUT_FRAME

#if !defined(MEDIAPIPE_DISABLE_GPU)
#define ADD_INPUT_FRAME(inputStream, captured, timestamp)                      \
  auto the_input_frame = absl::make_unique<mediapipe::ImageFrame>(             \
      mediapipe::ImageFormat::SRGB, captured.cols, captured.rows,              \
      mediapipe::ImageFrame::kGlDefaultAlignmentBoundary);                     \
  cv::Mat input_frame_mat =                                                    \
      mediapipe::formats::MatView(the_input_frame.get());                      \
  captured.copyTo(input_frame_mat);                                            \
  /* Send image packet into the graph. */                                      \
  MP_RETURN_IF_ERROR(                                                          \
      gpu_helper.RunInGlContext([&the_input_frame, &timestamp, &graph,         \
                                 &gpu_helper]() -> ::mediapipe::Status {       \
        /* Convert ImageFrame to GpuBuffer. */                                 \
        auto texture = gpu_helper.CreateSourceTexture(*the_input_frame.get()); \
        auto gpu_frame = texture.GetFrame<mediapipe::GpuBuffer>();             \
        glFlush();                                                             \
        texture.Release();                                                     \
        /* Send GPU image packet into the graph. */                            \
        MP_RETURN_IF_ERROR(graph.AddPacketToInputStream(                       \
            inputStream,                                                       \
            mediapipe::Adopt(gpu_frame.release()).At(timestamp)));             \
        return ::mediapipe::OkStatus();                                        \
      }))
#else  //  !MEDIAPIPE_DISABLE_GPU
#define ADD_INPUT_FRAME(inputStream, captured, timestamp)          \
  auto the_input_frame = absl::make_unique<mediapipe::ImageFrame>( \
      mediapipe::ImageFormat::SRGB, captured.cols, captured.rows,  \
      mediapipe::ImageFrame::kDefaultAlignmentBoundary);           \
  cv::Mat input_frame_mat =                                        \
      mediapipe::formats::MatView(the_input_frame.get());          \
  captured.copyTo(input_frame_mat);                                \
  /* Send image packet into the graph. */                          \
  MP_RETURN_IF_ERROR(graph.AddPacketToInputStream(                 \
      inputStream, mediapipe::Adopt(the_input_frame.release()).At(timestamp)))
#endif

// GET_OUTPUT_FRAME_MAT

#if !defined(MEDIAPIPE_DISABLE_GPU)
#define GET_OUTPUT_FRAME_MAT(packet, ofmat)                                    \
  std::unique_ptr<mediapipe::ImageFrame> output_frame;                         \
  MP_RETURN_IF_ERROR(gpu_helper.RunInGlContext(                                \
      [&packet, &output_frame, &gpu_helper]() -> ::mediapipe::Status {         \
        auto& gpu_frame = packet.Get<mediapipe::GpuBuffer>();                  \
        auto texture = gpu_helper.CreateSourceTexture(gpu_frame);              \
        output_frame = absl::make_unique<mediapipe::ImageFrame>(               \
            mediapipe::ImageFormatForGpuBufferFormat(gpu_frame.format()),      \
            gpu_frame.width(), gpu_frame.height(),                             \
            mediapipe::ImageFrame::kGlDefaultAlignmentBoundary);               \
        gpu_helper.BindFramebuffer(texture);                                   \
        const auto info =                                                      \
            mediapipe::GlTextureInfoForGpuBufferFormat(gpu_frame.format(), 0); \
        glReadPixels(0, 0, texture.width(), texture.height(), info.gl_format,  \
                     info.gl_type, output_frame->MutablePixelData());          \
        glFlush();                                                             \
        texture.Release();                                                     \
        return ::mediapipe::OkStatus();                                        \
      }));                                                                     \
  cv::Mat ofmat = mediapipe::formats::MatView(output_frame.get());             \
  cv::cvtColor(ofmat, ofmat, cv::COLOR_RGB2BGR)
#else  //  !MEDIAPIPE_DISABLE_GPU
#define GET_OUTPUT_FRAME_MAT(packet, ofmat)                   \
  auto& output_frame = packet.Get<mediapipe::ImageFrame>();   \
  cv::Mat ofmat = mediapipe::formats::MatView(&output_frame); \
  cv::cvtColor(ofmat, ofmat, cv::COLOR_RGB2BGR)
#endif
