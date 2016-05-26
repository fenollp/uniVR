// Shader downloaded from https://www.shadertoy.com/view/XddSWB
// written by shadertoy user FabriceNeyret2
//
// Name: boreal plasma
// Description: try also the rock textures :-)
void mainImage( out vec4 O, vec2 U ) { O = texture2D(iChannel0, U/iResolution.xy); }