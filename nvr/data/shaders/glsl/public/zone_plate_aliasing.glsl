// Shader downloaded from https://www.shadertoy.com/view/XddSDB
// written by shadertoy user Mx7f
//
// Name: Zone Plate Aliasing
// Description: Demonstration of aliasing.
// Set JITTERED_SAMPLING to 1 to break up the aliases.
// Set TIME_VARYING_SCALE to 1 to zoom in and out with time
#define TIME_VARYING_SCALE 1
#define JITTERED_SAMPLING 0

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pix = fragCoord.xy;
    
#if TIME_VARYING_SCALE
    float scale = ((-cos(iGlobalTime*0.2))*0.5+0.5)*0.3+0.01;
#else
    float scale = 0.04;
#endif
    
    vec2 uv = (fragCoord.xy - vec2(0.0,0.5*iResolution.y)) * scale;
    
#if JITTERED_SAMPLING
    vec2 jitter = vec2(rand(uv) - 0.5, rand(uv*uv) - 0.5)*1.0;
    uv += jitter * scale;
#endif  
	
    float r = sin(uv.x*uv.x + uv.y*uv.y)*0.5+0.5;
	fragColor = vec4(r,r,r,1.0);
}