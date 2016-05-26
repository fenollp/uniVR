// Shader downloaded from https://www.shadertoy.com/view/XsdSWB
// written by shadertoy user FabriceNeyret2
//
// Name: boreal plasma 2
// Description: try also the various textures :-)
void mainImage( out vec4 O, vec2 U ) { O = texture2D(iChannel0, U/iResolution.xy); }