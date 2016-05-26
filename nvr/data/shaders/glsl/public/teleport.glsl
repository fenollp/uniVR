// Shader downloaded from https://www.shadertoy.com/view/ltBGRW
// written by shadertoy user macbooktall
//
// Name: teleport
// Description: circles 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy*2.0-5.0;
    float g = sin(uv.x*12.0+sin(uv.x*50.0)*(4.0*sin(10.0 + iGlobalTime*2.0))+sin(10.0 + (iGlobalTime+10.0)*2.0*uv.y)*2.0);
    fragColor = vec4(0.0, g, 0.0 ,1.0);
}