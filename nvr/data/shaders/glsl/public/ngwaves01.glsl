// Shader downloaded from https://www.shadertoy.com/view/XtXGDS
// written by shadertoy user netgrind
//
// Name: ngWaves01
// Description: x - mad moire
//    y - color shift
#define PI 3.14159265359

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv-=0.5;
    float a = abs(atan(uv.y/uv.x))/PI;
    vec4 c = vec4(a,a,a,1.0);
    float off = iMouse.y/iResolution.y*PI*2.0;
    c.r += sin(a*iMouse.x*10.0+iGlobalTime)*0.1;
    c.g += sin(a*iMouse.x*10.0+iGlobalTime+off)*0.1;
    c.b += sin(a*iMouse.x*10.0+iGlobalTime+off*2.0)*0.1;
	fragColor = c;
}