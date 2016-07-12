// Shader downloaded from https://www.shadertoy.com/view/MdGGzR
// written by shadertoy user cornusammonis
//
// Name: Multiscale Turing Patterns
// Description: A Gaussian Pyramid implementation of Jonathan McCabe's Multiscale Turing Patterns. Paint with mouse controls.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = 0.5 + 0.5 * texture2D(iChannel0, uv);
}