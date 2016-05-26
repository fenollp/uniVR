// Shader downloaded from https://www.shadertoy.com/view/4dVXWz
// written by shadertoy user FabriceNeyret2
//
// Name: random walk / Brownian motion
// Description: random walk
void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}