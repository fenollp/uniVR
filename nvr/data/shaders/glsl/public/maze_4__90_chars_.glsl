// Shader downloaded from https://www.shadertoy.com/view/4scGWf
// written by shadertoy user FabriceNeyret2
//
// Name: maze 4 (90 chars)
// Description: shortest possible maze :-)
// inspired from   https://www.shadertoy.com/view/4sSXWR


// Shane version: 90 chars 

void mainImage( out vec4 O,  vec2 U )
{  O += .1/ fract(   sin(1e5*length (ceil(U/=8.))) < 0.  ? U.x : U.y ) - O; }

/**/




/* // Fabrice version : 108 chars

void mainImage( out vec4 O,  vec2 U )
{ O += .1/ fract( fract(1e5*sin(dot(ceil(U/=8.),vec2(39,.172)))) > .5 ? U.x : U.y ) -O;  }
                        // time variant :       ceil(iDate.zw)

/**/