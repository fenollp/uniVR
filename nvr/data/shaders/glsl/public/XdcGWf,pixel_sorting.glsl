// Shader downloaded from https://www.shadertoy.com/view/XdcGWf
// written by shadertoy user cornusammonis
//
// Name: Pixel Sorting
// Description: Pixel sorting (by color magnitude) along the y axis.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}