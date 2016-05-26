// Shader downloaded from https://www.shadertoy.com/view/4dcGDf
// written by shadertoy user cornusammonis
//
// Name: Pixel Sorting (X-Y Interleave)
// Description: Pixel sorting (by color magnitude) alternating between X and Y axes.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}