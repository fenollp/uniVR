#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#define GLEW_STATIC
#include <GL/glew.h>

#include <GLFW/glfw3.h>

#include <fstream>
#include <iostream>

int window_width = 800;
int window_height = 600;

float eyeX = 0;
float eyeY = 0;
float eyeZ = 5;

static const std::string vertexShaderSource = R"(\
#version 330 core
layout (location = 0) in vec3 aPos;
uniform mat4 u_proj;
uniform mat4 u_view;
void main() {
   gl_Position = u_proj * u_view * vec4(aPos.xyz, 1.0);
}
)";

static const std::string fragmentShaderSource = R"(\
#version 330 core
out vec4 FragColor;
void main() {
   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
)";

static void error_callback(int error, const char* description) {
  std::cerr << description << std::endl;
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action,
                         int mods) {
  if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
    glfwSetWindowShouldClose(window, GL_TRUE);

  if (key == GLFW_KEY_UP) eyeY += 0.2;
  if (key == GLFW_KEY_DOWN) eyeY += -0.2;
  if (key == GLFW_KEY_RIGHT) eyeX += 0.2;
  if (key == GLFW_KEY_LEFT) eyeX += -0.2;
}

int main() {
  glfwSetErrorCallback(error_callback);
  if (!glfwInit()) return -1;
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  glfwWindowHint(GLFW_SAMPLES, 4);  // 4x antialiasing
  GLFWwindow* window =
      glfwCreateWindow(window_width, window_height, "Hello World", NULL, NULL);
  if (!window) {
    glfwTerminate();
    return -1;
  }
  std::cout << "glfwCreateWindow\n";
  glfwMakeContextCurrent(window);

  glewExperimental = GL_TRUE;
  GLenum err = glewInit();
  if (err != GLEW_OK) {
    glfwTerminate();
    std::cout << "!glewInit\n";
    return -1;
  }
  std::cout << "glewInit\n";

  std::cout << "GLSL version: " << glGetString(GL_SHADING_LANGUAGE_VERSION)
            << std::endl;

  glfwSetKeyCallback(window, key_callback);

  std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
  std::cout << "OpenGL version supported " << glGetString(GL_VERSION)
            << std::endl;

  int vertexShader = glCreateShader(GL_VERTEX_SHADER);
  const char* vSrc = vertexShaderSource.c_str();
  glShaderSource(vertexShader, 1, (const GLchar**)&vSrc, NULL);
  glCompileShader(vertexShader);
  // check for shader compile errors
  int success;
  char infoLog[512];
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n"
              << infoLog << std::endl;
    return -1;
  }
  std::cout << "glCompileShader\n";
  // fragment shader
  int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  const char* fSrc = fragmentShaderSource.c_str();
  glShaderSource(fragmentShader, 1, (const GLchar**)&fSrc, NULL);
  glCompileShader(fragmentShader);
  // check for shader compile errors
  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n"
              << infoLog << std::endl;
    return -1;
  }
  std::cout << "glCompileShader\n";
  // link shaders
  int shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  // check for linking errors
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
  if (!success) {
    glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n"
              << infoLog << std::endl;
    return -1;
  }
  std::cout << "glLinkProgram\n";
  GLint projLoc = glGetUniformLocation(shaderProgram, "u_proj");
  GLint viewLoc = glGetUniformLocation(shaderProgram, "u_view");
  std::cout << "projLoc: " << projLoc << ", "
            << "viewLoc: " << viewLoc << "\n";
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);

  float vertices[] = {
      -1,  0.0, 0.0, -1,  0.0, 1.0, -1,  1.0, 0.0, -1,  1.0, 1.0,
      1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0,
  };
  unsigned int indices[] = {
      0, 6, 4, 0, 2, 6, 0, 3, 2, 0, 1, 3, 2, 7, 6, 2, 3, 7,
      4, 6, 7, 4, 7, 5, 0, 4, 5, 0, 5, 1, 1, 5, 7, 1, 7, 3,
  };

  unsigned int VBO, VAO, EBO;
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);
  glGenBuffers(1, &EBO);
  glBindVertexArray(VAO);
  std::cout << "glBindVertexArray\n";

  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  std::cout << "glBufferData\n";

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices,
               GL_STATIC_DRAW);
  std::cout << "glBufferData\n";

  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(0);

  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
  std::cout << "glBindVertexArray\n";

  // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

  while (!glfwWindowShouldClose(window)) {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glViewport(0, 0, window_width, window_height);

    glUseProgram(shaderProgram);

    glm::mat4 proj = glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, -10.0f, 10.0f);
    glm::mat4 view = glm::lookAt(
        // eye
        glm::vec3(eyeX, eyeY, eyeZ),
        // center
        glm::vec3(0.0f, 0.0f, 0.0f),
        // up
        glm::vec3(0.0f, 1.0f, 0.0f));
    glUniformMatrix4fv(projLoc, 1, GL_FALSE, glm::value_ptr(proj));
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));

    glBindVertexArray(VAO);  // seeing as we only have a single VAO there's no
                             // need to bind it every time, but we'll do so to
                             // keep things a bit more organized
    // glDrawArrays(GL_TRIANGLES, 0, 6);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    // glBindVertexArray(0); // no need to unbind it every time

    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  glfwDestroyWindow(window);
  glfwTerminate();
  return 0;
}
