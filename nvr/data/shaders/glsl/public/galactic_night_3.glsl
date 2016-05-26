// Shader downloaded from https://www.shadertoy.com/view/MdKSRD
// written by shadertoy user vox
//
// Name: Galactic Night 3
// Description: You have to wait 'til 2:45 for the music to get good. The opening is kinda funny, though.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 sample = texture2D(iChannel0, uv);
    fragColor = sample; return;
    fragColor = vec4(sample.a); return;
}
