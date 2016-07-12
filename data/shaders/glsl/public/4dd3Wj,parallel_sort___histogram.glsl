// Shader downloaded from https://www.shadertoy.com/view/4dd3Wj
// written by shadertoy user FabriceNeyret2
//
// Name: parallel sort / histogram
// Description: At each frame,  pixels are randomly paired (using pairPos = xor( Pos, f(T) )  )
//    Pixels in each pair are swapped if not in expected (luminance) order.  Sort of // random bubble sort.
void mainImage( out vec4 O, vec2 U )
{
	 O = texture2D(iChannel0, U/iResolution.xy);
}