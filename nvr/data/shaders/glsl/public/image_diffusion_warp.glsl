// Shader downloaded from https://www.shadertoy.com/view/Msd3W2
// written by shadertoy user cornusammonis
//
// Name: Image Diffusion Warp
// Description: Image warping using diffusion.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 im = texture2D(iChannel0, uv).xyz;
    fragColor = vec4(im, 0.0);
    //fragColor = 0.5 + 0.5 * texture2D(iChannel1, uv);
}