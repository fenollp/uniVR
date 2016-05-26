// Shader downloaded from https://www.shadertoy.com/view/Xst3WS
// written by shadertoy user hughsk
//
// Name: 2016/01/05
// Description: Revisiting an old thing I made with @MattMcKegg a few months back, now doable in Shadertoy thanks to multipass/feedback :D
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(texture2D(iChannel0, uv).rgb,1.0);
}