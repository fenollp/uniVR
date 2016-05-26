// Shader downloaded from https://www.shadertoy.com/view/lsjSDK
// written by shadertoy user 4rknova
//
// Name: Flag: Japan
// Description: Flag of Japan.
// by nikos papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS 0.001

#define SUPERSAMPLING 4.
#define ANIMATE

// Flag ####################################################################
#define FLAG_JP_PROP      3./2.
#define FLAG_JP_COL_WHITE vec3(1)
#define FLAG_JP_COL_RED   vec3(1, 0, 0)
#define FLAG_JP_RADIUS    .3

vec3 flag_jp(in vec2 p) {
    if (p.x > FLAG_JP_PROP || p.x < 0. ||
        p.y > 1. || p.y <0.) return vec3(0.);
  
    vec3 c = FLAG_JP_COL_WHITE;
	
    if (length(p - vec2(FLAG_JP_PROP * .5, .5)) < FLAG_JP_RADIUS)
        c = FLAG_JP_COL_RED;
  	
	return c;
}
// #########################################################################

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ar = iResolution.x/iResolution.y;
	vec2 uv = (fragCoord.xy / iResolution.xy) * vec2(ar, 1);
    
    float zoom = 1.4;
    vec2  pos  = vec2(.5,.25);
    
    uv = uv * zoom - pos; // Position the flag
    vec2 pv = uv;

#ifdef ANIMATE // Wave animation    
    vec2 cv = uv;    
	pv.y = uv.y + (.3 + cv.x) * pow(sin(cv.x * 6. - iGlobalTime * 6.0), 2.) * .032;
    pv.x = uv.x + cv.y * cos(cv.x - cv.y * 2. - iGlobalTime * .5) * .05;
#endif
    
    vec3 col = vec3(0);

#ifdef SUPERSAMPLING
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x) / zoom;
    for (float i = -SUPERSAMPLING; i < SUPERSAMPLING; ++i) {
        for (float j = -SUPERSAMPLING; j < SUPERSAMPLING; ++j) {
    		col += flag_jp(pv + vec2(i, j) * (e/SUPERSAMPLING)) 
                / (4.*SUPERSAMPLING*SUPERSAMPLING);
        }
    }
#else
     col = flag_jp(pv);
#endif

    float s = 1.;
    
#ifdef ANIMATE
    s = pow(dot(normalize(vec3(pv - uv, 1)), normalize(vec3(0,25, 4))),.4);
    #endif
    
	fragColor = vec4(col * s, 1);
}