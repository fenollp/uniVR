// Shader downloaded from https://www.shadertoy.com/view/ldcSDB
// written by shadertoy user cornusammonis
//
// Name: Anisotropic Blur Image Warp
// Description: Warps an image using an anisotropic blur kernel controlled by a vector field. Use mouse controls to mess with the underlying vector field, and spacebar to reset in fullscreen.
#define SIGMOID_CONTRAST 12.0

vec4 contrast(vec4 x, float s) {
	return 1.0 / (1.0 + exp(-s * (x - 0.5)));    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 texel = 1. / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = contrast(texture2D(iChannel0, uv), SIGMOID_CONTRAST);
}