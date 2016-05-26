// Shader downloaded from https://www.shadertoy.com/view/lst3R4
// written by shadertoy user FabriceNeyret2
//
// Name: blur wave illusion
// Description: do you see a displacement in the pattern ?

void mainImage( out vec4 o, vec2 u )
{
	vec2 R = iResolution.xy;
         u = (u+u-R) / R.y;
    
    float t = iGlobalTime,
        l = .5+.5*sin(6.28*(length(u)-t));
    o = texture2D(iChannel0, u,2.*l);  

}