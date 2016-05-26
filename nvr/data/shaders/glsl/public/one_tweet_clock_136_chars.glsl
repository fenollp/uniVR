// Shader downloaded from https://www.shadertoy.com/view/XddSRN
// written by shadertoy user GregRostami
//
// Name: One Tweet Clock 136 chars
// Description: Here are the One Tweet versions of the clock shader that was started here: https://www.shadertoy.com/view/MsdXzH&lt;br/&gt;We decided to separate these shaders since they are different enough from the original idea.
// 136 chars - After many EPIC battles between Fabrice and Andre, coyote made this:
// Infinite hands, with indicators and colors
// Red is hours, Green is minutes & Blue is seconds.
/**/
#define N 1e-3 / (1.-cos(atan(i.x,i.y) 
void mainImage(out vec4 o,vec2 i)
{
	i+=i-iResolution.xy;
	o =  N-iDate.w/vec4(6875,573,9.55,1)))
        +N*12.));
}
/**/

// 163 chars - Fabrice created this colorful clock
// On hands, indicators & colors
/*
#define N 1e-3 / ( 1.-cos(atan(i.x,i.y) 
void mainImage(out vec4 o,vec2 i) {
	i -= o.xy = iResolution.xy*.5;
	o  = length(i/o.y)>.9 ? o-o :  N-iDate.w/vec4(6875,573,9.55,1))) + N*12.));
}
*/

// 116 chars - Jedi Master Fabrice created the smallest clock from one of Andre's ideas:
/*
void mainImage(out vec4 o,vec2 i)
{
	i+=i-iResolution.xy;
	o = 1e-4 / (1.-cos(atan(i.x,i.y)-iDate.w/vec4(6875,573,9.55,1)));
}
*/

// 137 chars - Andre reduced Fabrice's shader with some clever macro tricks
// Infinite hands, no indicators, B&W
/*
#define N +vec4(.998<cos(atan(i.x,i.y)-iDate.w/
void mainImage(out vec4 o,vec2 i)
{   
    i+=i-(o.xy=iResolution.xy);
    o  = N 573.))     // minutes
         N 9.55))     // seconds
         N 6875.));   // hours      
}
*/

// 147 chars - Soon afterwards, Fabrice added indicators
/*
#define N(t) +vec4(cos(iDate.w/t atan(i.x,i.y))>.998)
void mainImage(out vec4 o,vec2 i)
{   
    i+=i-iResolution.xy;
    o  =  N(1e9 - 12.*) // 12 hour indicators
        N(573. -)     // minutes
         N(9.55 -)     // seconds
         N(6875.- );   // hours      
}
*/

// 140 chars - Fabrice started the one tweet clock shader with this:
// Infinite hands, no indicators, B&W
/*
#define N(t) +vec4(cos(iDate.w/t - atan(i.x,i.y))>.998)
void mainImage(out vec4 o,vec2 i)
{   
    i+=i-(o.xy=iResolution.xy);
    o  = N(573. )     // minutes
         N(9.55 )     // seconds
         N(6875. );   // hours      
}
*/