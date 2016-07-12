// Shader downloaded from https://www.shadertoy.com/view/XsyGzz
// written by shadertoy user TekF
//
// Name: Swirl Spin
// Description: My first attempt at a multipass shader, starting simple. Fullscreen recommended.
void mainImage( out vec4 f, in vec2 g )
{
    f = pow(texture2D(iChannel0, g / iResolution.xy),vec4(1.0/2.2));
}