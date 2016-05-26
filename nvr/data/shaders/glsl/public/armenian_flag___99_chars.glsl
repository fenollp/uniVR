// Shader downloaded from https://www.shadertoy.com/view/lscSDj
// written by shadertoy user GregRostami
//
// Name: Armenian Flag - 99 chars
// Description: In memory of the Armenian Genocide, April 24th 1915 ... Inspired by Fabrice's optimized flag shader: https://www.shadertoy.com/view/XstSzf
// 99 chars - Jedi Master Fabrice did it again!
/**/
void mainImage(out vec4 o,vec2 u)
{
    u /= iResolution.y;
    o = vec4(2,.6,.1,1);
    o = u.y>.67 ? --o : u.y > .33 ? .1/o : o;
}
/**/

// After 5 hours of trying EVERYTHING, got it down to 106 chars!
// Can you make it smaller?
/*
void mainImage(out vec4 o,vec2 u)
{
    u /= iResolution.y;
    o -= o;
    o.b = 1.;
	o = u.y>.67 ? o.bgra :
    	u.y<.33 ? vec4(1,.6,0,1) : o;
}
*/

// 110 chars - Original shader
/*
void mainImage(out vec4 o,vec2 u)
{
    u /= iResolution.y;
	o = vec4( u.y>.67||u.y<.33, u.y<.33?.6:0., u.y>.33&&u.y<.67, 1);     
}
*/