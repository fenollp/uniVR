// Shader downloaded from https://www.shadertoy.com/view/XlSGzD
// written by shadertoy user mpcomplete
//
// Name: Acid Kaleidoscope
// Description: Playing with transitions between transformations.
//    
//    Mixing ideas from
//    - https://www.shadertoy.com/view/XlXGW2 and
//    - https://www.shadertoy.com/view/XlfGDf
//#define DEBUG 1

float time = iGlobalTime*.3;

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
    vec2 ap = abs(sin(p*3.));
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

float numPhases = 4.;
vec2 getTransform(in vec2 p, float t)
{
    int which = int(mod(t, numPhases));

    if (which == 0) {
        p = rotate(time*.3)*p*.7;
        p = dupSquares(p);
    } else if (which == 1) {
        p = dupSquares(p);
        p = rotate(time*.2)*p;
        p = dupSquares(p);
    } else if (which == 2) {
        p = dupSquares(p);
        p = rotate(time*.3)*p;
        p = dupSquaresConcentric(p);
    } else {
        p = dupSquaresConcentric(p*1.5);
    }
    return p;
}

vec2 applyTransform(in vec2 p)
{
    float t = time*.35;
#ifdef DEBUG
    if (iMouse.z > .001) t = iMouse.x/iResolution.x * numPhases;
#endif
    float pct = smoothstep(0., 1., mod(t, 1.));
    return mix(getTransform(p, t), getTransform(p, t+1.), pct);
}

vec4 gradient(float f)
{
    vec4 c = vec4(0);
	f = mod(f, 1.5);
    for (int i = 0; i < 3; ++i)
        c[i] = pow(.5 + .5 * sin(2.0 * (f +  .2*float(i))), 10.0);
    return c;
}

float offset(float th)
{
    return .2*sin(25.*th)*sin(time);
}

vec4 tunnel(float th, float radius)
{
	return gradient(offset(th) + 2.*log(radius) - time);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

    p = applyTransform(p);

	fragColor = tunnel(atan(p.y, p.x), 2.0 * length(p));
}