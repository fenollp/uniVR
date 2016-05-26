// Shader downloaded from https://www.shadertoy.com/view/lsyGRz
// written by shadertoy user cornusammonis
//
// Name: Particle Attraction
// Description: Particle attraction dynamics with forces calculated by finite differences.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    fragColor = 0.5 + 0.5 * sin(50.0 * texture2D(iChannel1, uv)); 


}