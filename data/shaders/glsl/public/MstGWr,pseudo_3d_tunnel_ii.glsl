// Shader downloaded from https://www.shadertoy.com/view/MstGWr
// written by shadertoy user 4rknova
//
// Name: Pseudo 3D Tunnel II
// Description: A variation of the classic tunnel effect
// by nikos papadopoulos, 4rknova / 2015
// WTFPL

#define SAMPLES 64

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2  p = (2. * fragCoord.xy / iResolution.xy - 1.)
		    * vec2(iResolution.x / iResolution.y,1.);
    vec2  v = p * p * vec2(1.,2.);
    vec2  t = vec2(atan(p.x, p.y) / 3.1416, 1. / length(p));
	vec2  z = vec2(4, .6);
	vec3  r = vec3(0);    
    vec2  s = iGlobalTime * vec2(.1, 1);
    
    for (int i = 0; i < SAMPLES; ++i)
    {
    	r += texture2D(iChannel0, t * z + s + float(i)*.01).xyz / (t.y + .5) / float(SAMPLES); 
    }
    
	fragColor = vec4(r, 1);
}