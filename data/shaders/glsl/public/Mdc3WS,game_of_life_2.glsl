// Shader downloaded from https://www.shadertoy.com/view/Mdc3WS
// written by shadertoy user sixstring982
//
// Name: Game of Life 2
// Description: Game of Life. Mainly used as to demo buffers.
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = vec4(uv, 0.5 + 0.5 * sin(iGlobalTime), 1.0);
    if (texture2D(iChannel0, uv).g < 0.5) {
        fragColor = vec4(1.0) - vec4(fragColor.xyz, 0.0);
    }
}