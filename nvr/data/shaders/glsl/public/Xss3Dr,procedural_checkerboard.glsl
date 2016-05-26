// Shader downloaded from https://www.shadertoy.com/view/Xss3Dr
// written by shadertoy user 4rknova
//
// Name: Procedural Checkerboard
// Description: A simple checkerboard pattern.
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

#define S 5. // Scale

void mainImage(out vec4 c, vec2 p)
{
	vec2 uv = floor(S * p.xy * vec2(iResolution.x / iResolution.y, 1) / iResolution.xy);
	c = vec4(vec3(mod(uv.x + uv.y, 2.)), 1);
}