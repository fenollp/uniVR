/* Standalone Shadertoy
 * Copyright (C) 2014 Simon Budig <simon@budig.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>

#include <GL/glew.h>
#ifdef __APPLE__
# define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
# include <OpenGL/gl.h>
# include <OpenGL/glu.h>
# include <GLUT/glut.h>
# include <OpenGL/gl3.h>
# include <OpenGL/glext.h>
#else
# ifdef _WIN32
#  include <windows.h>
# endif
# include <GL/gl.h>
# include <GL/glu.h>
# include <GL/glut.h>
// #include <GL/freeglut_ext.h>
#endif

#include <FreeImage.h>

#ifdef __MACH__
# include <mach/clock.h>
# include <mach/mach.h>
#endif

#include <iostream>
#include <fstream>
#include <streambuf>
#include <regex>

#include "nvr.hh"

// Shared memory between the 2 main loops
nvr::UniVR ovr;
nvr::data  data;
size_t dropper = 0;
static int shader = 0;
static bool channels_loaded = false;

#define NAME "shaders"
#define winWidth  640
#define winHeight 480

/* width, height, x0, y0 (top left) */
static double geometry[4] = { 0, };

/* x, y, x_press, y_press  (in target coords) */
static double mouse[4] = { 0, };

static bool in_fullscreen = false;
static int window_x0 = -1;
static int window_y0 = -1;
static int window_width = -1;
static int window_height = -1;

bool
load_texture (const std::string& filename,
              GLint       tex_type,
              GLenum     *tex_id);

std::string
load_file (const std::string& filename, GLint types[4]);

GLint
link_program (const std::string& shader_source);

class Shader {
public:
    GLint prog = 0;
    GLenum tex[4];
    std::string file;
    std::string code;
    std::string textures[4];
    GLint       tex_types[4];
    Shader (const std::string& f,
            const std::string& t0,
            const std::string& t1,
            const std::string& t2,
            const std::string& t3)
        : file("data/shaders/glsl/" + f)
        {
            textures[0] = t0; tex_types[0] = (t0.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[1] = t1; tex_types[1] = (t1.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[2] = t2; tex_types[2] = (t2.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[3] = t3; tex_types[3] = (t3.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
        }
    void load_textures () {
        for (int i = 0; i < 4; ++i)
            if (!textures[i].empty())
                load_texture("data/shaders/presets/"+textures[i], tex_types[i], &tex[i]);
    }
    bool load_then_link () {
        code = load_file(file, tex_types);
        prog = link_program(code);
        return prog >= 0;
    }
};

static Shader shaders[] = {
   Shader("4dBXWD.glsl", "", "", "", ""),//nice 50 mouse
//   Shader("XtfGzj.glsl", "", "", "", ""),
   Shader("MdBGDK.glsl", "", "", "", ""),//60 mouse wowwwwwww
   Shader("ldXGDr.glsl", "", "", "", ""),//nicemap 60 mouse
   Shader("Md2Xzm.glsl", "tex16.png", "cube02_0.jpg", "", ""),//mouse nicecube 60
//   Shader("MsXGR2.glsl", "", "", "", ""),//60 wow nomouse
//   Shader("4sXGzn.glsl", "tex03.jpg", "", "", ""),//mouse nice 60
//   Shader("MdlXWr.glsl", "", "", "", ""),//60 starsnice mouse
//   Shader("ls2GDw.glsl", "tex03.jpg", "tex09.jpg", "tex02.jpg", "cube01_0.png"),//wowwoods 50 mouse
//   Shader("4dBXzw.glsl", "tex09.jpg", "", "", ""),//nicetargets 60 mouse
   Shader("Artificial.glsl", "cube04_0.png", "", "", ""),//50 mouse wow3d
   Shader("Hand-drawn Sketch.glsl", "", "", "", ""), //nicecartoon 60 mouse
//   Shader("crystal beacon.glsl", "", "", "", ""), //nomouse 50 wow
//   Shader("ldl3DS.glsl", "", "", "", ""),//nomouse 60 nice
//   Shader("MljGzR.glsl", "", "", "", ""),//60 nomouse meh
//   Shader("Msj3zD.glsl", "", "", "", ""),//cool 60 nomouse 2d
   Shader("llj3Rz.glsl", "tex09.jpg", "", "", ""), //onlymousex 60 nice
   Shader("XdlGzH.glsl", "tex04.jpg", "", "", ""),//nomouse 50 streetview
   Shader("Xyptonjtroz.glsl", "", "", "", ""),
   Shader("electron.glsl", "", "", "", "")
};



void
update_mouse_xy (int x, int y) {
    int x0     = glutGet(GLUT_WINDOW_X);
    int y0     = glutGet(GLUT_WINDOW_Y);
    int height = glutGet(GLUT_WINDOW_HEIGHT);
    if (geometry[0] > 0.1 && geometry[1] > 0.1) {
        mouse[0] =               geometry[2] + x0 + x;
        mouse[1] = geometry[1] - geometry[3] - y0 - y;
    } else {
        mouse[0] = x;
        mouse[1] = height - y;
    }
}

void
mouse_press_handler (int button, int state, int x, int y) {
    if (button != GLUT_LEFT_BUTTON)
        return;
    if (state == GLUT_DOWN) {
        update_mouse_xy(x, y);
        mouse[2] = mouse[0];
        mouse[3] = mouse[1];
    } else {
        mouse[2] = -1;
        mouse[3] = -1;
    }
}

void
show (int n) {
    if (n == shader) return;
    if      (n < 0) n = sizeof(shaders)/sizeof(Shader) -1;
    else if (n > (sizeof(shaders)/sizeof(Shader) -1)) n = 0;
    std::cout << "Switching to " << n << ": " << shaders[n].file << std::endl;
    shader = n;
    channels_loaded = false;
}

void
keyboard_handler (unsigned char key
                  , int // x
                  , int // y
    ) {
    switch (key) {
    case 27: // = ESC
    case 'q':
    case 'Q':
        exit(0);

    case 'f':
    case 'F':
        if (!in_fullscreen) {
            window_x0 = glutGet(GLUT_WINDOW_X);
            window_y0 = glutGet(GLUT_WINDOW_Y);
            window_width  = glutGet(GLUT_WINDOW_WIDTH);
            window_height = glutGet(GLUT_WINDOW_HEIGHT);
            in_fullscreen = true;
            glutFullScreen();
        } else {
            in_fullscreen = false;
            glutPositionWindow(window_x0, window_y0);
            glutReshapeWindow(window_width, window_height);
        }
        break;

    case ' ':
        ovr.detect_now();
        break;

    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
        show(key - '0');
        break;
    }
}

void
kb_arrows (int key, int, int) {
    if (GLUT_KEY_LEFT == key) {
        show(shader -1);
        return;
    }
    if (GLUT_KEY_RIGHT == key) {
        show(shader +1);
        return;
    }
}


void
univr () {
    ++dropper;
    if (10*dropper == 30) {
        ovr.step(data);
        dropper = 0;
    }
    int scale = 37;
    update_mouse_xy(scale * data.eyeX, scale * data.eyeY);
}

void
redisplay (int value) {
    glutPostRedisplay();
    glutTimerFunc(value, redisplay, value);
}


void
display (void)
{
  static int frames, last_time;
#ifdef __MACH__
  /// https://github.com/SIPp/sipp/pull/104/files
  // OS X does not have clock_gettime, use clock_get_time
  clock_serv_t cclock;
  mach_timespec_t mts;
#endif
  struct timespec ts;

  glUseProgram(shaders[shader].prog);
  univr();

  int x0     = glutGet(GLUT_WINDOW_X);
  int y0     = glutGet(GLUT_WINDOW_Y);
  int width  = glutGet(GLUT_WINDOW_WIDTH);
  int height = glutGet(GLUT_WINDOW_HEIGHT);
#ifdef __MACH__
  host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
  clock_get_time(cclock, &mts);
  mach_port_deallocate(mach_task_self(), cclock);
  ts.tv_sec = mts.tv_sec;
  ts.tv_nsec = mts.tv_nsec;
#else
  clock_gettime (CLOCK_MONOTONIC_RAW, &ts);
#endif
  int ticks = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;

  if (frames == 0)
    last_time = ticks;
  frames++;
  if (ticks - last_time >= 5000)
    {
      fprintf (stderr, "FPS: %.2f\n", 1000.0 * frames / (ticks - last_time));
      frames = 0;
    }

  GLint uindex;

  /// shader playback time (in seconds)
  uindex = glGetUniformLocation (shaders[shader].prog, "iGlobalTime");
  if (uindex >= 0)
    glUniform1f (uindex, ((float) ticks) / 1000.0);

  /// viewport resolution (in pixels)
  uindex = glGetUniformLocation (shaders[shader].prog, "iResolution");
  if (uindex >= 0)
    {
      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        glUniform3f (uindex, geometry[0], geometry[1], 1.0);
      else
        glUniform3f (uindex, width, height, 1.0);
    }

  /// viewport offset (in pixels)
  uindex = glGetUniformLocation (shaders[shader].prog, "iOffset");
  if (uindex >= 0)
    {
      if (geometry[0] > 0.1 && geometry[1] > 0.1)
          glUniform2f (uindex,
                       x0 + geometry[2],
                       geometry[1] - (y0 + height) - geometry[3]);
      else
          glUniform2f (uindex, 0.0, 0.0);
    }

  /// mouse pixel coords. xy: current (if MLB down), zw: click
  uindex = glGetUniformLocation (shaders[shader].prog, "iMouse");
  if (uindex >= 0)
    glUniform4f (uindex, mouse[0],  mouse[1], mouse[2], mouse[3]);

  /// input channel. XX = 2D/Cube
  if (!channels_loaded) {
    for (int k = 0; k < 4; ++k) {
        auto chan = "iChannel" + std::to_string(k);
        uindex = glGetUniformLocation(shaders[shader].prog, chan.c_str());
        if (uindex >= 0) {
            glActiveTexture(GL_TEXTURE0 + k);
            glBindTexture(shaders[shader].tex_types[k], shaders[shader].tex[k]);
            glUniform1i(uindex, k);
        }
    }
    channels_loaded = true;
  }

  glClear (GL_COLOR_BUFFER_BIT);
  glRectf (-1.0, -1.0, 1.0, 1.0);

  glutSwapBuffers ();
}

bool
load_texture (const std::string& filename,
              GLint       tex_type,
              GLenum     *tex_id) {
    FREE_IMAGE_FORMAT format = FreeImage_GetFileType(filename.c_str(), 0);
    if (format == -1)
        format = FreeImage_GetFIFFromFilename(filename.c_str());
    if (!FreeImage_FIFSupportsReading(format)) {
        std::cerr << "!read texture format " << filename << std::endl;
        return false;
    }

    FIBITMAP* bitmap = FreeImage_Load(format, filename.c_str(), 0);
    if (bitmap == NULL) {
        std::cerr << "!file " << filename << std::endl;
        return false;
    }
    int bitsPerPixel = FreeImage_GetBPP(bitmap);
    FIBITMAP* bitmap32 = NULL;
    if (bitsPerPixel == 32)
        bitmap32 = bitmap;
    else
        bitmap32 = FreeImage_ConvertTo32Bits(bitmap); // --> RGBa

    FreeImage_FlipVertical(bitmap32); // = TRUE

    int imageWidth  = FreeImage_GetWidth(bitmap32);
    int imageHeight = FreeImage_GetHeight(bitmap32);
    // We don't need to delete or delete[] this textureData because it's not on the heap
    GLubyte* textureData = FreeImage_GetBits(bitmap32);
    glGenTextures(1, tex_id);
    glBindTexture(GL_TEXTURE_2D, *tex_id);
    // Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
    // BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.

    auto tex_data = new GLfloat[imageWidth * imageHeight * 4];
    for (int y = 0; y < imageHeight; ++y) {
        uint8_t *curr_row = (uint8_t *) (textureData + y * imageWidth * 4);
        for (int x = 0; x < imageWidth; ++x) {
            tex_data[(y * imageWidth + x) * 4 + 0] = ((GLfloat) curr_row[x * 4 + 0]) / 255.0;
            tex_data[(y * imageWidth + x) * 4 + 1] = ((GLfloat) curr_row[x * 4 + 1]) / 255.0;
            tex_data[(y * imageWidth + x) * 4 + 2] = ((GLfloat) curr_row[x * 4 + 2]) / 255.0;
            tex_data[(y * imageWidth + x) * 4 + 3] = ((GLfloat) curr_row[x * 4 + 3]) / 255.0;
        }
    }

    glTexImage2D(GL_TEXTURE_2D,    // Type of texture
                 0,                // Mipmap level (0 being the top level i.e. full size)
                 GL_RGBA,          // Internal format
                 imageWidth,       // Width of the texture
                 imageHeight,      // Height of the texture,
                 0,                // Border in pixels
                 // GL_BGRA,          // Data format
                 GL_RGBA,
                 //GL_RGB |||| GL_RGBA
                 // GL_UNSIGNED_BYTE, // Type of texture data
                 GL_FLOAT,
                 // textureData);     // The image data to use for this texture
                 tex_data);

    if (false) { // = nearest
        glTexParameteri(tex_type, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(tex_type, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    } else {
        glTexParameteri(tex_type, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(tex_type, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glGenerateMipmap(tex_type);
    }
    if (true) { // = repeat
        glTexParameteri(tex_type, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(tex_type, GL_TEXTURE_WRAP_T, GL_REPEAT);
    } else {
        glTexParameteri(tex_type, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(tex_type, GL_TEXTURE_WRAP_T, GL_CLAMP);
    }

    switch (glGetError()) {
    case GL_NO_ERROR:
        break;
    case GL_INVALID_ENUM:
        std::cerr << "!gl enum " << filename << std::endl;
        return false;
    case GL_INVALID_VALUE:
        std::cerr << "!gl value " << filename << std::endl;
        return false;
    case GL_INVALID_OPERATION:
        std::cerr << "!gl operation " << filename << std::endl;
        return false;
    default:
        std::cerr << "!GL_ENUM " << filename << std::endl;
        return false;
    }

    delete[] tex_data;
    FreeImage_Unload(bitmap32);
    if (bitsPerPixel != 32)
        FreeImage_Unload(bitmap);

    fprintf(stdout, "texture: %s, %dx%d, (%d) --> id %d\n",
            filename.c_str(), imageWidth, imageHeight, bitsPerPixel, *tex_id);
    return true;
}


GLint
compile_shader (const std::string& shader_source) {
    GLint status = GL_FALSE;
    auto source = shader_source.c_str();
    GLuint shader = glCreateShader(GL_FRAGMENT_SHADER);

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_TRUE)
        return shader;

    GLint loglen;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &loglen);
    auto msg = new GLchar[loglen]();
    glGetShaderInfoLog(shader, loglen, NULL, msg);
    std::cerr << "!compile" << std::endl
              << msg        << std::endl;
    delete[] msg;
    return -1;
}


GLint
link_program (const std::string& shader_source) {
    GLint status = GL_FALSE;
    GLint n_uniforms;

    GLint frag = compile_shader(shader_source);
    if (frag < 0)
        return -1;

    GLint program = glCreateProgram();
    glAttachShader(program, frag);
    glLinkProgram(program);
    // glDeleteShader(frag);

    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status != GL_TRUE) {
        GLint loglen;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &loglen);
        auto msg = new GLchar[loglen]();
        glGetProgramInfoLog(program, loglen, NULL, msg);
        std::cerr << "!link" << std::endl
                  << msg     << std::endl;
        delete[] msg;
        return -1;
    }

    glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &n_uniforms);
    std::cerr << n_uniforms << " uniforms:" << std::endl;
    for (GLint i = 0; i < n_uniforms; ++i) {
        GLint size;
        GLenum type;
        GLchar name[20];
        GLsizei namelen;
        glGetActiveUniform(program, i, 19, &namelen, &size, &type, name);
        name[namelen] = '\0';
        std::cerr << i << ": " << name << "  type: " << type << ", " << size << std::endl;
    }

    return program;
}

void
init_glew () {
    GLenum status = glewInit();

    if (status != GLEW_OK) {
      fprintf (stderr, "glewInit error: %s\n", glewGetErrorString (status));
      exit (-1);
    }

  fprintf (stderr,
           "GL_VERSION   : %s\nGL_VENDOR    : %s\nGL_RENDERER  : %s\n"
           "GLEW_VERSION : %s\nGLSL VERSION : %s\n\n",
           glGetString (GL_VERSION), glGetString (GL_VENDOR),
           glGetString (GL_RENDERER), glewGetString (GLEW_VERSION),
           glGetString (GL_SHADING_LANGUAGE_VERSION));

  if (!GLEW_VERSION_2_1) {
      fprintf (stderr, "OpenGL 2.1 or better required for GLSL support.");
      exit (-1);
  }
}


std::string
may_add (const std::string& str,
         const std::string& matcher,
         const std::string& var) {
    std::regex re(matcher);
    std::smatch matches; // Useless but http://stackoverflow.com/a/26696318/1418165
    if (!std::regex_search(str, matches, re)) {
        std::cout << "Using  " << var << std::endl;
        return var + "\n";
    }
    return "";
}

std::string
load_file (const std::string& filename, GLint types[4]) {
    std::ifstream ifs(filename);
    if (!ifs.is_open()) {
        std::cerr << "!read " << filename << std::endl;
        exit(1);
    }
    std::string str( (std::istreambuf_iterator<char>(ifs))
                    , std::istreambuf_iterator<char>());
    std::regex coms("//[^\\n]+\\n");
    str = std::regex_replace(str, coms, std::string("\n"));

    for (int i = 0; i < 4; ++i) {
        std::string channel = "iChannel" + std::to_string(i) + ";";
        if (types[i] == GL_TEXTURE_2D)
            str = may_add(str, "uniform\\s+sampler2D\\s+"+channel, "uniform sampler2D "+channel) + str;
        else if (types[i] == GL_TEXTURE_3D)
            str = may_add(str, "uniform\\s+samplerCube\\s+"+channel, "uniform samplerCube "+channel) + str;
        else continue;
    }

    return
        may_add(str, "uniform\\s+vec3\\s+iResolution", "uniform vec3 iResolution;") +
        may_add(str, "uniform\\s+float\\s+iGlobalTime", "uniform float iGlobalTime;") +
        may_add(str, "uniform\\s+vec4\\s+iMouse", "uniform vec4 iMouse;") +
        may_add(str, "uniform\\s+vec2\\s+iOffset", "uniform vec2 iOffset;") +
        // "uniform float     iChannelTime[4];"       /// channel playback time (in seconds)
        // "uniform vec3      iChannelResolution[4];" /// channel resolution (in pixels)
        // "uniform vec4      iDate;"                 /// (year, month, day, time in seconds)
        // "uniform float     iSampleRate;" /// sound sample rate (i.e., 44100)
        // "struct Camera {"
        // "  int  active;"/// external camera active
        // "  mat4 position;"/// external camera position
        // "  vec3 screen;"/// external camera screen spec (halfSizeX, halfSizeY, distanceZ)
        // "};"
        // "uniform Camera    iCamera;" /// Oculus HMD eye position

        str + "\n" +
        may_add(str, "void\\s+main\\s*\\(",
                "void main(void)\n"
                "{\n"
                // "    vec4 color[4];\n"
                // "    mainImage(color[0], gl_FragCoord.xy);\n"
                // "    gl_FragColor = color[0];\n"
                "    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);\n"
                "    mainImage(color, gl_FragCoord.xy);\n"
                "    color.w = 1.0;\n"
                "    gl_FragColor = color;\n"
                "}\n");
}


int
main (int argc, char *argv[]) {
    glutInit(&argc, argv);

    glutInitWindowSize(winWidth, winHeight);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
    glutCreateWindow(NAME);

    init_glew();

    FreeImage_Initialise(false);
    for (int s = sizeof(shaders)/sizeof(Shader) -1; s >= 0; --s) {
        std::cout << "Loading " << shaders[s].file << std::endl;
        shaders[s].load_textures();
        if (!shaders[s].load_then_link()) {
            fprintf (stderr, "Failed to link shader program %i. Aborting\n", s);
            exit (-1);
        }
    }
    FreeImage_DeInitialise();
    show(0);

    glutDisplayFunc(display);
    glutMouseFunc(mouse_press_handler);
    glutMotionFunc(update_mouse_xy);
    glutKeyboardFunc(keyboard_handler);
    glutSpecialFunc(kb_arrows);

    redisplay(1000/60);

    ovr.init("data/ldmrks68.dat");  // UniVR init

    glutMainLoop();

    return 0;
}
