// Shader downloaded from https://www.shadertoy.com/view/4sV3zd
// written by shadertoy user blfunex
//
// Name: Unex learning Grayscale
// Description: basic grayscale shader
void grayscale( inout vec3 color ) {
    // float avg = (color.r + color.g + color.b) / 3.0;
    float avg = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
	color.rgb = vec3(avg);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    grayscale(color);
	fragColor = vec4(color, 1.0);
}