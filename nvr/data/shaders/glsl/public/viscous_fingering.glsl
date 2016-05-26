// Shader downloaded from https://www.shadertoy.com/view/Xst3Dj
// written by shadertoy user cornusammonis
//
// Name: Viscous Fingering
// Description: Fluid-like continuous cellular automata.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 texel = 1. / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 components = texture2D(iChannel0, uv).xyz;
    vec3 norm = normalize(components);
    fragColor = vec4(0.5 + norm.z);
}