// Shader downloaded from https://www.shadertoy.com/view/XsVXWz
// written by shadertoy user FabriceNeyret2
//
// Name: random quality measure
// Description: random quality measure
//    
//    With random multiplier 3e4 instead of 3213.76,
//    there is an excess of small values, and steps appears ( try rate  .01 line 4 and wait 10'  ).
void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}