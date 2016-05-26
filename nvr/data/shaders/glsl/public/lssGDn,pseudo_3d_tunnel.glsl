// Shader downloaded from https://www.shadertoy.com/view/lssGDn
// written by shadertoy user 4rknova
//
// Name: Pseudo 3D Tunnel
// Description: The classic tunnel effect.
// by nikos papadopoulos, 4rknova / 2013
// WTFPL

#ifdef GL_ES
precision highp float;
#endif

// Notes
// p: Screen coordinates in [-a,a]x[-1,1] space (aspect corrected).
// t: The texture uv coordinates.
//	  u: The angle between the positive x axis and p.
//	  v: The inverse distance of p from the axis origin.
// s: Scrolling offset to create the illusion of movement.
// z: Texture uv scale factor.
// m: Brightness scale factor.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2  p = (2. * fragCoord.xy / iResolution.xy - 1.)
		    * vec2(iResolution.x / iResolution.y,1.);
	vec2  t = vec2(atan(p.x, p.y) / 3.1416, 1. / length(p));
	vec2  s = iGlobalTime * vec2(.1, 1);
	vec2  z = vec2(3, 1);
	float m = t.y + .5;

	fragColor = vec4(texture2D(iChannel0, t * z + s).xyz / m, 1);
}