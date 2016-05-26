// Shader downloaded from https://www.shadertoy.com/view/MsKXzh
// written by shadertoy user xem
//
// Name: xem random 1
// Description: random
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
fragColor = cos((vec4(1.6, 0.8, iGlobalTime, sqrt(1.7)) / 1.6));
}