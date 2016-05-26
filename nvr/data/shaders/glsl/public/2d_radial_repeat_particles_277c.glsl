// Shader downloaded from https://www.shadertoy.com/view/XsV3RD
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat Particles 277c
// Description: 2D Radial Repeat : Blur
void mainImage( out vec4 f, vec2 g )
{
	f = texture2D(iChannel0, g/iResolution.xy);
}