// Shader downloaded from https://www.shadertoy.com/view/Xdd3Wf
// written by shadertoy user aiekick
//
// Name: Britney Stop and Blurred Motion
// Description: Britney Stop and Blurred Motion
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = texture2D(iChannel0, fragCoord / iResolution.xy);
}