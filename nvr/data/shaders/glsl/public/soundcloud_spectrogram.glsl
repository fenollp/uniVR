// Shader downloaded from https://www.shadertoy.com/view/lsdGDj
// written by shadertoy user Flexi
//
// Name: Soundcloud Spectrogram
// Description: as simple as possible
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}