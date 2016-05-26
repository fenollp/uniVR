// Shader downloaded from https://www.shadertoy.com/view/4sKXWz
// written by shadertoy user FabriceNeyret2
//
// Name: DLA (Diffusion-limited aggreg)
// Description: Quite slow to start :-)
//    Problem: line 19, why does proba 1e-30 give the same as 0.001 ?
//    some ideas here: https://www.shadertoy.com/view/4sGSD1
void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0, U/iResolution.xy);
}