// Shader downloaded from https://www.shadertoy.com/view/Xt2Gzz
// written by shadertoy user netgrind
//
// Name: ngTweet2
// Description: another tweet sized shader
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float i=iGlobalTime;vec2 uv=sin(fragCoord.xy*.02);float a=atan(uv.y,uv.x);fragColor=vec4(sin(i+a*sin(uv.yxy)*a*length(uv+sin(i+a*a))),1.0);
}