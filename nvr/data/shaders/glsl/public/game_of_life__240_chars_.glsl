// Shader downloaded from https://www.shadertoy.com/view/4dGSWR
// written by shadertoy user FabriceNeyret2
//
// Name: game of life (240 chars)
// Description: smallest Conway's game of life
//    compaction of https://www.shadertoy.com/view/4ddSRM
//    
//    could you find smaller ? ;-)
// compaction of https://www.shadertoy.com/view/4ddSRM

void mainImage( out vec4 O, vec2 U )
{  O = texture2D(iChannel0, U/iResolution.xy); }