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
#ifdef __APPLE_CC__
# define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
# include <OpenGL/gl3.h>
# include <OpenGL/glu.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#include <GLUT/glut.h>
// #else
// # include <GL/gl.h>
// # include <GL/glu.h>

// #include <GL/glut.h>
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
        : file("data/" + f)
        {
            textures[0] = t0; tex_types[0] = (t0.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[1] = t1; tex_types[1] = (t1.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[2] = t2; tex_types[2] = (t2.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
            textures[3] = t3; tex_types[3] = (t3.find("cube") == 0) ? GL_TEXTURE_3D : GL_TEXTURE_2D;
        }
    void load_textures () {
        for (int i = 0; i < 4; ++i)
            if (!textures[i].empty())
                load_texture("data/presets/"+textures[i], tex_types[i], &tex[i]);
    }
    bool load_then_link () {
        code = load_file(file, tex_types);
        prog = link_program(code);
        return prog >= 0;
    }
};

static Shader shaders[] = {
//    Shader("pyroclastic explosion.glsl", "", "", "", ""),//tooslow
//    Shader("XlsGz4.glsl", "", "tex09.jpg", "tex16.png", ""), //20, mouse, nice
//    Shader("XsB3Wc.glsl", "tex16.png", "", "", ""),//tooslow
//    Shader("MdXGW2.glsl", "tex11.png", "tex00.jpg", "tex09.jpg", "tex05.jpg"),//wow 15 mouse
//    Shader("4dSXDd.glsl", "", "", "", ""),//mouse 40 nice
//    Shader("4slGWM.glsl", "", "", "", ""),//40 nice fire mouse
//    Shader("MsBGWm.glsl", "tex16.png", "tex01.jpg", "", ""),//mouse 40 ok
//    Shader("4dBXWD.glsl", "", "", "", ""),//nice 50 mouse
//    Shader("MsSSWV.glsl", "", "", "", ""),//tooslow mouse nice
//    Shader("XtfGzj.glsl", "", "", "", ""),
//    Shader("MtfGR8.glsl", "tex07.jpg", "tex05.jpg", "tex12.png", "cube02_0.jpg"),//wow 24 mouse
//    Shader("Xsf3zX.glsl", "", "", "", ""),//meh
//    Shader("lsfXz4.glsl", "", "", "", ""),//tooslow wow mouse
   Shader("MdBGDK.glsl", "", "", "", ""),//60 mouse wowwwwwww
//    Shader("MsXXWH.glsl", "tex09.jpg", "tex11.png", "", ""),//good mouse 20
//    Shader("XljGDz.glsl", "", "", "", ""),//mouse 30 ok
//    Shader("ldB3DK.glsl", "", "", "", ""),//waytooslow
//    Shader("MtX3Ws.glsl", "cube02_0.jpg", "", "", ""),//nice mouse 20
//    Shader("MdjGRw.glsl", "tex16.png", "tex01.jpg", "", ""),//20 nice mouse
//    Shader("MdsGz8.glsl", "", "", "", ""),//20 mouse ok
//    Shader("4dBGDy.glsl", "tex12.png", "", "", ""),//wow nomouse 20
//    Shader("MdjGRy.glsl", "", "", "", ""),//kb 60 mouse lolitsagraph
//    Shader("Xls3D2.glsl", "", "", "", ""),//10 wow mouse
   Shader("ldXGDr.glsl", "", "", "", ""),//nicemap 60 mouse
   Shader("Md2Xzm.glsl", "tex16.png", "cube02_0.jpg", "", ""),//mouse nicecube 60
//    Shader("XlfGWl.glsl", "", "", "", ""),//wowmoving 20 mouse
//    Shader("MsXGR2.glsl", "", "", "", ""),//60 wow nomouse
//    Shader("4sXGzn.glsl", "tex03.jpg", "", "", ""),//mouse nice 60
//    Shader("XllGzN.glsl", "", "", "", ""),//nicestars mouse 40
//    Shader("lssGzn.glsl", "tex05.jpg", "", "tex14.png", "tex11.png"), //missing vid00.ogv //wow3dscene mouse 40
//    Shader("4tlGDM.glsl", "", "", "", ""),//5 wowplanes nomouse
//    Shader("lslSRf.glsl", "cube00_0.jpg", "cube01_0.png", "", ""),//wowstuff 10 mouse
//    Shader("lssGRM.glsl", "", "", "", ""),//10 wowflying 10
//    Shader("lssGW7.glsl", "tex09.jpg", "tex01.jpg", "tex07.jpg", "tex03.jpg"),//nice 20 mouse meh
//    Shader("4ssXW2.glsl", "tex16.png", "", "", ""),//nice 15 mouse meh
//    Shader("4dS3RG.glsl", "tex06.jpg", "", "", ""),//wow 25 mouse
//    Shader("lsX3WH.glsl", "", "", "", ""),//nomouse 30 ok
//    Shader("XsSGzG.glsl", "", "", "", ""),//teapot 10 mouse
//    Shader("4dB3Dw.glsl", "tex16.png", "", "", ""),//unresponding
//    Shader("Msf3Dj.glsl", "tex16.png", "cube04_0.png", "", ""),//unresponding
//    Shader("MdS3zm.glsl", "tex05.jpg", "tex04.jpg", "", ""),//30 nomouse cool
   Shader("MdlXWr.glsl", "", "", "", ""),//60 starsnice mouse
//    Shader("MsX3Rf.glsl", "", "", "", ""),//fuckedup
//    Shader("ls2GDw.glsl", "tex03.jpg", "tex09.jpg", "tex02.jpg", "cube01_0.png"),//wowwoods 50 mouse
//    Shader("4ssSRX.glsl", "tex05.jpg", "", "", ""),//10 wow mouse
//    Shader("4dBXzw.glsl", "tex09.jpg", "", "", ""),//nicetargets 60 mouse
//    Shader("XdfGW4.glsl", "", "", "", ""),//20 nicenodes mouse
//    Shader("ld2Gz3.glsl", "", "", "", ""),//50 mouse niceraytracingshperes
//    Shader("MsjSzz.glsl", "", "", "", ""),//nice 2
//    Shader("Volcanic.glsl", "tex16.png", "tex06.jpg", "tex09.jpg", ""),//nicefuckedlava 10 mouse
//    Shader("Bacterium.glsl", "tex03.jpg", "", "", ""),//nice nomouse 30
//    Shader("Artificial.glsl", "cube04_0.png", "", "", ""),//50 mouse wow3d
//    Shader("Juliabulb.glsl", "", "", "", ""),//10 nice nomouse
//    Shader("Seascape.glsl", "", "", "", ""),//nicefucked 30 mouse
//    Shader("XdlSDs.glsl", "", "", "", ""), //2dnice 60 nomouse
//    Shader("ltS3zd.glsl", "", "", "", ""),//2dok 60 nomouse
//    Shader("ngRay1.glsl", "", "", "", ""),//30 nice nomouse
//    Shader("Generators.glsl", "", "", "", ""),//30 wowcata mouse
//    Shader("Bridge.glsl", "tex00.jpg", "tex09.jpg", "tex16.png", ""),//10 wowfucked mouse
//    Shader("Catacombs.glsl", "", "", "", ""),//20 mouse wowinside
//    Shader("Hand-Drawn Sketch.glsl", "", "", "", ""), //nicecartoon 60 mouse
//    Shader("crystal beacon.glsl", "", "", "", ""), //nomouse 50 wow
//    Shader("MdXSzS.glsl", "", "", "", ""),//nomouse nice 20
//    Shader("Mss3WN.glsl", "", "", "", ""),//nice 30 mouse
//    Shader("ld2GRz.glsl", "cube04_0.png", "", "", ""),//mouse 10 okfucked
//    Shader("4ds3WS.glsl", "tex16.png", "tex01.jpg", "", ""),//10 nicefucked mouse
//    Shader("ldl3DS.glsl", "", "", "", ""),//nomouse 60 nice
//    Shader("MljGzR.glsl", "", "", "", ""),//60 nomouse meh
//    Shader("4tl3RM.glsl", "tex02.jpg", "tex16.png", "cube04_0.png", "cube05_0.png"), //nomouse 15 ok
//    Shader("Msj3zD.glsl", "", "", "", ""),//cool 60 nomouse 2d
//    Shader("4sjXzG.glsl", "tex03.jpg", "tex16.png", "", "tex08.jpg"),//20 nice mouse
//    Shader("XdB3Dw.glsl", "", "", "", ""),//meh 40 nomouse
//    Shader("ldl3zn.glsl", "tex00.jpg", "tex05.jpg", "", ""),//ok mouse 20
//    Shader("llj3Rz.glsl", "tex09.jpg", "", "", ""), //onlymousex 60 nice

//    Shader("lsl3W2.glsl", "cube02_0.jpg", "tex16.png", "", ""),//blank
//    Shader("MdlGz4.glsl", "", "", "", ""),//blank
//    Shader("MdlGz4.glsl", "", "", "", ""),//blank
//    Shader("Msf3z4.glsl", "cube00_0.jpg", "cube01_0.png", "", ""),//blank
//    Shader("4dsGD7.glsl", "", "", "", ""),//blank
//    Shader("Mdf3zr.glsl", "", "", "", ""),//blank
//    Shader("starDust.glsl", "", "", "", ""),//blank

    // Shader("XtS3DD.glsl", "tex16.png", "", "", ""),//iChannelResolution
    // Shader("Grid of Cylinders.glsl", "tex01.jpg", "tex16.png", "tex12.png", "tex05.jpg"),//iChannelResolution
    // Shader("4tsGD7.glsl", "", "", "", ""),//iDate
    // Shader("MtlGWM.glsl", "", "", "", ""),//iDate
    // Shader("lssGRX.glsl", "tex16.png", "", "", ""),//iChannelResolution
    // Shader("Md23Wz.glsl", "tex12.png", "", "", ""),//iChannelResolution
    // Shader("4sB3D1.glsl", "tex08.jpg", "tex16.png", "", ""),//iChannelResolution
    // Shader("XdfXDB.glsl", "tex09.jpg", "tex16.png", "tex12.png", "tex07.jpg"),//iChannelResolution
    // Shader("XsSGDy.glsl", "tex16.png", "tex02.jpg", "", ""),//iChannelResolution
    // Shader("XsXSWN.glsl", "tex00.jpg", "", "cube00_0.jpg", "cube01_0.png"),//iChannelResolution
    // Shader("Xss3DS.glsl", "tex16.png", "", "", ""),//iChannelResolution
    // Shader("MtBGRD.glsl", "", "", "", ""),//kb0 compilerror
    // Shader("4s23WV.glsl", "tex11.png", "", "", ""),//iChannelResolution
    // Shader("leizex.glsl", "", "", "", ""), //good fps, off, iCamera

   Shader("XdlGzH.glsl", "tex04.jpg", "", "", ""),//nomouse 50 streetview

    Shader("Xyptonjtroz.glsl", "", "", "", "")
};
static int shader = 0;

static bool channels_loaded = false;



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
mouse_move_handler (int x, int y) {
    update_mouse_xy(x, y);
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

    default:
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

  glUseProgram (shaders[shader].prog);

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
compile_shader (const GLenum  shader_type,
                const GLchar *shader_source)
{
  GLuint shader = glCreateShader (shader_type);
  GLint status = GL_FALSE;

  glShaderSource (shader, 1, &shader_source, NULL);
  glCompileShader (shader);

  glGetShaderiv (shader, GL_COMPILE_STATUS, &status);
  if (status == GL_TRUE)
    return shader;

  GLint loglen;
  glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &loglen);
  auto msg = new GLchar[loglen]();
  glGetShaderInfoLog(shader, loglen, NULL, msg);
  fprintf (stderr, "shader failed to compile:\n%s\n", msg);
  delete[] msg;

  return -1;
}


GLint
link_program (const std::string& shader_source)
{
  GLint frag, program;
  GLint status = GL_FALSE;
  GLint n_uniforms;

  frag = compile_shader(GL_FRAGMENT_SHADER, shader_source.c_str());
  if (frag < 0)
    return -1;

  program = glCreateProgram ();

  glAttachShader (program, frag);
  glLinkProgram (program);
  // glDeleteShader (frag);

  glGetProgramiv (program, GL_LINK_STATUS, &status);
  if (status != GL_TRUE) {
      GLint loglen;
      glGetProgramiv(program, GL_INFO_LOG_LENGTH, &loglen);
      auto msg = new GLchar[loglen]();
      glGetProgramInfoLog(program, loglen, NULL, msg);
      fprintf (stderr, "program failed to link:\n%s\n", msg);
      delete[] msg;
      return -1;
    }

  glGetProgramiv (program, GL_ACTIVE_UNIFORMS, &n_uniforms);
  fprintf (stderr, "%d uniforms:\n", n_uniforms);

  for (GLint i = 0; i < n_uniforms; i++)
    {
      GLint size;
      GLenum type;
      GLchar name[20];
      GLsizei namelen;

      glGetActiveUniform (program, i, 19, &namelen, &size, &type, name);
      name[namelen] = '\0';
      fprintf (stderr, "  %2d: %-20s (type: 0x%04x, size: %d)\n", i, name, type, size);
    }

  return program;
}

void
init_glew (void)
{
  GLenum status;

  status = glewInit ();

  if (status != GLEW_OK)
    {
      fprintf (stderr, "glewInit error: %s\n", glewGetErrorString (status));
      exit (-1);
    }

  fprintf (stderr,
           "GL_VERSION   : %s\nGL_VENDOR    : %s\nGL_RENDERER  : %s\n"
           "GLEW_VERSION : %s\nGLSL VERSION : %s\n\n",
           glGetString (GL_VERSION), glGetString (GL_VENDOR),
           glGetString (GL_RENDERER), glewGetString (GLEW_VERSION),
           glGetString (GL_SHADING_LANGUAGE_VERSION));

  if (!GLEW_VERSION_2_1)
    {
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
    str = std::regex_replace(str, coms, "\n");

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
    glutMotionFunc(mouse_move_handler);
    glutKeyboardFunc(keyboard_handler);
    glutSpecialFunc(kb_arrows);

    redisplay(1000/60);

    glutMainLoop();

    return 0;
}
