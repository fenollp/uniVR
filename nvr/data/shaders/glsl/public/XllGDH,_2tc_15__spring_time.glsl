// Shader downloaded from https://www.shadertoy.com/view/XllGDH
// written by shadertoy user bergi
//
// Name: [2TC 15] spring time
// Description: It's cold outside while GPUs are running hot..
// yeah, spring is due
//
// For-fun entry for the 2 Tweets Challenge
// (c) stefan berke
// 
// credits to Kali for the magic formula
// can not stop using it...
//
void mainImage( out vec4 f, in vec2 w )
{
	float t = iGlobalTime/11.;
    vec2 uv = (.2 + .05 * sin(t*1.1)) * w / iResolution.y + .2 * vec2(2.2+1.*sin(t), .4+.4*cos(t*.9));
    
    for (int i=0; i<11; ++i)
        uv = abs(uv) / dot(uv,uv) - vec2(.81-.1*uv.y);
    
	f = vec4(uv*uv, uv.y-uv.x, 1.);
}