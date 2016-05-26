// Shader downloaded from https://www.shadertoy.com/view/lsc3D4
// written by shadertoy user 4rknova
//
// Name: Arcade: Pacman
// Description: Pacman.
//    Work in progress, needs cleanup.
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define PI 3.14159265359
#define EPS 5e-5

#define SZ_PANE   30.0 // Resolution
#define SZ_DOTS    4.0 // Dot size
#define SZ_PMAN   16.0 // Pacman size
#define DS_DOTS   32.0 // Dot distances
#define SP_SCROLL 70.0 // Dot scrolling speed

void bgnd(inout vec4 fb, vec2 uv, float t)
{
    fb = vec4(vec3(0),1);
}

void dots(inout vec4 fb, vec2 uv, float t)
{
    vec2 st = uv;
 	st.x += t * SP_SCROLL;
    vec2 p = vec2(2.5 * SZ_DOTS,0);
    st.x =  mod(st.x, DS_DOTS);        
    float r = length(st - p);    
	if(uv.x > -SZ_DOTS && r < SZ_DOTS) fb = vec4(1);
}

void ghst(inout vec4 fb, vec2 uv, float t)
{
    vec2 p = vec2(-SZ_PMAN * 3., 0);
    vec2  d = uv - p;
    float r = length(d);
    float sz_eye   = SZ_PMAN * .3;
    vec2 dl = d - sz_eye * vec2(-.2, .7);
    vec2 dr = d - sz_eye * vec2(2.1, .7);
    vec2 pl = d - sz_eye * vec2(0.4, .7);
    vec2 pr = d - sz_eye * vec2(2.7, .7);

    float wv0 = cos(PI*d.x*.3);
    float wv1 = cos(PI*d.x*.3+PI*.85);
        
         if (   length(pl*pl*pl) < sz_eye
             || length(pr*pr*pr) < sz_eye )  fb = vec4(0,0,1,1);
    else if (   length(dl) < sz_eye 
             || length(dr) < sz_eye)         fb = vec4(1);
    else if (r < SZ_PMAN 
             && dot(d, vec2(0,1)) >= 0.)     fb = vec4(1,0,0,1);
    else if (dot(d, vec2(0,-1)) > 0.
            && abs(d.x) < SZ_PMAN
			&& abs(d.y) < SZ_PMAN *.9 - SZ_PMAN * .15 * (fract(t*3.) > .5 ? wv0 : wv1)) {
        fb = vec4(1,0,0,1);
    }
}


void pman(inout vec4 fb, vec2 uv, float t)
{
    float r = length(uv);
    
    if (r < SZ_PMAN)
    {
        t = t * PI * .25 * (SP_SCROLL*SZ_DOTS/(DS_DOTS));
        if (dot(vec2(1,0), normalize(uv + vec2(SZ_PMAN * .4,0))) * sin(mod(t, PI)) < .75) {
        	fb = vec4(1,1,0,1);
        }
    }
}

void draw(inout vec4 fb, vec2 uv)
{
    float t = iGlobalTime;
    uv = floor(uv * 2.);
    
    bgnd(fb, uv, t);
    dots(fb, uv, t);
    pman(fb, uv, t);
    ghst(fb, uv, t);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float a = iResolution.x / iResolution.y;
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
            * vec2(a, 1) * SZ_PANE;
    
    draw(fragColor, uv);
}