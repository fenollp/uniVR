// Shader downloaded from https://www.shadertoy.com/view/4dG3WR
// written by shadertoy user FabriceNeyret2
//
// Name: gradient of relaxation 
// Description: the pattern is accumulate with an horizontal gradient of memory length.
void mainImage( out vec4 O,  vec2 U ) { O = texture2D(iChannel1,U/iResolution.xy); }