// Shader downloaded from https://www.shadertoy.com/view/MsdXzH
// written by shadertoy user GregRostami
//
// Name: Smallest Clock 169 chars
// Description: This is a continuation of the shader that Fabrice and I worked on https://www.shadertoy.com/view/MdK3Wt&lt;br/&gt;I am desperately trying to shorten this shader.&lt;br/&gt;Please help!!
// 169 chars - Grand Master, Dave Hoskins, gave us the final version ...
// Sith Lord Andre, shaved another char off centering coordinates:
#define N(t) +vec4(length(i/=.8)<o.y&&cos(iDate.w/t-atan(i.x,i.y))>.998)
void mainImage(out vec4 o,vec2 i)
{   
    i-=o.xy=iResolution.xy*.5;
    o  = N(1e9-12.*) // 12 hour indicators
         N(573.)     // minutes
         N(9.55)     // seconds
         N(6875.);   // hours      
}

// 173 chars - As always, Fabrice SQUEEZES this shader by using some never-before-seen macro tricks.
// coyote delivers THE KO punch for another Shadertoy MIRACLE!!
/*
#define N(t) +vec4(length(i/=.9)<o.y&&cos(iDate.w/t atan(i.x,i.y))>.998)
void mainImage(out vec4 o,vec2 i)
{   
    i+=i-(o.xy=iResolution.xy);
    o  = N(1e9 - 12.*) // 12 hour indicators
         N(573.- )     // minutes
         N(9.55 -)     // seconds
         N(6875.- );   // hours      
}
*/

// 190 chars - Our new size optimization brother, Andre, did some SERIOUS black magic to remove the rotation matrix!!
/*
#define N(t,s) vec4(length(i)<(o.y*=.9)&&cos(atan(i.x,i.y)*s-iDate.w/t)>.999)+

void mainImage(out vec4 o,vec2 i)
{   
	o = iResolution.xyxy; 
    i -= o.xy*=.5;
    o  = N(1e9,   12.) // 12 hour indicators
         N(573.,  1.) // minutes
         N(9.55,  1.) // seconds
         N(6875., 1.) // hours
        .0;  
}
*/

// 227 chars - coyote reworked the coordinate centering code & reduced the fuction to only TWO variables!
/*
#define N(t,s) +vec4(length(o.xz=i*mat2(cos(iDate.w/t+1.57*vec4(3,0,0,1))))/o.y<++o.w*.1&&cos(atan(o.z,o.x)*s)>.999 )

void mainImage(out vec4 o,vec2 i)
{   
    o = vec4(iResolution,5);
    i += i - o.xy;
    o  = N(6875., 1.) // hours
         N(9.55, 1.) // seconds
         N(573., 1.) // minutes
         N(1e9, 12.); // 12 hour indicators
}
*/

// 235 chars - Fabrice "D Man" Neyret removed the conditional operations at the end of the function
/*
#define N(t,l,s) vec4(length(j=i*mat2(sin(iDate.w/t+1.57*vec4(3,0,0,1))))<l&&cos(atan(j.y,j.x)*s)>.999) +

void mainImage(out vec4 o,vec2 i )
{   
  
	vec2 r = iResolution.xy,j; i = (i+i-r)/r.y;
    o  = N(6875., .6, 1.) // hours
         N(573.,  .8, 1.) // minutes
         N(9.55,  .7, 1.) // seconds
         N(1e9,   .9,12.) // 12 hour indicators
        .0;  
}
*/

// 241 chars - Original shader
/*
#define N(t,l,s) length(j=i*mat2(sin(iDate.w/t+1.57*vec4(3,0,0,1))))<l&&cos(atan(j.y,j.x)*s)>.999?1.:0. +

void mainImage(out vec4 o,vec2 i )
{   
    o-=o;
	vec2 r = iResolution.xy,j; i = (i+i-r)/r.y;
    o += N(6875., .6, 1.) // hours
         N(573.,  .8, 1.) // minutes
         N(9.55,  .7, 1.) // seconds
         N(1e9,   .9,12.) // 12 hour indicators
        .0;  
}
*/