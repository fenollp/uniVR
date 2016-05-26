// Shader downloaded from https://www.shadertoy.com/view/XlfGDf
// written by shadertoy user mpcomplete
//
// Name: Phase Engine
// Description: Creating patterns by combining different geometric transforms onto a point on a circle.
//#define DEBUG 1
float time = iGlobalTime;

// Fuzzy unit circle.
float circle(in vec2 p)
{
    float r = length(p);
    float angle = atan(p.y, p.x);
    return step(r, 1.) * pow(1.-r, .5);
}

// 2D rotation matrix.
mat2 rotate(float angle)
{
    return mat2(
        vec2( cos(angle), sin(angle)),
        vec2(-sin(angle), cos(angle)));
}

// Transform a point on square to a circle.
vec2 mapSquare(in vec2 p)
{
    vec2 ap = abs(p);
    float r = max(ap.x, ap.y);
    float angle = atan(p.y, p.x);

    return r*vec2(cos(angle), sin(angle));
}

// Make a pattern of squares in a repeating grid.
vec2 dupSquares(in vec2 p)
{
    vec2 ap = abs(sin(p*6.));
    float r = max(ap.x, ap.y);
    float angle = atan(p.y, p.x);

    return r*vec2(cos(angle), sin(angle));
}

// Duplicate pattern in dupSquaresConcentric squares.
vec2 dupSquaresConcentric(in vec2 p)
{
    vec2 ap = abs(p);
    float r = max(ap.x, ap.y);
    float angle = atan(p.y, p.x);

    return sin(3.*r)*vec2(cos(angle), sin(angle));
}

// Duplicate pattern in a repeating grid.
vec2 dupGrid(in vec2 p)
{
    return abs(sin(p*4.));
}

float numPhases = 6.;
vec2 getTransform(in vec2 p, float t)
{
    int which = int(mod(t, numPhases));

    if (which == 0) {
        p = mapSquare(p);
        p = pow(vec2(.3), abs(p));
        p = rotate(time*.1)*p;
        p += .1*sin(time*.2);
        p = dupSquares(p);
        p -= .1*sin(time*.2);
        p = dupSquares(p);
    } else if (which == 1) {
        p = pow(abs(p), vec2(.5));
        p = mapSquare(p);
        p = pow(abs(p), vec2(3.));
        p += .1*sin(time*.2);
        p = dupSquares(p);
        p = rotate(time*.1)*p;
        p = dupGrid(p);
        p -= .1;
        p = rotate(time*.1)*p;
    } else if (which == 2) {
        p = mapSquare(p);
        p = dupGrid(p*.5);
        p += .2 + .1*sin(time*.2);
        p = dupSquares(p);
        p = rotate(time*.1)*p;
        p = dupSquares(p);
    } else if (which == 3) {
        p = mapSquare(p);
        p = dupGrid(p*.7);
        p = dupSquaresConcentric(p);
        p = rotate(time*.1)*p;
        p = dupSquares(p);
        p += .3*sin(time*.2);
        p = pow(abs(p), vec2(.5));
        p = dupSquares(p);
    } else if (which == 4) {
        p = pow(vec2(.3), abs(p));
        p = mapSquare(p);
        p = dupGrid(p);
        p = dupSquaresConcentric(p);
        p = rotate(time*.1)*p;
        p = dupSquares(p);
        p += .3*sin(time*.2);
        p = pow(abs(p), vec2(.5));
        p = dupSquares(p);
    } else if (which == 5) {
        p = pow(vec2(.3), abs(p));
        p = mapSquare(p);
        p = dupGrid(p);
        p = dupSquaresConcentric(p);
        p += .3*sin(time*.2);
        p = rotate(time*.1)*p;
        p = dupSquares(p);
        p = pow(abs(p), vec2(.5));
        p = dupSquares(p);
    }
#if 0  // REJECTS
    } else {
        p = mapSquare(p);
        p = dupSquares(p*.5);
        p = dupGrid(p);
        p = dupSquares(p*.5);
        p = rotate(time*.1)*p;
        p = dupSquares(p);

    }
#endif
    return p;
}

vec2 applyTransform(in vec2 p)
{
    float t = time*.05;
#ifdef DEBUG
    if (iMouse.z > .001) t = iMouse.x/iResolution.x * numPhases;
#endif
    float pct = smoothstep(0., 1., mod(t, 1.));
    return mix(getTransform(p, t), getTransform(p, t+1.), pct);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
    p *= 1.3;

    p = applyTransform(p);
    float c1 = circle(p);
#if 0
    float c2 = circle(p*1.7);
    float c3 = circle(p*1.3);
#else
    float c2 = circle(p*1.7 + .25*vec2(sin(time*.6), cos(time*.4)));
    float c3 = circle(p*1.3 - .15*vec2(sin(time*.5), cos(time*.5)));
#endif

    fragColor = vec4(c1, c2, c3, 1.0);
}