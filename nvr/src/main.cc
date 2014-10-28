#if 0
#include "nvr.hh"
int
main (int argc, const char* argv[]) {
    try {
        if (argc == 1) {
            std::cout << "Call this program like this:" << std::endl
                      << "./nvr 68_face_landmarks.dat" << std::endl;
            return 1;
        }
        std::string trained(argv[1]);
        nvr::UniVR ovr;
        ovr.init(trained);
        nvr::data face;
        while (true) { // GAME LOOP
            if (!ovr.step(face))
                break;
            std::cout << face;//
            if (cv::waitKey(5) == 'q')
                break;
        }
    }
    catch (std::exception& e) {
        std::cout << std::endl << "exception thrown!"
                  << std::endl << e.what() << std::endl;
    }
}
#endif


// //www.cs.umd.edu/class/spring2013/cmsc425/OpenGL/OpenGLSamples/OpenGL-3D-Sample/OpenGL-3D-Sample-ForC/opengl-3D-sample.c

#include <stdlib.h>
#include <math.h>
#include <stdio.h>

#ifdef __APPLE__
# include <GLUT/glut.h>
#else
# include <GL/glut.h>
#endif

// Pipe stuff
#include <unistd.h>
#include <sys/wait.h> // Actually..

// Shared mem stuff
#include <sys/shm.h>

#include "nvr.hh"

#define DEMO "demo2"
#define PROJECT "snowmen"
#define WIN_SZ_Y 800
#define WIN_SZ_X 400

//----------------------------------------------------------------------
// Global variables
//
// The coordinate system is set up so that the (x,y)-coordinate plane
// is the ground, and the z-axis is directed upwards. The y-axis points
// to the north and the x-axis points to the east.
//
// The values (x,y) are the current camera position. The values (lx, ly)
// point in the direction the camera is looking. The variables angle and
// deltaAngle control the camera's angle. The variable deltaMove
// indicates the amount of incremental motion for the camera with each
// redraw cycle. The variables isDragging and xDragStart are used to
// monitor the mouse when it drags (with the left button down).
//----------------------------------------------------------------------

// Camera position
float x = 0.0, y = -5.0; // initially 5 units south of origin
float deltaMove = 0.0; // initially camera doesn't move

// Camera direction
float lx = 0.0, ly = 1.0; // camera points initially along y-axis
float angle = 0.0; // angle of rotation for the camera direction
float deltaAngle = 0.0; // additional angle change when dragging

// Mouse drag control
int isDragging = 0; // true when dragging
int xDragStart = WIN_SZ_X; // records the x-coordinate when dragging starts

// Shared memory between the 2 main loops
nvr::UniVR ovr;
nvr::data  data;

// Previous value of norm, so as to extract a differential
int norm_;

//----------------------------------------------------------------------
// Reshape callback
//
// Window size has been set/changed to w by h pixels. Set the camera
// perspective to 45 degree vertical field of view, a window aspect
// ratio of w/h, a near clipping plane at depth 1, and a far clipping
// plane at depth 100. The viewport is the entire window.
//
//----------------------------------------------------------------------
void
changeSize (int w, int h)
{
    float ratio =  ((float) w) / ((float) h); // window aspect ratio
    glMatrixMode(GL_PROJECTION); // projection matrix is active
    glLoadIdentity(); // reset the projection
    gluPerspective(45.0, ratio, 0.1, 100.0); // perspective transformation
    glMatrixMode(GL_MODELVIEW); // return to modelview mode
    glViewport(0, 0, w, h); // set viewport (drawing area) to entire window
}

//----------------------------------------------------------------------
// Draw one snowmen (at the origin)
//
// A snowman consists of a large body sphere and a smaller head sphere.
// The head sphere has two black eyes and an orange conical nose. To
// better create the impression they are sitting on the ground, we draw
// a fake shadow, consisting of a dark circle under each.
//
// We make extensive use of nested transformations. Everything is drawn
// relative to the origin. The snowman's eyes and nose are positioned
// relative to a head sphere centered at the origin. Then the head is
// translated into its final position. The body is drawn and translated
// into its final position.
//----------------------------------------------------------------------
void
drawSnowman ()
{
    // Draw body (a 20x20 spherical mesh of radius 0.75 at height 0.75)
    glColor3f(1.0, 1.0, 1.0); // set drawing color to white
    glPushMatrix();
        glTranslatef(0.0, 0.0, 0.75);
        glutSolidSphere(0.75, 20, 20);
    glPopMatrix();

    // Draw the head (a sphere of radius 0.25 at height 1.75)
    glPushMatrix();
        glTranslatef(0.0, 0.0, 1.75); // position head
        glutSolidSphere(0.25, 20, 20); // head sphere

        // Draw Eyes (two small black spheres)
        glColor3f(0.0, 0.0, 0.0); // eyes are black
        glPushMatrix();
            glTranslatef(0.0, -0.18, 0.10); // lift eyes to final position
            glPushMatrix();
                glTranslatef(-0.05, 0.0, 0.0);
                glutSolidSphere(0.05, 10, 10); // right eye
            glPopMatrix();
            glPushMatrix();
		glTranslatef(+0.05, 0.0, 0.0);
                glutSolidSphere(0.05, 10, 10); // left eye
            glPopMatrix();
        glPopMatrix();

	// Draw Nose (the nose is an orange cone)
	glColor3f(1.0, 0.5, 0.5); // nose is orange
	glPushMatrix();
            glRotatef(90.0, 1.0, 0.0, 0.0); // rotate to point along -y
            glutSolidCone(0.08, 0.5, 10, 2); // draw cone
        glPopMatrix();
    glPopMatrix();

    // Draw a faux shadow beneath snow man (dark green circle)
    glColor3f(0.0, 0.5, 0.0);
    glPushMatrix();
        glTranslatef(0.2, 0.2, 0.001);	// translate to just above ground
        glScalef(1.0, 1.0, 0.0); // scale sphere into a flat pancake
        glutSolidSphere(0.75, 20, 20); // shadow same size as body
    glPopMatrix();
}

//----------------------------------------------------------------------
// Update with each idle event
//
// This incrementally moves the camera and requests that the scene be
// redrawn.
//----------------------------------------------------------------------
void
update (void) {
    if (ovr.step(data))
        std::cout << data;

    if (deltaMove) { // update camera position
        x += deltaMove * lx * 0.1;
        y += deltaMove * ly * 0.1;
    }
    glutPostRedisplay(); // redisplay everything

    std::cout << "lx:" << lx << " "
              << "ly:" << ly << " "
              << "x:"  <<  x << " "
              << "y:"  <<  y << " "
              << "deltaMove:" << deltaMove << " "
              << "angle:" << angle << " "
              << "deltaAngle:" << deltaAngle << " "
              << std::endl;
}

//----------------------------------------------------------------------
// Draw the entire scene
//
// We first update the camera location based on its distance from the
// origin and its direction.
//----------------------------------------------------------------------
void
renderScene (void)
{
    // Clear color and depth buffers
    glClearColor(0.0, 0.7, 1.0, 1.0); // sky color is light blue
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Reset transformations
    glLoadIdentity();

    // Set the camera centered at (x,y,1) and looking along directional
    // vector (lx, ly, 0), with the z-axis pointing up
    gluLookAt(x,      y,      1.0,
              x + lx, y + ly, 1.0,
              0.0,    0.0,    1.0);

    // Draw ground - 200x200 square colored green
    glColor3f(0.0, 0.7, 0.0);
    glBegin(GL_QUADS);
        glVertex3f(-100.0, -100.0, 0.0);
        glVertex3f(-100.0,  100.0, 0.0);
        glVertex3f( 100.0,  100.0, 0.0);
        glVertex3f( 100.0, -100.0, 0.0);
    glEnd();

    // Draw 36 snow men
    for (int i = -3; i < 3; i++)
        for (int j = -3; j < 3; j++) {
            glPushMatrix();
                glTranslatef(i*7.5, j*7.5, 0);
                drawSnowman();
            glPopMatrix();
        }

    glutSwapBuffers(); // Make it all visible
}

//----------------------------------------------------------------------
// User-input callbacks
//
// processNormalKeys: ESC, q, and Q cause program to exit
// pressSpecialKey: Up arrow = forward motion, down arrow = backwards
// releaseSpecialKey: Set incremental motion to zero
//----------------------------------------------------------------------
void
processNormalKeys (unsigned char key, int xx, int yy)
{
    if ('\e' == key || 'q' == key || 'Q' == key)
        exit(0);

    // printf("[MASTER] Received (%i %i %f %f)\n",
    //        lvrs->cx, lvrs->cy, lvrs->norm, lvrs->alpha);

    // int cx = lvrs->cx + 200;
    // if (cx > 600) cx = 1 + xDragStart;//
    // deltaAngle = 0.005 * (cx - xDragStart);
    // lx = - sin(angle + deltaAngle);
    // ly =   cos(angle + deltaAngle);
    // printf("MOI %i %f  %f %f\n", cx, deltaAngle, lx, ly);
    // // xDragStart = cx;
    // // angle += deltaAngle;

    // EXPERIMENTAL y translation
    // int norm = lvrs->norm;
    // if (0 == norm_) norm_ = norm;
    // deltaMove = (norm_ - norm) / (norm_ - norm + 1);
}

void
pressSpecialKey (int key, int xx, int yy)
{
    switch (key) {
        case GLUT_KEY_UP   : deltaMove =  1.0; break;
        case GLUT_KEY_DOWN : deltaMove = -1.0; break;
    }
}

void
releaseSpecialKey (int key, int xx, int yy)
{
    switch (key) {
        case GLUT_KEY_UP   : deltaMove = 0.0; break;
        case GLUT_KEY_DOWN : deltaMove = 0.0; break;
    }
}

//----------------------------------------------------------------------
// Process mouse drag events
//
// This is called when dragging motion occurs. The variable
// angle stores the camera angle at the instance when dragging
// started, and deltaAngle is a additional angle based on the
// mouse movement since dragging started.
//----------------------------------------------------------------------
void
mouseMove (int xx, int yy)
{
    if (isDragging) { // only when dragging
        // update the change in angle
        deltaAngle = 0.005 * (xx - xDragStart);
        std::cout << "xx " << xx << std::endl;//
        // camera's direction is set to angle + deltaAngle
        lx = - sin(angle + deltaAngle);
        ly =   cos(angle + deltaAngle);
        // printf("LUI %i %f  %f %f\n", xx, deltaAngle, lx, ly);
    }
}

void
mouseButton (int button, int state, int xx, int yy)
{
    if (GLUT_LEFT_BUTTON == button) {
        if (GLUT_DOWN == state) { // left mouse button pressed
            isDragging = 1; // start dragging
            xDragStart = xx; // save xx where button first pressed
        }
        else  { /* state is GLUT_UP */
            angle += deltaAngle; // update camera turning angle
            isDragging = 0; // no longer dragging
        }
    }
}


// Main program  - standard GLUT initializations and callbacks
int
main (int argc, const char *argv[]) {
    if (argc != 2)
        return 1;
    std::string trained(argv[1]);
    ovr.init(trained);

    // UglyHack® #47
    char *my_argv[] = {"demo2", NULL};
    int   my_argc = 1;

    // general initializations
    glutInit(&my_argc, my_argv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowPosition(100, 100);
    glutInitWindowSize(WIN_SZ_Y, WIN_SZ_X);
    glutCreateWindow(PROJECT " ~ " DEMO);

    // register callbacks
    glutReshapeFunc(changeSize); // window reshape callback
    glutDisplayFunc(renderScene); // (re)display callback
    glutIdleFunc(update); // incremental update
    //glutIgnoreKeyRepeat(1); // ignore key repeat when holding key down
    glutMouseFunc(mouseButton); // process mouse button push/release
    glutMotionFunc(mouseMove); // process mouse dragging motion
    glutKeyboardFunc(processNormalKeys); // process standard key clicks
    glutSpecialFunc(pressSpecialKey); // process special key pressed
// Warning: Nonstandard function! Delete if desired.
    glutSpecialUpFunc(releaseSpecialKey); // process special key release

    // OpenGL init
    glEnable(GL_DEPTH_TEST);

    // enter GLUT event processing cycle
    glutMainLoop();

    return 0;
}
