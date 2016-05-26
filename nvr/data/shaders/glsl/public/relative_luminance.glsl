// Shader downloaded from https://www.shadertoy.com/view/4slGDn
// written by shadertoy user 4rknova
//
// Name: Relative Luminance
// Description: Grayscale conversion using relative luminance.
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

#define F vec3(.2126, .7152, .0722)

void mainImage(out vec4 c, vec2 p)
{
	c = vec4(vec3(dot(texture2D(iChannel0, p.xy / iResolution.xy).xyz,F)), 1);
}