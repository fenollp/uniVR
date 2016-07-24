// Shader downloaded from https://www.shadertoy.com/view/lsdGzf
// written by shadertoy user masaki
//
// Name: holizontal line
// Description: holizontal line
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color2 =vec4(1. - ((uv.x + uv.y) / 2.),uv,1.);
    vec2 pos = uv*20.-10.;
	fragColor = color2*(1./abs(2.*sin(pos.y+20.*sin(iGlobalTime))));
}