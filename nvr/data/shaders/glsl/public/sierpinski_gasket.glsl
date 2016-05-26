// Shader downloaded from https://www.shadertoy.com/view/ltXSDH
// written by shadertoy user 4rknova
//
// Name: Sierpinski Gasket
// Description: The Sierpinski Gasket, using the chaos game.
// by Nikos Papadopoulos, 4rknova / 2016
// WTFPL

void mainImage(out vec4 c, vec2 p)
{
	c = texture2D(iChannel0, p.xy / iResolution.xy);
}