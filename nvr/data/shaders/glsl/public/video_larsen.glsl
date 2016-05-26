// Shader downloaded from https://www.shadertoy.com/view/XsG3RW
// written by shadertoy user FabriceNeyret2
//
// Name: video larsen
// Description: a very old classical recursive video effect.
void mainImage( out vec4 O,  vec2 U )  { O = texture2D(iChannel0, U/iResolution.xy); }