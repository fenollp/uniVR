// Shader downloaded from https://www.shadertoy.com/view/4dK3WR
// written by shadertoy user cornusammonis
//
// Name: Iterative Blue Noise
// Description: An iterative blue noise generator that uses no tiles, no precomputation, no points, no voronoi, etc. Hit spacebar to reset to a na&iuml;ve initial approximation using white noise. Try it in fullscreen.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 vMouse = iMouse.xy / iResolution.xy;
    float on = texture2D(iChannel3, uv).x;

    fragColor = vec4(on);
}