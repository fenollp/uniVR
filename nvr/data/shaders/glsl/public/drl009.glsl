// Shader downloaded from https://www.shadertoy.com/view/XsVGzG
// written by shadertoy user DrLuke
//
// Name: drl009
// Description: Raymarching texture test

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	fragColor = texture2D(iChannel1, uv);
}