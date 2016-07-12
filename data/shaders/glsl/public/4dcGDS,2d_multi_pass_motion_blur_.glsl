// Shader downloaded from https://www.shadertoy.com/view/4dcGDS
// written by shadertoy user aiekick
//
// Name: 2D Multi Pass Motion Blur 
// Description: Motion Blur Multi Pass
void mainImage( out vec4 f, in vec2 g )
{
    f = texture2D(iChannel0, g / iResolution.xy);
}