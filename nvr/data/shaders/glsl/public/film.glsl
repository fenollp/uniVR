// Shader downloaded from https://www.shadertoy.com/view/lscGDj
// written by shadertoy user FabriceNeyret2
//
// Name: film
// Description: film
void mainImage( out vec4 O, vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}