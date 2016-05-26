// Shader downloaded from https://www.shadertoy.com/view/MdK3Wt
// written by shadertoy user GregRostami
//
// Name: 2TC Clock - 280 chars
// Description: This is a modification of Fabrice's clock shader: https://www.shadertoy.com/view/4sVGDd   Jedi Master Fabrice reduced this shader from 345 chars down to 280 chars (less than 2 tweets)!
// 280 chars - Fabrice made it UNDER TWO TWEETS with different size needles & Anti_Aliasing!
/**/
#define N(T,r,l) smoothstep(l,0.,length( clamp(dot(U,R=sin(iDate.w/T+vec2(0,1.57)) ),0.,r) *R-U)) +

void mainImage( out vec4 O,vec2 U )
{
    
	vec2 R=iResolution.xy; U = (U+U-R)/R.y;
    O +=  N( 6875., .6, .04)
          N( 573.,  .8, .03)
          N( 9.55,  .7, .01)
          max(1e2*cos(atan(U.y,U.x)*12.)-99.,0.)*step(abs(length(U)-.8),.1)
        -O;
}
/**/

// 245 chars - smallest version with same length needles
/*
#define N(T,l) length( clamp(dot(U,R=sin(iDate.w/T+vec2(0,1.57)) ),0.,.6) *R-U)<l||

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy; U = (U+U-R)/R.y;

    N( 6875., .04)
    N( 573.,  .03)
    N( 9.55,  .01)
    abs(length(U)-.8)<.1&&cos(atan(U.y,U.x)*12.)>.99? O ++ : O ;  
}
*/

// 272 chars - GRAND MASTER FABRICE does it AGAIN! WOW!!
/*
#define N(T,w) .4>length( clamp(dot(U,R=sin(t/T+vec2(0,1.57)) ),0.,.6) *R-U)/w? O++ :O

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy; U = (U+U-R)/R.y;
    float a = atan(U.y,U.x)*12., t = iDate.w/60.;
    abs(length(U)-.8)<.1&&cos(a)>.99? O ++ : O ;
    N( 114.6, .1 );
    N( 9.55,  .07);
    N( .159,  .03);      
}
*/

// 295 chars - Fabrice made the dials the same length
/*
#define N(T,w) l<.6&&.4>length(max(0.,dot(U,d=sin(t/T+vec2(0,1.6)))/dot(d,d))*d-U)/w? O++ :O

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy,d;
    float,l = length(U = (U+U-R)/R.y), a = atan(U.y,U.x)*12., t = iDate.w/60.;
    abs(l-.8)<.1 ? O += cos(4.*a)+cos(a)-1. : O ;
    N( 114.6, .1 );
    N( 9.55,  .07);
    N( .159,  .03);      
}
*/

// 315 chars - Fabrice's latest version without -AliasinAntig
/*
#define N(T,r,w) d=sin(t/T+vec2(0,1.6)); l<r&&.4>length(clamp(dot(U,d)/dot(d,d),0.,1.)*d-U)/w? O-=O++ :O;

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy,d;
    float,l = length(U = (U+U-R)/R.y), a = atan(U.y,U.x)*12., t = iDate.w/60.;
    abs(l-.8)<.1 ? O += cos(4.*a)+cos(a)-1. : O ;
	N( 114.6, .6, .1 );
	N( 9.55,  .8, .07);
	N( .159,  .7, .03);     
}
*/

// 343 chars - Fabrice's version + Anti-Aliasing
/*
#define z(b) length( clamp( dot(U,b)/dot(b,b), 0.,1.) *b - U )
#define N(t,r,w)d=sin(6.283*t+vec2(0,1.6)); a = smoothstep(.4,e,z(d)/w); O = l<r ? 1.-a+a*O :O;

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy,d;
    float e=.6,s=60.,l = length(U = (U+U-R)/R.y), a = atan(U.y,U.x)*12., t = iDate.w/s;
    abs(l-.8)<.1 ? O += cos(4.*a)+cos(a)-1. : O ;
    N( t/s/12., e, .1);
    N( t/s,    .8, .07);
    N( t,       e, .03);      
}
*/

// 345 chars - Size optimization help from Dave & Fabrice:
/*
#define z(b) length( clamp( dot(U,b)/dot(b,b), 0.,1.) *b - U )
#define N(t,r)d=sin(6.283*t+vec2(0,1.6)); a = step(e,z(d)/(r*.1)); O = l<r ? 1.-a+a*O :O;

void mainImage( out vec4 O,vec2 U )
{
    O-=O;
	vec2 R=iResolution.xy,d;
    float e=.6,s=60.,l = length(U = (U+U-R)/R.y), a = atan(U.y,U.x), t = iDate.w/s;
    if (abs(l-.8)<.1 && cos(12.*a)>e) O += cos(48.*a);
    N( t/s/12., e);
    N( t/s,    .8);
    N( t,       e);      
}
*/