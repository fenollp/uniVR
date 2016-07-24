// Shader downloaded from https://www.shadertoy.com/view/MtlGzf
// written by shadertoy user macbooktall
//
// Name: kraft diner
// Description: sale
#define M_PI 3.14159265359

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float r = sin(uv.x*22.0+sin(uv.x*10.0)*(4.0*(10.0 + iGlobalTime*2.0))+(100.0 + (iGlobalTime+100.0)*2.0*uv.x)*2.0);
	float g = sin(uv.y*122.0+sin(uv.y*10.0)*(4.0*(10.0 + iGlobalTime*2.0))+(100.0 + (iGlobalTime+100.0)*2.0*uv.y)*2.0);
    fragColor = vec4(r, g, 0.5 - g*r ,1.0);
}