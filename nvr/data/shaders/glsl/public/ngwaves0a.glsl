// Shader downloaded from https://www.shadertoy.com/view/lll3Ds
// written by shadertoy user netgrind
//
// Name: ngWaves0A
// Description: wavey
#define PI 3.1415
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c = vec4(1.0);
    c.r = sin(uv.y*10.0*cos(uv.x*10.0+i+sin(uv.x+uv.y+i)*tan(uv.y*1.0+i))+i)*.5+.5;
    c.g = sin(c.r*PI*2.0)*.5+.5;
    c.b = sin(c.g*PI*2.0+i)*.5+.5;
	fragColor = c;
}