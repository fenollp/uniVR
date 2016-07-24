// Shader downloaded from https://www.shadertoy.com/view/lsKGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Noise
// Description: basic noise filter
// http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand( vec2 co ){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 0.5 - 0.25;
}

void noise( inout vec3 color, vec2 uv, float level ) {
    color.rgb = max(min(color.rgb + vec3(rand(uv) * level), vec3(1)), vec3(0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    noise(color, uv, 0.5);
	fragColor = vec4(color, 1.0);
}