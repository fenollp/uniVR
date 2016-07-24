// Shader downloaded from https://www.shadertoy.com/view/4stGRl
// written by shadertoy user efrailustun
//
// Name: adasd
// Description: asda
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}