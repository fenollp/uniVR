// Shader downloaded from https://www.shadertoy.com/view/4ssXRl
// written by shadertoy user 4rknova
//
// Name: Flag: Greece
// Description: Flag of Greece. (1978 to date)
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS .001

#define SUPERSAMPLING 4.
#define ANIMATE

#define FLAG_GR_PROP      3./2.
#define FLAG_GR_COL_BLUE  vec3(.14117647058, .25098039215, .94901960784)
#define FLAG_GR_COL_WHITE vec3(1)
#define FLAG_GR_LINES     9.
#define FLAG_GR_CROSS_X   2./5. * FLAG_GR_PROP
#define FLAG_GR_CROSS_Y   4./9.

vec3 flag_gr(in vec2 p) {
    if (p.x > FLAG_GR_PROP || p.x < 0. ||
        p.y > 1. || p.y <0.) return vec3(0.);
    
    float st = floor(FLAG_GR_LINES * p.y);
    vec3 c = FLAG_GR_COL_BLUE;
	
    // Cross
    if (p.x < FLAG_GR_CROSS_X && p.y > FLAG_GR_CROSS_Y)
    {
        if (st == 6. ||
           length(p.x - FLAG_GR_CROSS_X / 2.) < (1. / FLAG_GR_LINES * .5)
        ) c = FLAG_GR_COL_WHITE;
    }
    // Stripes
    else if (mod(st, 2.) > 0.) c = FLAG_GR_COL_WHITE;
	
	return c;
}

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
    		col += flag_gr(pv + vec2(i, j) * (e/SUPERSAMPLING)) 
                / (4.*SUPERSAMPLING*SUPERSAMPLING);
        }
    }
#else
     col = flag_gr(pv);
#endif
    
    float s = 1.;
    
#ifdef ANIMATE
    s = pow(dot(normalize(vec3(pv - uv, 1)), normalize(vec3(0, 25, 4))), .4);
#endif
    
	fragColor = vec4(col * s, 1);
}