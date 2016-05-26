// Shader downloaded from https://www.shadertoy.com/view/MsKGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Vignette
// Description: basic exposure filter
void vignette( inout vec3 color, vec2 uv, float adjust ) {
    color.rgb -= max((distance(uv, vec2(0.5, 0.5)) - 0.25) * 1.25 * adjust, 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    vignette(color, uv, 1.0);
	fragColor = vec4(color, 1.0);
}