// Shader downloaded from https://www.shadertoy.com/view/XsXGDM
// written by shadertoy user 4rknova
//
// Name: Chroma Key Composition
// Description: Simple chroma key composition.
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

#define BIAS  4.
#define LUMIN vec3(.2126, .7152, .0722)

void mainImage(out vec4 c, vec2 p)
{
	vec2 uv = p.xy / iResolution.xy;
	
	vec4 fg = texture2D(iChannel0, vec2(1) - uv);
	vec4 bg = texture2D(iChannel1, vec2(1) - uv);
	
	float sf = max(fg.r, fg.b);
	float k = clamp((fg.g - sf) * BIAS, 0., 1.);
	
	if (fg.g > sf) fg = vec4(dot(LUMIN, fg.xyz));
	
	c = mix(fg, bg, k);
}