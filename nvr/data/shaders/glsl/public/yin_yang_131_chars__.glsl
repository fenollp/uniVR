// Shader downloaded from https://www.shadertoy.com/view/ldVGzK
// written by shadertoy user GregRostami
//
// Name: Yin Yang 131 chars!!
// Description: This is my version of the Yin Yang challenge in one tweet that was started by s23b:&lt;br/&gt;https://www.shadertoy.com/view/4sKGRG&lt;br/&gt;Please help me make it better (smaller)
// 131 chars - As the TITANS of optimization (Fabrice & coyote) battle, another 2 chars vanish!
// Added real centering code only added 2 chars.
// A BIG thank you to coyote and Fabrice ... this is an algorithmic MIRACLE!!
/**/
void mainImage(out vec4 o,vec2 i)
{
	float a = dot(i=(i+i-(o.xy=iResolution.xy))/o.y,i), b = abs(i.y);
    o += 9./(b>a ? (b-a-.23)*i.y : --a*i.x)-o;
}
/**/

// 121 chars - Not centerd version ... Fabrice, once again did the IMPOSSIBLE!!
/*
void mainImage(out vec4 o,vec2 i)
{
    float a = dot(i=2.*i/iResolution.y-1. ,i), b = abs(i.y);
    o += 9./(b>a ? (b-a-.23)*i.y : --a*i.x) - o;
}
*/

// Here it is centered with Fabrice's optimization - 131 chars (-3 chars because of coyote)
/*
void mainImage(out vec4 o,vec2 i)
{
	i/=iResolution.y*.5;
    i.x-=.8;
    float a = dot(--i,i), b = abs(i.y)-a;
	o += --a*(b>0.? i.y : i.x )*(b-.23)*1e6 -o;
}
*/

// 138 chars - coyote magically made another character disappear 
/*
void mainImage(out vec4 o,vec2 i)
{
    float a = dot(i=2.*i/iResolution.y-1. ,i), b = abs(i.y)-a;
	o = vec4( --a*(b-.23) * (i.x+i.y + sign(b)*(i.y-i.x)) > 0. );
}
*/

// Original version at 139 chars by Greg Rostami
/*
void mainImage(out vec4 o,vec2 i)
{
    float a = dot(i=2.*i/iResolution.y-1. ,i), b = abs(i.y)-a;
	o = o-o+sign( --a*(b-.23) * (i.x+i.y + sign(b)*(i.y-i.x)) );
}
*/