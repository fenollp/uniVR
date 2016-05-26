// Shader downloaded from https://www.shadertoy.com/view/4scXWB
// written by shadertoy user FabriceNeyret2
//
// Name: star field 5
// Description: star field with flares.
//    variant of https://www.shadertoy.com/view/4scXWS (base on Shane flare idea)
float flare( vec2 U )                            // rotating hexagon 
{	vec2 A = sin(vec2(0, 1.57) + iDate.w);
    U = abs( U * mat2(A, -A.y, A.x) ) * mat2(2,0,1,1.7); 
    return .2/max(U.x,U.y);                      // glowing-spiky approx of step(max,.2)
  //return .2*pow(max(U.x,U.y), -2.);
 
}

#define r(x)     fract(1e4*sin((x)*541.17))      // rand, signed rand   in 1, 2, 3D.
#define sr2(x)   ( r(vec2(x,x+.1)) *2.-1. )
#define sr3(x)   ( r(vec4(x,x+.1,x+.2,0)) *2.-1. )

void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
    U =  (U+U - R) / R.y;
	O -= O+.3;
    for (float i=0.; i<99.; i++)
        O += flare (U - sr2(i)*R/R.y )           // rotating flare at random location
              * r(i+.2)                          // random scale
              * (1.+sin(iDate.w+r(i+.3)*6.))*.1  // time pulse
            //* (1.+.1*sr3(i+.4));               // random color - uncorrelated
              * (1.+.1*sr3(i));                  // random color - correlated
}