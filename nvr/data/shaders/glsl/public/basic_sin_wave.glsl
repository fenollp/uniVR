// Shader downloaded from https://www.shadertoy.com/view/Xs33RX
// written by shadertoy user masaki
//
// Name: basic sin wave
// Description: simple sin wave
#define PI 3.141592

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pos = PI *(uv*2.-1.);
    vec4 color =vec4(0.2, 0.6, 1., 1.)* abs(sin(20.*pos.y + 20.*sin(pos.x + iGlobalTime)));
   
    fragColor = color;
}