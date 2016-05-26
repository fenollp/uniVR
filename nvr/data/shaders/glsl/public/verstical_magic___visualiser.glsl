// Shader downloaded from https://www.shadertoy.com/view/4lB3D3
// written by shadertoy user uNiversal
//
// Name: Verstical magic - Visualiser
// Description: A very simple vertical audio visualizer
/*
Vertical magic - Visualiser - https://www.shadertoy.com/view/4lB3D3
by: uNiversal - 29th May, 2015
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float fft  = texture2D( iChannel0, vec2(-.0) ).x;

    float bar = texture2D( iChannel0, vec2(uv.x, .7) ).x;
    vec3 barColor = vec3(.001, .005, .03) / abs(bar - uv.x);

    fragColor = vec4(barColor, 1.0);
}
