// Shader downloaded from https://www.shadertoy.com/view/MsG3zD
// written by shadertoy user joeedh
//
// Name: AA Artwork
// Description: A failed neighborhood function for AA Patterns.  Click and drag to (slightly) change seed.
/*
	https://www.shadertoy.com/view/MsG3zD
	
	This little shader is the result of a mathematical breakthrough I made last week.
    This was a side effect.  The idea is simple.  AA patterns work by calculating a thresholding
    for each pixel, using a function f (here is my slightly modified version):

    dx = fract(x*seed - y*0.5);
    dy = fract(y*seed + x*0.5);

    f(x, y) -> length(dx, dy) / sqrt(2) //return value from 0...1

There are other patterns too.  I was deriving a neighborhood filter (think of it as a blur filter) 
for anther pattern analytically.  It tells you which neighborhood a point in that particular pattern
is in.  No matter what width of filter I used, I kept arriving at the same basic equation:

    neighborhood_id = fract( (f(x, y) + C1) * C2 )

Where C1 and C2 are constants.  I thought to myself, why not see what the same equation will do 
to AA Patterns?  The result was an approxmation of the neighborhood function.  It's imperfect,
but can produce very pretty looking patterns.

(For those interested, the reason it's hard to derive a neighborhood filter for AA patterns is that 
 fract(fract(x)*fract(y)) can't be factored).

*/

//#define NO_COLOR;
#define ZOOM 2.0
//#define HEXAGON; //offset grid pixels in hexagon pattern. useful when zoomed in.
//#define SMOOTHSTEP_SHARPEN; //provides some sharpening, but at cost of suppressing some details

float tent(float f) {
    return 1.0 - abs(fract(f)-0.5)*2.0;
}

vec3 sample(vec2 uv, float time) {
	float c;
    float seed = 8.13295 /* - tent(time*0.00541)*0.00*/ + iMouse.x*0.0000225;
    float seed2 = 0.5;
    
    //align to power of 2
    seed = floor(seed*2048.0)/2048.0;
    seed2 = floor(seed2*2048.0)/2048.0;
    
    float dx = fract(uv[0]*seed - uv[1]*seed2)*2.0-1.0;
    float dy = fract(uv[1]*seed + uv[0]*seed2)*2.0-1.0;
    
    //c = 1.0- sqrt((dx*dx + dy*dy))/1.414;
    c = sqrt(dx*dx+dy*dy)/sqrt(2.0);
    
    //c = min(abs(dx), abs(dy));
    float mtime = 1.0 - tent(3.5*0.025+time*0.025);
    float m = 1.0 + mtime*5.0;
    
    c = cos(-1.15+(c+0.0)*m)*0.5 + 0.5;
    float f = (tent(c*1.35+1.205));
    
    c = pow(c, 2.0);
    
    f = f*0.85 + 0.15;
    f *= 1.05;
    f *= f*f*f*f*f*f;
    
    #ifdef SMOOTHSTEP_SHARPEN
    for (int i=0; i<1; i++) {
    	f = f*f*(3.0-2.0*f);
    }
    #endif
	
    float steps = 5.0;
    
    c = floor(c*steps+0.5)/steps;
    c *= 2.324324;
    
    return vec3(f, c, mtime);
}

vec3 pow(vec3 v, float f) {
    return vec3(
        pow(v[0], f),
        pow(v[1], f),
        pow(v[2], f)
    );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv2 = fragCoord.xy / iResolution.xy;
    vec2 uv = fragCoord.xy;
    float sz = 1.0 / ZOOM;
    uv *= sz;
    
    
#ifdef HEXAGON
    vec2 hexoff = vec2(0.0, 0.5*floor(mod(uv[0], 2.0)));
    hexoff *= floor(mod(floor(uv[0]/2.0), 2.0))*2.0-1.0;

    vec2 px = fract(uv + hexoff)-0.5;
    uv = floor(uv+hexoff);
#else
    vec2 px = fract(uv)-0.5;
    uv = floor(uv);
#endif
    
    vec3 ret = sample(uv, iGlobalTime);
    float f = ret[0];
    float c = ret[1];
    
    c *= 100.0;
    
    //color offset
    float off = 0.9;// + tent(iGlobalTime*0.05)*0.5;
    
    float r = tent(1.0 / ((sin(c*3.0)+0.25)*0.0000123432+0.00000001));
    float g = tent(1.0 / ((sin(c*c*c*2.0+3.32)+0.5)*0.00002234+0.00000001));
    float b = tent(1.0 / ((sin(c*c*5.0+4.43))*0.0000123432+0.0000000001));
    float w = (r+g+b)/3.0;
    
    r = cos((r + off)*3.141)*0.5+0.5;
    g = cos((g + off)*3.141)*0.5+0.5;
    b = cos((b + off)*3.141)*0.5+0.5;
    
    r *= 1.2;
    b *= 0.8;
    g *= 0.9;
    
    
    float fac = f*9.0-9.5;
    fac = pow(abs(fac), 1.0)*sign(fac);
    
	vec3 clr = vec3(r, g, b)*f*f;
    clr = clr*10.0 - 11.0;
    
    fac = clamp(0.0,1.0,fac);
    clr = min(max(clr, 0.0), 1.0);
    clr = clr*0.5 + 0.5;
    
	fragColor = vec4(r, g, b, 1.0);
    fragColor.xyz = normalize(fragColor.xyz)*f; //(uv2[0] > 0.5 ? clr : 1.0);
    // if (uv2[0] < 0.5)
    	fragColor.xyz = mix(fragColor.xyz, fragColor.xyz * clr * 2.75, ret[2]);
    
    if (sz < 0.5) {
        float pfac = dot(px, px);
    	fragColor.xyz = mix(fragColor.xyz, vec3(0.5, 0.5, 0.5), 1.0-smoothstep(0.4, 0.1, pfac));
    }
    
#ifdef NO_COLOR    
    fragColor = vec4(f, f, f, 1.0);
#endif
    
}