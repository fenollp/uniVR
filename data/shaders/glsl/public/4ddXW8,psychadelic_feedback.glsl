// Shader downloaded from https://www.shadertoy.com/view/4ddXW8
// written by shadertoy user TekF
//
// Name: psychadelic feedback
// Description: Just doodling.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = texture2D(iChannel0, fragCoord / iResolution.xy);
}