// Shader downloaded from https://www.shadertoy.com/view/ldcXRl
// written by shadertoy user aiekick
//
// Name: Motion Blur Experiment 5
// Description: Mblur test
void mainImage( out vec4 f, vec2 g )
{
	f = texture2D(iChannel0, g / iResolution.xy);
}