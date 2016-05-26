// Shader downloaded from https://www.shadertoy.com/view/ll23Wt
// written by shadertoy user 4rknova
//
// Name: Interpolation: Bezier, Cubic
// Description: Cubic Bezier interpolation.
//    Note that I use line segments, not the curve distance field.
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define ANIMATED
#define SHOW_CONTROL_POINTS
//#define SHOW_SEGMENT_POINTS
//#define MOUSE_ENABLED 
//#define AA 1.

#define STEPS  25.
#define STROKE .8

#define EPS    .01

#define COL0 vec3(.2, .35, .55)
#define COL1 vec3(.9, .43, .34)
#define COL3 vec3(1.)

float df_circ(in vec2 p, in vec2 c, in float r)
{
    return abs(r - length(p - c));
}

float df_line(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);	
	return length(pa - ba * h);
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

vec2 bezier(vec2 a, vec2 b, vec2 c, vec2 d, float p)
{
    vec2 v0 = mix(a, b, p);
    vec2 v1 = mix(b, c, p);
    vec2 v2 = mix(c, d, p);
    vec2 v3 = mix(v0, v1, p);
    vec2 v4 = mix(v1, v2, p);
    
    return mix(v3, v4, p);
}

float ip_control(vec2 uv, vec2 a, vec2 b, vec2 c, vec2 d)
{    
    float cp = 0.;
    
#ifdef SHOW_CONTROL_POINTS    
    float c0 = sharpen(df_circ(uv, a, .02), EPS * .75);
    float c1 = sharpen(df_circ(uv, b, .02), EPS * .75);
    float c2 = sharpen(df_circ(uv, c, .02), EPS * .75);
    float c3 = sharpen(df_circ(uv, d, .02), EPS * .75);

    float l0 = sharpen(df_line(uv, a, b), EPS * .6);
    float l1 = sharpen(df_line(uv, b, c), EPS * .6);
    float l2 = sharpen(df_line(uv, c, d), EPS * .6);

    cp = max(max(max(c0, c1),max(c2, c3)),
	         max(max(l0, l1),l2));
#endif

    return cp;
}

float ip_point(vec2 uv, vec2 a, vec2 b, vec2 c, vec2 d)
{
    vec2 p = bezier(a, b, c, d, mod(iGlobalTime * 2., 10.) / 10.);
    return sharpen(df_circ(uv, p, .025), EPS * 1.);
}

float ip_bzcurve(vec2 uv, vec2 a, vec2 b, vec2 c, vec2 d)
{ 
    float e = 0.;
    for (float i = 0.; i < STEPS; ++i)
    {
        vec2  p0 = bezier(a, b, c, d, (i   ) / STEPS);
        vec2  p1 = bezier(a, b, c, d, (i+1.) / STEPS);
#ifdef SHOW_SEGMENT_POINTS        
        float m = sharpen(df_circ(uv, p0, .01), EPS * .5);
        float n = sharpen(df_circ(uv, p1, .01), EPS * .5);
        e = max(e, max(m, n));
#endif
        float l = sharpen(df_line(uv, p0, p1), EPS * STROKE);
        e = max(e, l);
    }
                
    return e;
}

vec3 scene(in vec2 uv, in vec2 a, in vec2 b, in vec2 c, in vec2 d)
{
    float d0 = ip_control(uv, a, b, c, d);
    float point = 0.;
    
#ifdef ANIMATED
    point = ip_point(uv, a, b, c, d);
#endif
    
    float d1 = ip_bzcurve(uv, a, b, c, d);    
    float rs = max(d0, d1);
    
    return (point < .5)
        ? rs * (d0 > d1 ? COL0 : COL1)
        : point * COL3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.);
    uv.x *= iResolution.x / iResolution.y;
    vec3 col = vec3(0);
    
    vec2 a = vec2(-.50,-.25);
    vec2 b = vec2( .00, .75);
    vec2 c = vec2( .75,-.75);
    vec2 d = vec2(-.75,-.75);
        
#ifdef MOUSE_ENABLED        
    a = (iMouse.xy / iResolution.xy * 2. - 1.)
           * vec2(iResolution.x / iResolution.y, 1.);
#endif
    
#ifdef AA
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x);    
    for (float i = -AA; i < AA; ++i) {
        for (float j = -AA; j < AA; ++j) {
    		col += scene(uv + vec2(i, j) * (e/AA), a, b, c, d) / (4.*AA*AA);
        }
    }
#else
    col += scene(uv, a, b, c, d);
#endif /* AA */
    
	fragColor = vec4(col, 1);
}