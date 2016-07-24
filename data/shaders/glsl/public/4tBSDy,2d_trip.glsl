// Shader downloaded from https://www.shadertoy.com/view/4tBSDy
// written by shadertoy user fantomas
//
// Name: 2D trip
// Description: he
#define _t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy-0.5)*5.;
    float an;
    for (int i=0; i<24; i++)
    {
        an =1.+sin(length(uv/=1.6)*5.+_t/2.);
        uv += normalize(vec2(-uv.y, uv.x))*an/6.;
        uv = abs(uv*=1.8)-_t/20.-2.;        
    }
    float d=length(uv)*2.;
	fragColor = normalize(vec4(sin(d),sin(d*1.2),sin(d*1.3),0.1));
}