// Shader downloaded from https://www.shadertoy.com/view/Xsy3RR
// written by shadertoy user aiekick
//
// Name: 2D MPass MBlur 3
// Description: 2D Multi Pass Motion Blur 3
void mainImage( out vec4 f, in vec2 g )
{
    f = texture2D(iChannel0, g / iResolution.xy);
}