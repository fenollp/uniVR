// Shader downloaded from https://www.shadertoy.com/view/MdKXRh
// written by shadertoy user vox
//
// Name: Galactic Night 2
// Description: Galactic Night 2

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 sample = texture2D(iChannel0, uv);
    fragColor = sample; return;
    fragColor = vec4(sample.a); return;
}
