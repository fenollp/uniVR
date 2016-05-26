// Shader downloaded from https://www.shadertoy.com/view/4sGSD1
// written by shadertoy user FabriceNeyret2
//
// Name: random quality measure 2
// Description: random quality measure: histogram or random values zoomed to inspect the range [0 , 01].
//    I'ld like to understand the strange relation between the multiplier and the quality !
//    
//    Ok: it seems that 111.1111 best scramble and propagates decimals
void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}