// Shader downloaded from https://www.shadertoy.com/view/llXGDS
// written by shadertoy user 4rknova
//
// Name: Half Life 3
// Description: Waiting for Valve to learn how to count to 3..
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define EPS .001
#define PI  3.14159265359

#define AA	4.
#define COL1 vec3(1,.6,0)

vec2 rotate(in vec2 p, in float t)
{
    t = t * 2. * PI;
    return vec2(p.x * cos(t) - p.y * sin(t),
                p.y * cos(t) + p.x * sin(t));
}

float df_box (in vec2 p)
{
    return max(abs(p.x), abs(p.y));
}

float df_line(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);	
	return length(pa - ba * h);
}

float df_circ(in vec2 p, in vec2 c, in float r)
{
    return abs(r - length(p - c));
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

float df_scene(vec2 uv)
{   
    
	vec2 c = vec2(0), u = vec2(0,.45);
    float c1 = sharpen(df_circ(uv, c, .8), EPS * 100.);
    
    
    //3    
    float e0 = 1. - sharpen(df_circ(20. * uv - vec2(14.,14.5), c, 1.), EPS * 350.);
    float e1 = 1. - sharpen(df_circ(20. * uv - vec2(14.,12.5), c, 1.), EPS * 350.);
    float e2 = sharpen(df_box((uv- vec2(.63,.675))*vec2(1.15,1.3)), EPS * 75.0);
    float e  = max(min(e0, e1),e2);
    float c2 = 0.;
    
    // circle
    if (   uv.y > 0. && uv.y < 0.9 
        && uv.x > 0. && uv.x < 0.9
        && length(uv + vec2(.25)) < 1./length(uv*uv*uv*uv))
        c2 = sharpen(
            df_circ(uv, c, 1.2), EPS * 500.);
    
    // λ
    float l1 = sharpen(df_line(uv, vec2(.0, .5), vec2(  .3,-.40)), EPS * 75.);
    float l2 = sharpen(df_line(uv, vec2(.3,-.4), vec2(  .45,-.35)), EPS * 75.);
    float l3 = sharpen(df_line(uv, vec2(.0, .5), vec2(-.25, .50)), EPS * 75.);
    float l4 = sharpen(df_line(uv, vec2(.04, .2), vec2(-.4,-.40)), EPS * 75.);
    
    float l5 = sharpen(df_line(uv, vec2(-.3, 1.), vec2(-.3,.0)), EPS * 75.);
    float l6 = sharpen(df_line(uv, vec2(-.3, 1.), vec2(-.3,.0)), EPS * 75.);
    float l7 = sharpen(df_line(uv, vec2(-.3, 1.), vec2(-.3,.0)), EPS * 75.);
    return min(max(max(max(max(max(l1,l2),l3-l5),l4), c1), c2),e);
}

vec3 tex(vec2 uv)
{
    return vec3(df_scene(uv));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.);
	vec2 nv = uv * vec2(iResolution.x/iResolution.y, 1) * 1.1;
    
    
    vec3 col = vec3(0);
    
#ifdef AA
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x);    
    for (float i = -AA; i < AA; ++i) {
        for (float j = -AA; j < AA; ++j) {
    		col += tex(nv + vec2(i, j) * (e/AA)) / (4.*AA*AA);
        }
    }
#else
    col += tex(nv);
#endif /* AA */
    
    col *= COL1;
    
	fragColor = vec4(col, 1);
}