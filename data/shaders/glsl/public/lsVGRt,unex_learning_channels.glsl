// Shader downloaded from https://www.shadertoy.com/view/lsVGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Channels
// Description: basic channels filter : lets you modify the intensity of any combination of red, green, or blue channels individually.
void channels( inout vec3 color, in vec3 channels , float adjust ) {
    if (channels == vec3(0)) return;

    if (channels.r != 0.0)
    	if (channels.r > 0.0)
        	color.r += (1.0 - color.r) * channels.r;
        else
        	color.r += color.r * channels.r;

    if (channels.g != 0.0)
    	if (channels.g > 0.0)
        	color.g += (1.0 - color.g) * channels.g;
        else
        	color.g += color.g * channels.g;

    if (channels.b != 0.0)
    	if (channels.b > 0.0)
        	color.b += (1.0 - color.b) * channels.b;
        else
        	color.b += color.b * channels.b;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    channels(color, vec3(0.2, -0.4, -0.05) , 0.0);
	fragColor = vec4(color, 1.0);
}