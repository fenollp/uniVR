// Shader downloaded from https://www.shadertoy.com/view/MscXWM
// written by shadertoy user FabriceNeyret2
//
// Name: rosace 5 ( 252 chars) 
// Description: rosace (generalisation of https://www.shadertoy.com/view/ls3XWM )
// in the taste of http://9gag.com/gag/am9peXo
// generalisation of https://www.shadertoy.com/view/ls3XWM


/**/  // 252 chars  (-9 tomkh, -8 Fabrice )


#define d  O+=.1*(1.+cos(A=2.33*a+iGlobalTime)) / length(vec2( fract(a*k*7.96)-.5, 16.*length(U)-1.6*k*sin(A)-8.*k)); a+=6.3;
//#define d  O+= (1.+cos(A=2.33*a+iGlobalTime)) * smoothstep(.5,0., length(vec2( fract(a*k*7.96)-.5, 16.*length(U)-1.6*k*sin(A)-8.*k))); a+=6.3;
#define c  d d d  k+=k;

void mainImage(out vec4 O,vec2 U)
{
    U = (U+U-(O.xy=iResolution.xy)) / O.y;
    float a = atan(U.y,U.x), k=.5, A;
    O -= O;
    c c c c
}
/**/




/** // 269 chars

#define A  7./3.*a + iGlobalTime
#define d  O += .1*(1.+cos(A)) / length(vec2( fract(a*k*50./6.283)-.5, 16.*(length(U)-.1*k*sin(A)-.5*k))); a += 6.283;
#define c  d d d k+=k;

void mainImage( out vec4 O, vec2 U )
{

    U = (U+U-(O.xy=iResolution.xy))/O.y;
    float a = atan(U.y,U.x), k=.5;
    
	O -= O;  
    c c c c
    //  O += .2*vec4(0,1,2,0);
}
/**/