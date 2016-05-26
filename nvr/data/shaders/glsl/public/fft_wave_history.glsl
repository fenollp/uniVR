// Shader downloaded from https://www.shadertoy.com/view/MsGGzw
// written by shadertoy user pixelbeast
//
// Name: fft wave history
// Description: 'Yet another sonogram' but with scroll speed affected by frequency
void mainImage( out vec4 f, in vec2 g )
{
    f = texture2D(iChannel0, g / iResolution.xy);
}