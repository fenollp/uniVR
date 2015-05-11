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
#include <string.h>
#include <getopt.h>
#include <poll.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <GL/glew.h>
#ifdef __APPLE_CC__
# define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
# include <OpenGL/gl3.h>
# include <OpenGL/glu.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#include <GLUT/glut.h>
#else
# include <GL/gl.h>
# include <GL/glu.h>

#include <GL/glut.h>
#include <GL/freeglut_ext.h>
#endif

#include <FreeImage.h>

#ifdef __MACH__
# include <mach/clock.h>
# include <mach/mach.h>
#endif

/* width, height, x0, y0 (top left) */
static double geometry[4] = { 0, };

/* x, y, x_press, y_press  (in target coords) */
static double mouse[4] = { 0, };

static int window_x0 = -1;
static int window_y0 = -1;
static int window_width = -1;
static int window_height = -1;

static GLint prog = 0;
static GLenum tex[4];
static int sockfd  = -1;

#define IPC_ADDR (0x7f000000)
#define IPC_PORT (4242)

void ipc_socket_handle_message (void);
void ipc_socket_send_message (char *msg);

void
mouse_press_handler (int button, int state, int x, int y)
{
  char msg[1000];
  int x0, y0, height;

  if (button != GLUT_LEFT_BUTTON)
    return;

  if (state == GLUT_DOWN)
    {
      x0     = glutGet (GLUT_WINDOW_X);
      y0     = glutGet (GLUT_WINDOW_Y);
      height = glutGet (GLUT_WINDOW_HEIGHT);

      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        {
          mouse[2] = mouse[0] =               geometry[2] + x0 + x;
          mouse[3] = mouse[1] = geometry[1] - geometry[3] - y0 - y;
        }
      else
        {
          mouse[2] = mouse[0] = x;
          mouse[3] = mouse[1] = height - y;
        }
    }
  else
    {
      mouse[2] = -1;
      mouse[3] = -1;
    }

  snprintf (msg, sizeof (msg), "iMouse:%.0f,%.0f,%.0f,%.0f",
            mouse[0], mouse[1], mouse[2], mouse[3]);
  ipc_socket_send_message (msg);
}


void
mouse_move_handler (int x, int y)
{
  char msg[1000];
  int x0, y0, height;

      x0     = glutGet (GLUT_WINDOW_X);
      y0     = glutGet (GLUT_WINDOW_Y);
      height = glutGet (GLUT_WINDOW_HEIGHT);

      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        {
          mouse[0] =               geometry[2] + x0 + x;
          mouse[1] = geometry[1] - geometry[3] - y0 - y;
        }
      else
        {
          mouse[0] = x;
          mouse[1] = height - y;
        }

  snprintf (msg, sizeof (msg), "iMouse:%.0f,%.0f,%.0f,%.0f",
            mouse[0], mouse[1], mouse[2], mouse[3]);
  ipc_socket_send_message (msg);
}


void
keyboard_handler (unsigned char key, int x, int y)
{
  switch (key)
    {
      case '\x1b':  /* Escape */
      case 'q':
      case 'Q':
        /* glutLeaveMainLoop (); */
          exit(0);
        break;

      case 'f': /* fullscreen */
      case 'F':
        /* glutFullScreenToggle (); */
          if (window_width < 0)
          {
              window_x0 = glutGet (GLUT_WINDOW_X);
              window_y0 = glutGet (GLUT_WINDOW_Y);
              window_width = glutGet (GLUT_WINDOW_WIDTH);
              window_height = glutGet (GLUT_WINDOW_HEIGHT);
              glutFullScreen ();
          }
          else
          {
              glutPositionWindow (window_x0, window_y0);
              glutReshapeWindow (window_width, window_height);
              window_width = -1;
          }
          break;

      default:
        break;
    }
}


void
redisplay (int value)
{
  struct pollfd udp;
  int ret;

  udp.fd = sockfd;
  udp.events = POLLIN;

  while ((ret = poll (&udp, 1, 0)) >= 1)
    {
      ipc_socket_handle_message ();
    }

  glutPostRedisplay ();
  glutTimerFunc (value, redisplay, value);
}


void
display (void)
{
  static int frames, last_time;
  int x0, y0, width, height, ticks;
  GLint uindex;
#ifdef __MACH__
  /// https://github.com/SIPp/sipp/pull/104/files
  // OS X does not have clock_gettime, use clock_get_time
  clock_serv_t cclock;
  mach_timespec_t mts;
#endif
  struct timespec ts;

  glUseProgram (prog);

  x0     = glutGet (GLUT_WINDOW_X);
  y0     = glutGet (GLUT_WINDOW_Y);
  width  = glutGet (GLUT_WINDOW_WIDTH);
  height = glutGet (GLUT_WINDOW_HEIGHT);
#ifdef __MACH__
  host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
  clock_get_time(cclock, &mts);
  mach_port_deallocate(mach_task_self(), cclock);
  ts.tv_sec = mts.tv_sec;
  ts.tv_nsec = mts.tv_nsec;
#else
  clock_gettime (CLOCK_MONOTONIC_RAW, &ts);
#endif
  ticks  = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;

  if (frames == 0)
    last_time = ticks;

  frames++;

  if (ticks - last_time >= 5000)
    {
      fprintf (stderr, "FPS: %.2f\n", 1000.0 * frames / (ticks - last_time));
      frames = 0;
    }

  uindex = glGetUniformLocation (prog, "iGlobalTime");
  if (uindex >= 0)
    glUniform1f (uindex, ((float) ticks) / 1000.0);

  uindex = glGetUniformLocation (prog, "time");
  if (uindex >= 0)
    glUniform1f (uindex, ((float) ticks) / 1000.0);

  uindex = glGetUniformLocation (prog, "iResolution");
  if (uindex >= 0)
    {
      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        glUniform3f (uindex, geometry[0], geometry[1], 1.0);
      else
        glUniform3f (uindex, width, height, 1.0);
    }

  uindex = glGetUniformLocation (prog, "iOffset");
  if (uindex >= 0)
    {
      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        {
          glUniform2f (uindex,
                       x0 + geometry[2],
                       geometry[1] - (y0 + height) - geometry[3]);
        }
      else
        {
          glUniform2f (uindex, 0.0, 0.0);
        }
    }

  uindex = glGetUniformLocation (prog, "iMouse");
  if (uindex >= 0)
    glUniform4f (uindex, mouse[0],  mouse[1], mouse[2], mouse[3]);


  uindex = glGetUniformLocation (prog, "iChannel0");
  if (uindex >= 0)
    {
      glActiveTexture (GL_TEXTURE0 + 0);
      glBindTexture (GL_TEXTURE_2D, tex[0]);
      glUniform1i (uindex, 0);
    }

  uindex = glGetUniformLocation (prog, "iChannel1");
  if (uindex >= 0)
    {
      glActiveTexture (GL_TEXTURE0 + 1);
      glBindTexture (GL_TEXTURE_2D, tex[1]);
      glUniform1i (uindex, 1);
    }

  uindex = glGetUniformLocation (prog, "iChannel2");
  if (uindex >= 0)
    {
      glActiveTexture (GL_TEXTURE0 + 2);
      glBindTexture (GL_TEXTURE_2D, tex[1]);
      glUniform1i (uindex, 2);
    }

  uindex = glGetUniformLocation (prog, "iChannel3");
  if (uindex >= 0)
    {
      glActiveTexture (GL_TEXTURE0 + 3);
      glBindTexture (GL_TEXTURE_2D, tex[1]);
      glUniform1i (uindex, 3);
    }

  uindex = glGetUniformLocation (prog, "resolution");
  if (uindex >= 0)
    {
      if (geometry[0] > 0.1 && geometry[1] > 0.1)
        glUniform2f (uindex, geometry[0], geometry[1]);
      else
        glUniform2f (uindex, width, height);
    }

  uindex = glGetUniformLocation (prog, "led_color");
  if (uindex >= 0)
    glUniform3f (uindex, 0.5, 0.3, 0.8);

  glClear (GL_COLOR_BUFFER_BIT);
  glRectf (-1.0, -1.0, 1.0, 1.0);

  glutSwapBuffers ();
}

int
load_texture (const char *filename,
              GLenum     *tex_id,
              char        nearest,
              char        repeat)
{
    FREE_IMAGE_FORMAT format = FreeImage_GetFileType(filename, 0);
    if (format == -1)
        format = FreeImage_GetFIFFromFilename(filename);
    if (!FreeImage_FIFSupportsReading(format)) {
        fprintf(stderr, "!read texture format %s\n", filename);
        return 0;
    }

    FIBITMAP* bitmap = FreeImage_Load(format, filename, 0);
    if (bitmap == NULL) {
        fprintf(stderr, "!file %s\n", filename);
        return 0;
    }
    int bitsPerPixel = FreeImage_GetBPP(bitmap);
    FIBITMAP* bitmap32 = NULL;
    if (bitsPerPixel == 32)
        bitmap32 = bitmap;
    else
        bitmap32 = FreeImage_ConvertTo32Bits(bitmap); // --> RGBa

    int imageWidth  = FreeImage_GetWidth(bitmap32);
    int imageHeight = FreeImage_GetHeight(bitmap32);
    // We don't need to delete or delete[] this textureData because it's not on the heap
    GLubyte* textureData = FreeImage_GetBits(bitmap32);
    glGenTextures(1, tex_id);
    glBindTexture(GL_TEXTURE_2D, *tex_id);
    // Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
    // BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.

    GLfloat *tex_data = NULL;
    tex_data = (GLfloat *) malloc(imageWidth * imageHeight * 4 * sizeof (GLfloat));
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
                 /* GL_BGRA,          // Data format */
                 GL_RGBA,
                 //GL_RGB |||| GL_RGBA
                 /* GL_UNSIGNED_BYTE, // Type of texture data */
                 GL_FLOAT,
                 /* textureData);     // The image data to use for this texture */
                 tex_data);

    if (nearest) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    if (repeat) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    }

    switch (glGetError()) {
    case GL_NO_ERROR:
        break;
    case GL_INVALID_ENUM:
        fprintf(stderr, "!gl enum %s\n", filename);
        return 0;
    case GL_INVALID_VALUE:
        fprintf(stderr, "!gl value %s\n", filename);
        return 0;
    case GL_INVALID_OPERATION:
        fprintf(stderr, "!gl operation %s\n", filename);
        return 0;
    default:
        fprintf(stderr, "!GL_ENUM %s\n", filename);
        return 0;
    }

    free(tex_data);
    FreeImage_Unload(bitmap32);
    if (bitsPerPixel != 32)
        FreeImage_Unload(bitmap);

    fprintf(stdout, "texture: %s, %dx%d, (%d) --> id %d\n",
            filename, imageWidth, imageHeight, bitsPerPixel, *tex_id);
    return 1;
}


GLint
compile_shader (const GLenum  shader_type,
                const GLchar *shader_source)
{
  GLuint shader = glCreateShader (shader_type);
  GLint status = GL_FALSE;
  GLint loglen;
  GLchar *error_message;

  glShaderSource (shader, 1, &shader_source, NULL);
  glCompileShader (shader);

  glGetShaderiv (shader, GL_COMPILE_STATUS, &status);
  if (status == GL_TRUE)
    return shader;

  glGetShaderiv (shader, GL_INFO_LOG_LENGTH, &loglen);
  error_message = (char *) calloc (loglen, sizeof (GLchar));
  glGetShaderInfoLog (shader, loglen, NULL, error_message);
  fprintf (stderr, "shader failed to compile:\n   %s\n", error_message);
  free (error_message);

  return -1;
}


GLint
link_program (const GLchar *shader_source)
{
  GLint frag, program;
  GLint status = GL_FALSE;
  GLint loglen, n_uniforms;
  GLchar *error_message;
  GLint i;

  GLchar name[80];
  GLsizei namelen;

  frag = compile_shader (GL_FRAGMENT_SHADER, shader_source);
  if (frag < 0)
    return -1;

  program = glCreateProgram ();

  glAttachShader (program, frag);
  glLinkProgram (program);
  // glDeleteShader (frag);

  glGetProgramiv (program, GL_LINK_STATUS, &status);
  if (status != GL_TRUE)
    {
      glGetProgramiv (program, GL_INFO_LOG_LENGTH, &loglen);
      error_message = (char *) calloc (loglen, sizeof (GLchar));
      glGetProgramInfoLog (program, loglen, NULL, error_message);
      fprintf (stderr, "program failed to link:\n   %s\n", error_message);
      free (error_message);
      return -1;
    }

  /* diagnostics */
  glGetProgramiv (program, GL_ACTIVE_UNIFORMS, &n_uniforms);
  fprintf (stderr, "%d uniforms:\n", n_uniforms);

  for (i = 0; i < n_uniforms; i++)
    {
      GLint size;
      GLenum type;

      glGetActiveUniform (program, i, 79, &namelen, &size, &type, name);
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


char *
load_file (char *filename)
{
  FILE *f;
  int size;
  char *data;

  f = fopen (filename, "rb");
  if (f == NULL)
    {
      perror ("error opening file");
      return NULL;
    }

  fseek (f, 0, SEEK_END);
  size = ftell (f);
  fseek (f, 0, SEEK_SET);

  data = (char *) malloc (size + 1);
  if (fread (data, size, 1, f) < 1)
    {
      fprintf (stderr, "problem reading file %s\n", filename);
      free (data);
      return NULL;
    }
  fclose(f);

  data[size] = '\0';

  return data;
}


void
ipc_socket_send_message (char *msg)
{
  struct sockaddr_in servaddr;

  bzero (&servaddr, sizeof (servaddr));
  servaddr.sin_family      = AF_INET;
  servaddr.sin_addr.s_addr = htonl (IPC_ADDR);
  servaddr.sin_port        = htons (IPC_PORT);

  sendto (sockfd, msg ,strlen (msg), 0,
          (struct sockaddr *) &servaddr, sizeof(servaddr));
}


void
ipc_socket_handle_message (void)
{
  char msg[1000];
  int len;
  char *pos, *token;

  len = recvfrom (sockfd, msg, sizeof (msg) - 1, 0, NULL, NULL);

  msg[len] = '\0';

  pos = msg;
  token = strsep (&pos, ":");

  if (strcmp (token, "iMouse") == 0)
    {
      int i = 0;

      for (i = 0; i < 4; i++)
        {
          token = strsep (&pos, ",");
          if (!token)
            break;
          mouse[i] = atof (token);
        }
    }
}


int
ipc_socket_open (int port)
{
  struct sockaddr_in servaddr;
  int ret;
  int flag = 1;

  sockfd = socket (AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0)
    perror ("socket");

  setsockopt (sockfd, SOL_SOCKET, SO_REUSEPORT, (char*) &flag, sizeof (flag));
  setsockopt (sockfd, SOL_SOCKET, SO_BROADCAST, (char*) &flag, sizeof (flag));

  bzero (&servaddr, sizeof (servaddr));
  servaddr.sin_family      = AF_INET;
  servaddr.sin_addr.s_addr = htonl (IPC_ADDR);
  servaddr.sin_port        = htons (port);

  ret = bind (sockfd, (struct sockaddr *) &servaddr, sizeof (servaddr));
  if (ret < 0)
    perror ("bind");

  return sockfd;
}


int
main (int   argc,
      char *argv[])
{
  char *frag_code = NULL;
  glutInit (&argc, argv);

  static struct option long_options[] = {
      { "texture",  required_argument, NULL,  't' },
      { "geometry", required_argument, NULL,  'g' },
      { "help",     no_argument, NULL,        'h' },
      { 0,          0,                 NULL,  0   }
  };

  glutInitWindowSize (800, 600);
  glutInitDisplayMode (GLUT_RGBA | GLUT_DOUBLE);
  glutCreateWindow ("Shadertoy");

  init_glew ();

  /* option parsing */
  while (1)
    {
      int c, slot, i;
      char nearest, repeat;

      c = getopt_long (argc, argv, ":t:g:?", long_options, NULL);
      if (c == -1)
        break;

      switch (c)
        {
          case 'g':
            for (i = 0; i < 4; i++)
              {
                char *token = strsep (&optarg, "x+");
                if (!token)
                  break;
                geometry[i] = atof (token);
              }

            fprintf (stderr, "geometry: %.0fx%.0f+%.0f+%.0f\n",
                     geometry[0], geometry[1], geometry[2], geometry[3]);
            break;

          case 't':
            if (optarg[0] <  '0' || optarg[0] >  '3' || strchr (optarg, ':') == NULL)
              {
                fprintf (stderr, "Argument for texture file needs a slot from 0 to 3\n");
                exit (1);
              }

            slot = optarg[0] - '0';

            repeat = 1;
            nearest = 0;

            for (c = 1; optarg[c] != ':' && optarg[c] != '\0'; c++)
              {
                switch (optarg[c])
                  {
                    case 'r':
                      repeat = 1;
                      break;
                    case 'o':
                      repeat = 0;
                      break;
                    case 'i':
                      nearest = 0;
                      break;
                    case 'n':
                      nearest = 1;
                      break;
                    default:
                      break;
                  }
              }

            FreeImage_Initialise(FALSE);
            if (optarg[c] != ':'
                || !load_texture(optarg+c+1, &tex[slot], nearest, repeat))
              {
                fprintf (stderr, "Failed to load texture. Aborting.\n");
                exit (1);
              }
            FreeImage_DeInitialise();
            break;

          case 'h':
          case ':':
          default:
            fprintf (stderr, "Usage:\n  %s [options] <shaderfile>\n", argv[0]);
            fprintf (stderr, "Options:    --help\n");
            fprintf (stderr, "            --texture [0-3]:<textureimage>\n");
            exit (c == ':' ? 1 : 0);
            break;
        }
    }

  if (optind != argc - 1)
    {
      fprintf (stderr, "No shaderfile specified. Aborting.\n");
      exit (-1);
    }

  frag_code = load_file (argv[optind]);
  if (!frag_code)
    {
      fprintf (stderr, "Failed to load Shaderfile. Aborting.\n");
      exit (-1);
    }

  prog = link_program (frag_code);
  if (prog < 0)
    {
      fprintf (stderr, "Failed to link shader program. Aborting\n");
      exit (-1);
    }

  ipc_socket_open (IPC_PORT);

  glutDisplayFunc  (display);
  glutMouseFunc    (mouse_press_handler);
  glutMotionFunc   (mouse_move_handler);
  glutKeyboardFunc (keyboard_handler);

  redisplay (1000/60);

  glutMainLoop ();

  return 0;
}

