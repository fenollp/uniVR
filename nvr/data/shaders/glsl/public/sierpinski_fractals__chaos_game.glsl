// Shader downloaded from https://www.shadertoy.com/view/XllXD8
// written by shadertoy user 4rknova
//
// Name: Sierpinski Fractals, Chaos Game
// Description: Use the 'r' key to switch between the rendering modes.
//    Hold down the key corresponding to the fractal you wish to see (keys: 1-5).
//    Change the rendering mode to clear the frame.
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define E  1e-3
#define P  3.14159265359
#define Q  0.78539816339

#define TOGGLED .75
#define HELD    .25
#define KEY(k, y) (texture2D(iChannel0, vec2(float(k) / 255., y)).x == 1.)

// Fractal parameters (TYPE, VERTICES, RATIO)
#define S vec3(1, 8, 1./3.)

vec2 r(vec3 s, float t)
{
    float r = floor(fract(cos(iGlobalTime+t)*43758.5453) * float(s.y));
    float f = 2.* Q + 2. * P / s.y * r;
    vec2  p = vec2(cos(f), sin(f));
    vec2  q = vec2(abs(cos(Q)), abs(sin(Q)));

    if (s.x == 1. && (abs(p.x) > q.x || abs(p.y) > q.y)) {
        float F = f - 2. * Q;
        if      (F >       Q && F <  3. * Q) p.x = -q.x;
        else if (F >= 3. * Q && F <= 5. * Q) p.y = -q.y;
        else if (F >= 5. * Q && F <= 7. * Q) p.x =  q.x;
        else                                 p.y =  q.y;
    }
    
    return p;
}

void mainImage(out vec4 c, in vec2 p)
{
    vec3 s = S;
    if      (KEY(49, HELD)) s = vec3(0, 3, 1./2.); // Sierpinski Gasket
    else if (KEY(50, HELD)) s = vec3(0, 4, 1./2.); // Sierpinski Square
    else if (KEY(51, HELD)) s = vec3(1, 3, 1./2.); // Sierpinski Gasket
    else if (KEY(52, HELD)) s = vec3(1, 8, 1./3.); // Sierpinski Carpet
    else if (KEY(53, HELD)) s = vec3(0, 6, 1./3.); // Sierpinski Fraction
    
    vec2 u = 1.1 * (p / iResolution.xy * 2. - 1.);
    u.x *= iResolution.x / iResolution.y;
    
    vec2 e = r(s, 0.);    
    for (float i = 0.; i < 7e2; ++i) {
        e = mix(r(s, i), e, s.z);
        vec2 v = e - u;
        if (max(abs(v.x), abs(v.y)) < 75e-4) {
            c = vec4(1); 
            return;
        }  
    }
   
    if (KEY(82, TOGGLED)) discard;
    c = vec4(0,0,0,1);
}