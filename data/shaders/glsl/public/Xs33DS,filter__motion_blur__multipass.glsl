// Shader downloaded from https://www.shadertoy.com/view/Xs33DS
// written by shadertoy user 4rknova
//
// Name: Filter: Motion Blur, multipass
// Description: A simple multipass blur filter
// by Nikos Papadopoulos, 4rknova / 2016
// WTFPL

void mainImage(out vec4 c, vec2 p)
{
	c = texture2D(iChannel0, p.xy / iResolution.xy);
}