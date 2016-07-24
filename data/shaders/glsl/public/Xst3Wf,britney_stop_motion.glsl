// Shader downloaded from https://www.shadertoy.com/view/Xst3Wf
// written by shadertoy user aiekick
//
// Name: Britney Stop Motion
// Description: Britney Stop Motion
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = texture2D(iChannel0, fragCoord / iResolution.xy);
}