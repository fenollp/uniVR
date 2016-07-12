// Shader downloaded from https://www.shadertoy.com/view/Md33Dj
// written by shadertoy user FabriceNeyret2
//
// Name: chronophotography
// Description: uncomment line 14 to add a scrolling.
void mainImage( out vec4 O, vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}