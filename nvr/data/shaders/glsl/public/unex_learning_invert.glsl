// Shader downloaded from https://www.shadertoy.com/view/MdKGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Invert
// Description: basic inverting shader
void invert( inout vec3 color ) {
	color.rgb = vec3(1).rgb - color.rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    invert(color);
	fragColor = vec4(color, 1.0);
}