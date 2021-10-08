// Inspired from Box3d //code.google.com/p/ehci/

#ifdef __APPLE__
# include <GLUT/glut.h>
#else
# include <GL/glut.h>
#endif

#include "nvr.hh"


#define NAME "nvr_boxes"
#define winWidth  640
#define winHeight 480

// Shared memory between the 2 main loops
nvr::UniVR ovr;
nvr::data  data;

GLfloat xrot;   // x rotation
GLfloat yrot;   // y rotation
GLfloat xspeed; // x rotation speed
GLfloat yspeed; // y rotation speed

GLfloat z = -5.0f; // depth into the screen.

/* white ambient light at half intensity (rgba) */
GLfloat LightAmbient[]  = { 0.5f, 0.5f, 0.5f, 1.0f };
/* super bright, full intensity diffuse light. */
GLfloat LightDiffuse[]  = { 1.0f, 1.0f, 1.0f, 1.0f };
/* position of light (x, y, z, (position of light)) */
GLfloat LightPosition[] = { 0.0f, 2.0f, 0.0f, 1.0f };

int window;
bool light; // Lighting on/off (false is off)
bool fullscreen = false; // Full screen on/off (true is on)
GLuint texture; // Holds loaded texture

size_t dropper = 0;


void DrawGLScene () {
    double t = (double)cvGetTickCount();
    ++dropper;
    if (10*dropper == 20) {
        ovr.step(data);
        dropper = 0;
    } else
        std::cout << "\treusing" << std::endl;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Clear scene & depthb
    glLoadIdentity();  // Reset The View

    //printf("X %lf\tY %lf\tZ %lf\n", data.eyeX,data.eyeY,data.eyeZ);//
    gluLookAt(data.eyeX, data.eyeY, data.eyeZ,
              0, 0, 0, 0, 1, 0); //+ 5*headDist

    glTranslatef(0.0f, 0.0f, -1);  // Move z units out from the screen

    glRotatef(xrot, 1.0f, 0.0f, 0.0f);  // Rotate On The X Axis
    glRotatef(yrot, 0.0f, 1.0f, 0.0f);  // Rotate On The Y Axis

    glBindTexture(GL_TEXTURE_2D, texture);

    glBegin(GL_QUADS);  // begin drawing a cube

    // Front Face (note that the texture's corners have to match the quad's)
    glNormal3f( 0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Left

    // Back Face
    glNormal3f( 0.0f, 0.0f,-1.0f);  // back face points into the screen on z
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Left

    // Top Face
    glNormal3f( 0.0f, 1.0f, 0.0f);  // top face points up on y
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right

    // Bottom Face
    glNormal3f( 0.0f, -1.0f, 0.0f);  // bottom face points down on y
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right

    // Right face
    glNormal3f( 1.0f, 0.0f, 0.0f);  // right face points right on x
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left

    // Left Face
    glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left

    glEnd();  // done with the polygon

    glTranslatef(-3.0f, 0.0f, 0);  // Move z units out from the screen

    glBegin(GL_QUADS);  // begin drawing a cube

    // Front Face (note that the texture's corners have to match the quad's)
    glNormal3f( 0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Left

    // Back Face
    glNormal3f( 0.0f, 0.0f,-1.0f);  // back face points into the screen on z
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Left

    // Top Face
    glNormal3f( 0.0f, 1.0f, 0.0f);  // top face points up on y
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right

    // Bottom Face
    glNormal3f( 0.0f, -1.0f, 0.0f);  // bottom face points down on y
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right

    // Right face
    glNormal3f( 1.0f, 0.0f, 0.0f);  // right face points right on x
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left

    // Left Face
    glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left

    glEnd();  // done with the polygon

    glTranslatef(+6.0f, 0.0f, 0);  // Move z units out from the screen

    glBegin(GL_QUADS);  // begin drawing a cube

    // Front Face (note that the texture's corners have to match the quad's)
    glNormal3f( 0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Left

    // Back Face
    glNormal3f( 0.0f, 0.0f,-1.0f);  // back face points into the screen on z
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Left

    // Top Face
    glNormal3f( 0.0f, 1.0f, 0.0f);  // top face points up on y
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right

    // Bottom Face
    glNormal3f( 0.0f, -1.0f, 0.0f);  // bottom face points down on y
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right

    // Right face
    glNormal3f( 1.0f, 0.0f, 0.0f);  // right face points right on x
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left

    // Left Face
    glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left

    glEnd();  // done with the polygon

    glTranslatef(0.0f, 0.0f, 3.0);  // Move z units out from the screen

    glBegin(GL_QUADS);  // begin drawing a cube

    // Front Face (note that the texture's corners have to match the quad's)
    glNormal3f( 0.0f, 0.0f, 1.0f);  // front face points out of the screen on z
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Left

    // Back Face
    glNormal3f( 0.0f, 0.0f,-1.0f);  // back face points into the screen on z
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Left

    // Top Face
    glNormal3f( 0.0f, 1.0f, 0.0f);  // top face points up on y
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right

    // Bottom Face
    glNormal3f( 0.0f, -1.0f, 0.0f);  // bottom face points down on y
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right

    // Right face
    glNormal3f( 1.0f, 0.0f, 0.0f);  // right face points right on x
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);	// Top Left
    glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);	// Bottom Left

    // Left Face
    glNormal3f(-1.0f, 0.0f, 0.0f);  // left face points left on x
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);	// Bottom Left
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);	// Bottom Right
    glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);	// Top Right
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);	// Top Left

    glEnd();  // done with the polygon

    xrot += xspeed;  // X Axis Rotation
    yrot += yspeed;  // Y Axis Rotation

    // Double buffered => swap the buffers to display what just got drawn
    glutSwapBuffers();

    t = (double)cvGetTickCount() - t;
    printf("\tframe time = %gms\n", t/((double)cvGetTickFrequency()*1000.));
}

GLuint LoadTexture (const std::string& bmp) {
    //stackoverflow.com/a/12524013/1418165
    GLuint tex;
    int tWidth = 256, tHeight = 256, tSize = tWidth * tHeight * 3;
    unsigned char *data = NULL;
    FILE *fd = NULL;

    if ((fd = fopen(bmp.c_str(), "rb")) == NULL) {
        std::cerr << "!file " << bmp << std::endl;
        fclose(fd);
        exit(2);
    }
    if ((data = (unsigned char *)malloc(tSize)) == NULL) {
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
    for (int i = 0; i < tWidth*tHeight; ++i) {  // Turn BGR into RGB
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
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, tWidth, tHeight, GL_RGB,
                      GL_UNSIGNED_BYTE, data);
    free(data);
    return tex; // Not directly used but works (weird)
}

void InitGL (const std::string& bmp, GLsizei Width, GLsizei Height) {
    LoadTexture(bmp);
    glBindTexture(GL_TEXTURE_2D, texture);
    glEnable(GL_TEXTURE_2D);              // Enable texture mapping.

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // Black background color
    glClearDepth(1.0);                    // Clears depth buffer
    glDepthFunc(GL_LESS);                 // The Type Of Depth Test To Do
    glEnable(GL_DEPTH_TEST);              // Enables Depth Testing
    glShadeModel(GL_SMOOTH);              // Enables Smooth Color Shading

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();	                  // Reset The Projection Matrix

    // Calculate aspect ratio of window
    gluPerspective(45.0f, (GLfloat)Width / (GLfloat)Height, 0.1f, 100.0f);

    glMatrixMode(GL_MODELVIEW);

    // set up light number 1.
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);  // add lighting (ambient)
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);  // add lighting (diffuse).
    glLightfv(GL_LIGHT1, GL_POSITION,LightPosition); // set light position
    glEnable(GL_LIGHT1);                             // turn light 1 on
    light = true;
    glEnable(GL_LIGHTING);
}

void ReSizeGLScene (GLsizei Width, GLsizei Height) {
    if (Height == 0)
	Height = 1;
    glViewport(0, 0, Width, Height); // Reset curr viewport & perspec transform
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0f, (GLfloat)Width / (GLfloat)Height, 0.1f, 100.0f);
    glMatrixMode(GL_MODELVIEW);
}

void
toggle_fullscreen () {
    fullscreen = !fullscreen;
    if (!fullscreen) {
        glutSetCursor(GLUT_CURSOR_INHERIT);
        glutPositionWindow(0, 0);
        glutReshapeWindow(winWidth, winHeight);
    } else {
        glutSetCursor(GLUT_CURSOR_NONE);
        glutFullScreen();
    }
}

void
keyPressed (unsigned char key, int, int) {
    switch (key) {
    case 'l':
    case 'L': // Toggle lighting
	light = !light;
	(!light) ? glDisable(GL_LIGHTING) : glEnable(GL_LIGHTING);
	break;
    case 'f':
    case 'F':
        toggle_fullscreen();
        break;
    case ' ': // = 32
        std::cout << "got SPACE" << std::endl;
    case 'R':
    case 'r':
        ovr.detect_now();
        break;
    case 'q':
    case 27: // ESCAPE
	glutDestroyWindow(window);
	exit(0);
    }
}

void
specialKeyPressed (int key, int, int) {
    switch (key) {
    case GLUT_KEY_PAGE_UP: // move the cube into the distance.
	z -= 0.02f;
	break;
    case GLUT_KEY_PAGE_DOWN: // move the cube closer.
	z += 0.02f;
	break;
    case GLUT_KEY_UP: // decrease x rotation speed;
	xspeed -= 0.01f;
	break;
    case GLUT_KEY_DOWN: // increase x rotation speed;
	xspeed += 0.01f;
	break;
    case GLUT_KEY_LEFT: // decrease y rotation speed;
	yspeed -= 0.01f;
	break;
    case GLUT_KEY_RIGHT: // increase y rotation speed;
	yspeed += 0.01f;
	break;
    }
}

int
main (int argc, char *argv[]) {
    glutInit(&argc, argv);

    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH);
    glutInitWindowSize(winWidth, winHeight);
    glutInitWindowPosition(0, 0);
    window = glutCreateWindow(NAME);
    glutDisplayFunc(&DrawGLScene);
    //toggle_fullscreen();
    glutIdleFunc(&DrawGLScene); // Redraw even when no events
    glutReshapeFunc(&ReSizeGLScene);
    glutKeyboardFunc(&keyPressed);
    glutSpecialFunc(&specialKeyPressed);

    InitGL("data/crate.bmp", winWidth, winHeight);

    ovr.init();  // UniVR init

    glutMainLoop();
    return 0;
}
