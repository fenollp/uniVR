// Shader downloaded from https://www.shadertoy.com/view/MsG3Dy
// written by shadertoy user GregRostami
//
// Name: Yin Yang Redux 138 chars
// Description: This is an update to our attempts to make a Yin Yang in ONE TWEET!&lt;br/&gt;All of the amazing reductions were done with some BIG help from Fabrice and coyote:&lt;br/&gt;https://www.shadertoy.com/view/ldVGzK&lt;br/&gt;
// 138 chars - Added REAL centering code. Regardless of aspect ratio, it's always centered.
// Super Fabrice helped me save 2 more chars ... :)
/**/
void mainImage(out vec4 o,vec2 i)
{
	float a = dot(i = (i + i - (o.xy=iResolution.xy) )/o.y , i), b = abs(i.y);
    o += (a>1. ? .5 : 9./(b-a-.23)/(b>a ? -i.y : i.x))-o;
}
/**/

// Small Spin version - 172 chars:
/*
void mainImage(out vec4 o,vec2 i)
{
    float t=iDate.w, c=cos(t), s=sin(t),
    a = dot(i=mat2(-c,s,s,c)*(2.*i/iResolution.y-1.) ,i), b = abs(i.y);
    o += (a>1. ? .5 : 9./(b-a-.23)/(b>a ? i.y : i.x))-o;
}
*/

// 136 chars - An updated version of the Yin Yang shader that Fabrice, coyote and I size optimized.
// The Yin Yang now has a grey background and spins clockwise ... and still under ONE TWEET!
// Thanks to Fabrice, we saved another 5 chars!!
/*
void mainImage(out vec4 o,vec2 i)
{
	i/=iResolution.y*.5;
    i.x -= .8;
	float a = dot(--i,i), b = abs(i.y);
    o += ( a>1. ? .5 : 9./(b-a-.23)/(b>a ? -i.y : i.x)) - o;
}
*/

// 129 chars - As the TITANS of optimization (Fabrice & coyote) battle, another 2 chars vanish!
// A BIG thank you to coyote and Fabrice ... this is an algorithmic MIRACLE!!
/*
void mainImage(out vec4 o,vec2 i)
{
	i/=iResolution.y*.5;
    i.x-=.8;
	float a = dot(--i,i), b = abs(i.y);
    o += 9./(b>a ? (b-a-.23)*i.y : --a*i.x)-o;
}
*/

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