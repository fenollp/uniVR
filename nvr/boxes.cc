#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/formats/landmark.pb.h"
#include "mediapipe/framework/port/commandlineflags.h"
#include "mediapipe/framework/port/file_helpers.h"
#include "mediapipe/framework/port/opencv_highgui_inc.h"
#include "mediapipe/framework/port/opencv_imgproc_inc.h"
#include "mediapipe/framework/port/opencv_video_inc.h"
#include "mediapipe/framework/port/parse_text_proto.h"

#if defined(MEDIAPIPE_DISABLE_GPU)
#include "mediapipe/gpu/gl_base.h"  // Finds OpenGL headers
#endif

#include "GLFW/glfw3.h"

#define GRAPHS "nvr/graphs/"
#if !defined(MEDIAPIPE_DISABLE_GPU)
constexpr char kGraph[] = GRAPHS "boxes_gpu.pbtxt";
#else
constexpr char kGraph[] = GRAPHS "boxes_cpu.pbtxt";
#endif
#include "mediapipe_xpu.h"

DEFINE_string(input_video_path, "", "Full path of video to load.");
DEFINE_bool(without_window, false, "Do not setup opencv window.");

static const std::string fragmentShaderCode = R"(
#version 330 core

// Interpolated values from the vertex shaders
in vec3 fragmentColor;

// Ouput data
out vec3 color;

void main(){

  // Output color = color specified in the vertex shader,
  // interpolated between all 3 surrounding vertices
  color = fragmentColor;

}
)";

static const std::string vertexShaderCode = R"(
#version 330 core

// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec3 vertexColor;

// Output data ; will be interpolated for each fragment.
out vec3 fragmentColor;
// Values that stay constant for the whole mesh.
uniform mat4 MVP;

void main(){

  // Output position of the vertex, in clip space : MVP * position
  gl_Position =  MVP * vec4(vertexPosition_modelspace,1);

  // The color of each vertex will be interpolated
  // to produce the color of each fragment
  fragmentColor = vertexColor;
}
)";

::mediapipe::NormalizedLandmarkList nvr;

constexpr char wName[] = "boxes";
constexpr int wWidth = 1024;
constexpr int wHeight = 768;

constexpr int max_samples_count = 5;
typedef std::deque<float> Floats;

GLuint LoadShaders() {
  GLuint VertexShaderID = glCreateShader(GL_VERTEX_SHADER);
  GLuint FragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

  GLint Result = GL_FALSE;
  int InfoLogLength;

  LOG(INFO) << "Compiling vertex shader";
  const char* vSrc = vertexShaderCode.c_str();
  glShaderSource(VertexShaderID, 1, (const GLchar**)&vSrc, NULL);
  glCompileShader(VertexShaderID);

  // Check Vertex Shader
  glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, &Result);
  glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
  if (InfoLogLength > 0) {
    std::vector<char> VertexShaderErrorMessage(InfoLogLength + 1);
    glGetShaderInfoLog(VertexShaderID, InfoLogLength, NULL,
                       &VertexShaderErrorMessage[0]);
    LOG(INFO) << &VertexShaderErrorMessage[0];
  }

  LOG(INFO) << "Compiling fragment shader";
  const char* fSrc = fragmentShaderCode.c_str();
  glShaderSource(FragmentShaderID, 1, (const GLchar**)&fSrc, NULL);
  glCompileShader(FragmentShaderID);

  // Check Fragment Shader
  glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, &Result);
  glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
  if (InfoLogLength > 0) {
    std::vector<char> FragmentShaderErrorMessage(InfoLogLength + 1);
    glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NULL,
                       &FragmentShaderErrorMessage[0]);
    LOG(INFO) << &FragmentShaderErrorMessage[0];
  }

  // Link the program
  LOG(INFO) << "Linking program";
  GLuint ProgramID = glCreateProgram();
  glAttachShader(ProgramID, VertexShaderID);
  glAttachShader(ProgramID, FragmentShaderID);
  glLinkProgram(ProgramID);

  // Check the program
  glGetProgramiv(ProgramID, GL_LINK_STATUS, &Result);
  glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
  if (InfoLogLength > 0) {
    std::vector<char> ProgramErrorMessage(InfoLogLength + 1);
    glGetProgramInfoLog(ProgramID, InfoLogLength, NULL,
                        &ProgramErrorMessage[0]);
    LOG(INFO) << &ProgramErrorMessage[0];
  }

  glDetachShader(ProgramID, VertexShaderID);
  glDetachShader(ProgramID, FragmentShaderID);

  glDeleteShader(VertexShaderID);
  glDeleteShader(FragmentShaderID);

  return ProgramID;
}

static void error_callback(int error, const char* description) {
  LOG(ERROR) << description;
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action,
                         int mods) {
  if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
    glfwSetWindowShouldClose(window, GL_TRUE);
}

float Mean(const Floats& xs) {
  return std::accumulate(xs.begin(), xs.end(), 0.0f) / xs.size();
}

::mediapipe::Status RunMPPGraph() {
  std::string pbtxt;
  MP_RETURN_IF_ERROR(mediapipe::file::GetContents(kGraph, &pbtxt));
  auto config =
      mediapipe::ParseTextProtoOrDie<mediapipe::CalculatorGraphConfig>(pbtxt);
  LOG(INFO) << "Initialize the calculator graph.";
  std::string windowName;
  if (!FLAGS_without_window) windowName = "mediapipe " + std::string(wName);
  bool window_was_closed = false;
  std::map<std::string, ::mediapipe::Packet> input_side_packets = {
      {"window_name", ::mediapipe::MakePacket<std::string>(windowName)},
      {"window_was_closed", ::mediapipe::MakePacket<bool*>(&window_was_closed)},
      {"nvr",
       ::mediapipe::MakePacket<::mediapipe::NormalizedLandmarkList*>(&nvr)},
  };
  mediapipe::CalculatorGraph graph;
  MP_RETURN_IF_ERROR(graph.Initialize(config, input_side_packets));
  MAYBE_INIT_GPU(graph);

  LOG(INFO) << "Load the video.";
  cv::VideoCapture capture;
  const bool load_video = !FLAGS_input_video_path.empty();
  if (load_video) {
    capture.open(FLAGS_input_video_path);
    // capture.set(cv::CAP_PROP_FPS, 2);
  } else {
    capture.open(0);
  }
  RET_CHECK(capture.isOpened());
  const double invCaptureFPS = 1.0 / capture.get(cv::CAP_PROP_FPS);

  LOG(INFO) << "Start running the calculator graph.";
  MP_RETURN_IF_ERROR(graph.StartRun({}));

  LOG(INFO) << "Start grabbing and processing frames.";
  size_t frame_timestamp = 0;

  RET_CHECK(glfwInit());

  glfwWindowHint(GLFW_SAMPLES, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow* window = glfwCreateWindow(wWidth, wHeight, wName, NULL, NULL);
  if (window == NULL) {
    glfwTerminate();
    LOG(FATAL) << "!window";
  }
  glfwMakeContextCurrent(window);

  LOG(INFO) << "GLSL version: " << glGetString(GL_SHADING_LANGUAGE_VERSION);
  LOG(INFO) << "Renderer: " << glGetString(GL_RENDERER);
  LOG(INFO) << "OpenGL version supported " << glGetString(GL_VERSION);

  glfwSetErrorCallback(error_callback);
  glfwSetKeyCallback(window, key_callback);
  glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);

  // Dark blue background
  glClearColor(0.0f, 0.0f, 0.4f, 0.0f);

  glEnable(GL_DEPTH_TEST);
  // Accept fragment if it closer to the camera than the former one
  glDepthFunc(GL_LESS);

  GLuint VertexArrayID;
  glGenVertexArrays(1, &VertexArrayID);
  glBindVertexArray(VertexArrayID);

  GLuint programID = LoadShaders();
  GLuint MatrixID = glGetUniformLocation(programID, "MVP");

  // Projection matrix : 45� Field of View, 4:3 ratio, display range : 0.1 unit
  // <-> 100 units
  glm::mat4 Projection =
      glm::perspective(glm::radians(45.0f), 4.0f / 3.0f, 0.1f, 100.0f);
  // Model matrix : an identity matrix (model will be at the origin)
  glm::mat4 Model = glm::mat4(1.0f);

  // Our vertices. Tree consecutive floats give a 3D vertex; Three consecutive
  // vertices give a triangle. A cube has 6 faces with 2 triangles each, so this
  // makes 6*2=12 triangles, and 12*3 vertices
  static const GLfloat g_vertex_buffer_data[] = {
      -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, 1.0f,  -1.0f, 1.0f,  1.0f,  1.0f,
      1.0f,  -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, 1.0f,  -1.0f, 1.0f,  -1.0f,
      1.0f,  -1.0f, -1.0f, -1.0f, 1.0f,  -1.0f, -1.0f, 1.0f,  1.0f,  -1.0f,
      1.0f,  -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f,
      1.0f,  1.0f,  -1.0f, 1.0f,  -1.0f, 1.0f,  -1.0f, 1.0f,  -1.0f, -1.0f,
      1.0f,  -1.0f, -1.0f, -1.0f, -1.0f, 1.0f,  1.0f,  -1.0f, -1.0f, 1.0f,
      1.0f,  -1.0f, 1.0f,  1.0f,  1.0f,  1.0f,  1.0f,  -1.0f, -1.0f, 1.0f,
      1.0f,  -1.0f, 1.0f,  -1.0f, -1.0f, 1.0f,  1.0f,  1.0f,  1.0f,  -1.0f,
      1.0f,  1.0f,  1.0f,  1.0f,  1.0f,  1.0f,  -1.0f, -1.0f, 1.0f,  -1.0f,
      1.0f,  1.0f,  1.0f,  -1.0f, 1.0f,  -1.0f, -1.0f, 1.0f,  1.0f,  1.0f,
      1.0f,  1.0f,  -1.0f, 1.0f,  1.0f,  1.0f,  -1.0f, 1.0f};

  // One color for each vertex. They were generated randomly.
  static const GLfloat g_color_buffer_data[] = {
      0.583f, 0.771f, 0.014f, 0.609f, 0.115f, 0.436f, 0.327f, 0.483f, 0.844f,
      0.822f, 0.569f, 0.201f, 0.435f, 0.602f, 0.223f, 0.310f, 0.747f, 0.185f,
      0.597f, 0.770f, 0.761f, 0.559f, 0.436f, 0.730f, 0.359f, 0.583f, 0.152f,
      0.483f, 0.596f, 0.789f, 0.559f, 0.861f, 0.639f, 0.195f, 0.548f, 0.859f,
      0.014f, 0.184f, 0.576f, 0.771f, 0.328f, 0.970f, 0.406f, 0.615f, 0.116f,
      0.676f, 0.977f, 0.133f, 0.971f, 0.572f, 0.833f, 0.140f, 0.616f, 0.489f,
      0.997f, 0.513f, 0.064f, 0.945f, 0.719f, 0.592f, 0.543f, 0.021f, 0.978f,
      0.279f, 0.317f, 0.505f, 0.167f, 0.620f, 0.077f, 0.347f, 0.857f, 0.137f,
      0.055f, 0.953f, 0.042f, 0.714f, 0.505f, 0.345f, 0.783f, 0.290f, 0.734f,
      0.722f, 0.645f, 0.174f, 0.302f, 0.455f, 0.848f, 0.225f, 0.587f, 0.040f,
      0.517f, 0.713f, 0.338f, 0.053f, 0.959f, 0.120f, 0.393f, 0.621f, 0.362f,
      0.673f, 0.211f, 0.457f, 0.820f, 0.883f, 0.371f, 0.982f, 0.099f, 0.879f};

  GLuint vertexbuffer;
  glGenBuffers(1, &vertexbuffer);
  glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(g_vertex_buffer_data),
               g_vertex_buffer_data, GL_STATIC_DRAW);

  GLuint colorbuffer;
  glGenBuffers(1, &colorbuffer);
  glBindBuffer(GL_ARRAY_BUFFER, colorbuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(g_color_buffer_data),
               g_color_buffer_data, GL_STATIC_DRAW);

  Floats eyeXs = {4}, eyeYs = {3}, eyeZs = {-3};
  while (!window_was_closed && !glfwWindowShouldClose(window)) {
    double t = (double)cvGetTickCount();

    cv::Mat camera_frame_raw;
    capture >> camera_frame_raw;
    if (camera_frame_raw.empty()) {
      LOG(INFO) << "EOV";
      break;
    }
    cv::Mat input_frame;
    cv::cvtColor(camera_frame_raw, input_frame, cv::COLOR_BGR2RGB);
    if (!load_video)
      cv::flip(input_frame, input_frame, /*flipcode=HORIZONTAL*/ 1);

    const auto ts =
        mediapipe::Timestamp::FromSeconds(frame_timestamp++ * invCaptureFPS);
    ADD_INPUT_FRAME("input_frame", input_frame, ts);

    // LOG(INFO) << "nvr: " << nvr.DebugString();

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(programID);

    LOG(INFO) << "nvr.landmark_size() = " << nvr.landmark_size();
    if (nvr.landmark_size() == 1) {
      eyeXs.push_back(1.5 * (5 - nvr.landmark(0).x()));
      eyeYs.push_back(1.5 * (nvr.landmark(0).y()));
      eyeZs.push_back(1.5 * (nvr.landmark(0).z()));
    }
    while (eyeXs.size() > max_samples_count) {
      eyeXs.pop_front();
      eyeYs.pop_front();
      eyeZs.pop_front();
    }
    auto eyeX = Mean(eyeXs), eyeY = Mean(eyeYs), eyeZ = Mean(eyeZs);
    LOG(INFO) << "eye x|y|z: " << eyeX << "|" << eyeY << "|" << eyeZ;

    // Camera matrix
    glm::mat4 View = glm::lookAt(
        glm::vec3(eyeX, eyeY, eyeZ),
        glm::vec3(0, 0, 0),  // and looks at the origin
        glm::vec3(0, -1, 0)  // Head is up (set to 0,-1,0 to look upside-down)
    );
    // Our ModelViewProjection : multiplication of our 3 matrices
    // Remember, matrix multiplication is the other way around
    glm::mat4 MVP = Projection * View * Model;
    glUniformMatrix4fv(MatrixID, 1, GL_FALSE, &MVP[0][0]);

    // 1rst attribute buffer : vertices
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glVertexAttribPointer(0,  // attribute. No particular reason for 0, but must
                              // match the layout in the shader.
                          3,  // size
                          GL_FLOAT,  // type
                          GL_FALSE,  // normalized?
                          0,         // stride
                          (void*)0   // array buffer offset
    );

    // 2nd attribute buffer : colors
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, colorbuffer);
    glVertexAttribPointer(1,  // attribute. No particular reason for 1, but must
                              // match the layout in the shader.
                          3,  // size
                          GL_FLOAT,  // type
                          GL_FALSE,  // normalized?
                          0,         // stride
                          (void*)0   // array buffer offset
    );

    // 12*3 indices starting at 0 -> 12 triangles
    glDrawArrays(GL_TRIANGLES, 0, 12 * 3);

    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);

    glfwSwapBuffers(window);
    glfwPollEvents();

    t = (double)cvGetTickCount() - t;
    LOG(INFO) << t / ((double)cvGetTickFrequency() * 1000.) << " ms";
  }

  LOG(INFO) << "Shutting down.";

  glDeleteBuffers(1, &vertexbuffer);
  glDeleteBuffers(1, &colorbuffer);
  glDeleteProgram(programID);
  glDeleteVertexArrays(1, &VertexArrayID);
  glfwTerminate();

  MP_RETURN_IF_ERROR(graph.CloseAllInputStreams());
  return graph.WaitUntilDone();
}

int main(int argc, char** argv) {
  google::InitGoogleLogging(argv[0]);
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  ::mediapipe::Status run_status = RunMPPGraph();
  if (!run_status.ok())
    LOG(FATAL) << "Failed to run the graph: " << run_status.message() << " !!";
  LOG(INFO) << "Success!";
  return 0;
}
