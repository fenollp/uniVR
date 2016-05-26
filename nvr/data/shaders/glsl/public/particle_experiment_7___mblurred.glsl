// Shader downloaded from https://www.shadertoy.com/view/Xdt3DB
// written by shadertoy user aiekick
//
// Name: Particle Experiment 7 : MBlurred
// Description: Based on https://www.shadertoy.com/view/MddGWN
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}