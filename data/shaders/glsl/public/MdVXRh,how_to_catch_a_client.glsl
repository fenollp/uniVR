// Shader downloaded from https://www.shadertoy.com/view/MdVXRh
// written by shadertoy user vox
//
// Name: How to Catch a Client
// Description: 1) Attempt to catch whoever is stalking you on Facebook by setting up a trap (unlisted) shader.
//    2) Gnab the first person who gets caught looking and berate them until they divulge their profession.
//    3) If they need shaders sell them to them.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 sample = texture2D(iChannel0, uv);
    fragColor = sample; return;
    fragColor = vec4(sample.a); return;
}
