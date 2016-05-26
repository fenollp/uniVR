// Shader downloaded from https://www.shadertoy.com/view/MdcGRl
// written by shadertoy user masaki
//
// Name: rising sun
// Description: rising sun
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color2 =vec4(1. - ((uv.x + uv.y) / 2.),uv,1.);
    vec4 filter = vec4(vec3(smoothstep(0.20,0.26,uv.y)),1.);
    vec2 pos = uv*2.-1.;
    pos.x *= iResolution.x / iResolution.y;
    vec2 center = vec2(pos.x,pos.y- (4.*fract(iGlobalTime/30.)-2.)-0.35);
	fragColor = filter * color2* (pow(2.*(0.9-0.7*length(center)),3.));
}