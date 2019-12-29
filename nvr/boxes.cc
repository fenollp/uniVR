#define GLEW_STATIC
#include <GL/glew.h>

#include <GLFW/glfw3.h>

#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/formats/landmark.pb.h"
#include "mediapipe/framework/port/commandlineflags.h"
#include "mediapipe/framework/port/file_helpers.h"
#include "mediapipe/framework/port/opencv_highgui_inc.h"
#include "mediapipe/framework/port/opencv_imgproc_inc.h"
#include "mediapipe/framework/port/opencv_video_inc.h"
#include "mediapipe/framework/port/parse_text_proto.h"

#define GRAPHS "nvr/graphs/"
#if !defined(MEDIAPIPE_DISABLE_GPU)
constexpr char kGraph[] = GRAPHS "boxes_gpu.pbtxt";
#else
constexpr char kGraph[] = GRAPHS "boxes_cpu.pbtxt";
#endif
#include "mediapipe_xpu.h"

#define NAME "nvr_boxes"
#define WIDTH 640
#define HEIGHT 480

DEFINE_string(input_video_path, "", "Full path of video to load.");
DEFINE_bool(without_window, false, "Do not setup opencv window.");

::mediapipe::NormalizedLandmarkList nvr;

GLfloat xrot;    // x rotation
GLfloat yrot;    // y rotation
GLfloat xspeed;  // x rotation speed
GLfloat yspeed;  // y rotation speed

GLfloat z = -5.0f;  // depth into the screen.

/* white ambient light at half intensity (rgba) */
GLfloat LightAmbient[] = {0.5f, 0.5f, 0.5f, 1.0f};
/* super bright, full intensity diffuse light. */
GLfloat LightDiffuse[] = {1.0f, 1.0f, 1.0f, 1.0f};
/* position of light (x, y, z, (position of light)) */
GLfloat LightPosition[] = {0.0f, 2.0f, 0.0f, 1.0f};

bool light;      // Lighting on/off (false is off)
GLuint texture;  // Holds loaded texture

void DrawGLScene() {
  double t = (double)cvGetTickCount();

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);  // Clear scene & depthb
  glLoadIdentity();                                    // Reset The View

  if (nvr.landmark_size() != 1) {
    LOG(INFO) << "nvr.landmark_size() = " << nvr.landmark_size();
  } else {
    printf("X %lf\tY %lf\tZ %lf\n", nvr.landmark(0).x(), nvr.landmark(0).y(),
           nvr.landmark(0).z());  //
    gluLookAt(nvr.landmark(0).x(), nvr.landmark(0).y(), nvr.landmark(0).z(), 0,
              0, 0, 0, 1, 0);  //+ 5*headDist
  }

  glTranslatef(0.0f, 0.0f, -1);  // Move z units out from the screen

  glRotatef(xrot, 1.0f, 0.0f, 0.0f);  // Rotate On The X Axis
  glRotatef(yrot, 0.0f, 1.0f, 0.0f);  // Rotate On The Y Axis

  glBindTexture(GL_TEXTURE_2D, texture);

  glBegin(GL_QUADS);  // begin drawing a cube

  // Front Face (note that the texture's corners have to match the quad's)
  glNormal3f(0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Left

  // Back Face
  glNormal3f(0.0f, 0.0f, -1.0f);  // back face points into the screen on z
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Left

  // Top Face
  glNormal3f(0.0f, 1.0f, 0.0f);  // top face points up on y
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right

  // Bottom Face
  glNormal3f(0.0f, -1.0f, 0.0f);  // bottom face points down on y
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right

  // Right face
  glNormal3f(1.0f, 0.0f, 0.0f);  // right face points right on x
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left

  // Left Face
  glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left

  glEnd();  // done with the polygon

  glTranslatef(-3.0f, 0.0f, 0);  // Move z units out from the screen

  glBegin(GL_QUADS);  // begin drawing a cube

  // Front Face (note that the texture's corners have to match the quad's)
  glNormal3f(0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Left

  // Back Face
  glNormal3f(0.0f, 0.0f, -1.0f);  // back face points into the screen on z
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Left

  // Top Face
  glNormal3f(0.0f, 1.0f, 0.0f);  // top face points up on y
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right

  // Bottom Face
  glNormal3f(0.0f, -1.0f, 0.0f);  // bottom face points down on y
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right

  // Right face
  glNormal3f(1.0f, 0.0f, 0.0f);  // right face points right on x
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left

  // Left Face
  glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left

  glEnd();  // done with the polygon

  glTranslatef(+6.0f, 0.0f, 0);  // Move z units out from the screen

  glBegin(GL_QUADS);  // begin drawing a cube

  // Front Face (note that the texture's corners have to match the quad's)
  glNormal3f(0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Left

  // Back Face
  glNormal3f(0.0f, 0.0f, -1.0f);  // back face points into the screen on z
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Left

  // Top Face
  glNormal3f(0.0f, 1.0f, 0.0f);  // top face points up on y
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right

  // Bottom Face
  glNormal3f(0.0f, -1.0f, 0.0f);  // bottom face points down on y
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right

  // Right face
  glNormal3f(1.0f, 0.0f, 0.0f);  // right face points right on x
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left

  // Left Face
  glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left

  glEnd();  // done with the polygon

  glTranslatef(0.0f, 0.0f, 3.0);  // Move z units out from the screen

  glBegin(GL_QUADS);  // begin drawing a cube

  // Front Face (note that the texture's corners have to match the quad's)
  glNormal3f(0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Left

  // Back Face
  glNormal3f(0.0f, 0.0f, -1.0f);  // back face points into the screen on z
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Left

  // Top Face
  glNormal3f(0.0f, 1.0f, 0.0f);  // top face points up on y
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right

  // Bottom Face
  glNormal3f(0.0f, -1.0f, 0.0f);  // bottom face points down on y
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right

  // Right face
  glNormal3f(1.0f, 0.0f, 0.0f);  // right face points right on x
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, -1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, -1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(1.0f, 1.0f, 1.0f);  // Top Left
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(1.0f, -1.0f, 1.0f);  // Bottom Left

  // Left Face
  glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
  glTexCoord2f(0.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Left
  glTexCoord2f(1.0f, 0.0f);
  glVertex3f(-1.0f, -1.0f, 1.0f);  // Bottom Right
  glTexCoord2f(1.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, 1.0f);  // Top Right
  glTexCoord2f(0.0f, 1.0f);
  glVertex3f(-1.0f, 1.0f, -1.0f);  // Top Left

  glEnd();  // done with the polygon

  xrot += xspeed;  // X Axis Rotation
  yrot += yspeed;  // Y Axis Rotation

  t = (double)cvGetTickCount() - t;
  printf("\tframe time = %gms\n", t / ((double)cvGetTickFrequency() * 1000.));
}

GLuint LoadTexture(const std::string& bmp) {
  // stackoverflow.com/a/12524013/1418165
  GLuint tex;
  int tWidth = 256, tHeight = 256, tSize = tWidth * tHeight * 3;
  unsigned char* data = NULL;
  FILE* fd = NULL;

  if ((fd = fopen(bmp.c_str(), "rb")) == NULL) {
    std::cerr << "!file " << bmp << std::endl;
    fclose(fd);
    exit(2);
  }
  if ((data = (unsigned char*)malloc(tSize)) == NULL) {
    std::cerr << "!malloc texture of size " << tSize << std::endl;
    fclose(fd);
    exit(2);
  }
  if (fread(data, tSize, 1, fd) != 1) {
    std::cerr << "!fread texture of size " << tSize << std::endl;
    fclose(fd);
    free(data);
    exit(2);
  }
  fclose(fd);
  for (int i = 0; i < tWidth * tHeight; ++i) {  // Turn BGR into RGB
    int index = 3 * i;
    unsigned char B, R;
    B = data[index];
    R = data[index + 2];
    data[index] = R;
    data[index + 2] = B;
  }

  glGenTextures(1, &tex);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  // Scale linearly when image bigger than texture
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // Scale linearly + mipmap when image smalled than texture
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                  GL_LINEAR_MIPMAP_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  // 2d texture, level of detail 0 (normal), 3 components (rgb),
  // x size from image, y size from image, border 0 (normal), rgb color data,
  // unsigned byte data, and finally the data itself.
  glTexImage2D(GL_TEXTURE_2D, 0, 3, tWidth, tHeight, 0, GL_RGB,
               GL_UNSIGNED_BYTE, data);
  // 2d texture, 3 colors, width, height, RGB, byte data, and the data.
  gluBuild2DMipmaps(GL_TEXTURE_2D, 3, tWidth, tHeight, GL_RGB, GL_UNSIGNED_BYTE,
                    data);
  free(data);
  return tex;  // Not directly used but works (weird)
}

void InitGL(const std::string& bmp, GLsizei Width, GLsizei Height) {
  LoadTexture(bmp);
  glBindTexture(GL_TEXTURE_2D, texture);
  glEnable(GL_TEXTURE_2D);  // Enable texture mapping.

  glClearColor(0.0f, 0.0f, 0.0f, 0.0f);  // Black background color
  glClearDepth(1.0);                     // Clears depth buffer
  glDepthFunc(GL_LESS);                  // The Type Of Depth Test To Do
  glEnable(GL_DEPTH_TEST);               // Enables Depth Testing
  glShadeModel(GL_SMOOTH);               // Enables Smooth Color Shading

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();  // Reset The Projection Matrix

  // Calculate aspect ratio of window
  gluPerspective(45.0f, (GLfloat)Width / (GLfloat)Height, 0.1f, 100.0f);

  glMatrixMode(GL_MODELVIEW);

  // set up light number 1.
  glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);    // add lighting (ambient)
  glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);    // add lighting (diffuse).
  glLightfv(GL_LIGHT1, GL_POSITION, LightPosition);  // set light position
  glEnable(GL_LIGHT1);                               // turn light 1 on
  light = true;
  glEnable(GL_LIGHTING);
}

void key_callback(GLFWwindow* window, int key, int scancode, int action,
                  int mode) {
  if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
    glfwSetWindowShouldClose(window, GL_TRUE);
  //   case GLUT_KEY_PAGE_UP:  // move the cube into the distance.
  //   z -= 0.02f;
  //   break;
  // case GLUT_KEY_PAGE_DOWN:  // move the cube closer.
  //   z += 0.02f;
  //   break;
  // case GLUT_KEY_UP:  // decrease x rotation speed;
  //   xspeed -= 0.01f;
  //   break;
  // case GLUT_KEY_DOWN:  // increase x rotation speed;
  //   xspeed += 0.01f;
  //   break;
  // case GLUT_KEY_LEFT:  // decrease y rotation speed;
  //   yspeed -= 0.01f;
  //   break;
  // case GLUT_KEY_RIGHT:  // increase y rotation speed;
  //   yspeed += 0.01f;
  //   break;
}

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
    capture.set(cv::CAP_PROP_FPS, 2);
  } else {
    capture.open(0);
  }
  RET_CHECK(capture.isOpened());

  LOG(INFO) << "Start running the calculator graph.";
  MP_RETURN_IF_ERROR(graph.StartRun({}));

  LOG(INFO) << "Start grabbing and processing frames.";
  size_t frame_timestamp = 0;

  glfwInit();
  // Set all the required options for GLFW
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

  // Create a GLFWwindow object that we can use for GLFW's functions
  GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, NAME, nullptr, nullptr);
  glfwMakeContextCurrent(window);

  // Set the required callback functions
  glfwSetKeyCallback(window, key_callback);

  // Set this to true so GLEW knows to use a modern approach to retrieving
  // function pointers and extensions
  glewExperimental = GL_TRUE;
  // Initialize GLEW to setup the OpenGL Function pointers
  glewInit();

  // Define the viewport dimensions
  {
    int width, height;
    glfwGetFramebufferSize(window, &width, &height);
    glViewport(0, 0, width, height);
  }

  InitGL("data/crate.bmp", WIDTH, HEIGHT);

  while (!window_was_closed || !glfwWindowShouldClose(window)) {
    // Check if any events have been activiated (key pressed, mouse moved etc.)
    // and call corresponding response functions
    glfwPollEvents();

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

    LOG(INFO) << "nvr: " << nvr.DebugString();

    // Render
    // Clear the colorbuffer
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // Draw our first triangle
    DrawGLScene();

    // Swap the screen buffers
    glfwSwapBuffers(window);
  }

  LOG(INFO) << "Shutting down.";
  glfwTerminate();
  MP_RETURN_IF_ERROR(graph.CloseAllInputStreams());
  return graph.WaitUntilDone();
}

int main(int argc, char** argv) {
  google::InitGoogleLogging(argv[0]);
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  ::mediapipe::Status run_status = RunMPPGraph();
  if (!run_status.ok()) {
    LOG(FATAL) << "Failed to run the graph: " << run_status.message() << " !!";
  } else {
    LOG(INFO) << "Success!";
  }

  return 0;
}
