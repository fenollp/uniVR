// Shader downloaded from https://www.shadertoy.com/view/ldVGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Contrast
// Description: basic filter contrast
void contrast( inout vec3 color, float adjust ) {
    adjust = adjust + 1.0;
    color.rgb = ( color.rgb - vec3(0.5) ) * adjust + vec3(0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    contrast(color, 1.0);
	fragColor = vec4(color, 1.0);
}