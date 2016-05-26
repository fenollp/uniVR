// Shader downloaded from https://www.shadertoy.com/view/XdcGzn
// written by shadertoy user jackdavenport
//
// Name: Faded Edge
// Description: A shader I wrote for a minimap in a game, recreated for Shadertoy. It uses smoothstep to blend the edge and create a fadeoff. Similar to the minimap in Watch Dogs.
#define EDGE .2

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float edge = EDGE * abs(sin(iGlobalTime / 5.));

	fragColor = texture2D(iChannel0, uv);
    fragColor *= (smoothstep(0., edge, uv.x)) * (1. - smoothstep(1. - edge, 1., uv.x));
    fragColor *= (smoothstep(0., edge, uv.y)) * (1. - smoothstep(1. - edge, 1., uv.y));
}