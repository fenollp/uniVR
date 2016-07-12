// Shader downloaded from https://www.shadertoy.com/view/MlXSR8
// written by shadertoy user sqlin
//
// Name: tsb
// Description: 颜色改变
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}