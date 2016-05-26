// Shader downloaded from https://www.shadertoy.com/view/Md3SDS
// written by shadertoy user FabriceNeyret2
//
// Name: stary hexagon
// Description: variant of https://www.shadertoy.com/view/4scXWS
float f = 1./6.; //  NB: 1./2. crash WebGL driver on Linux/chrome ! 

void mainImage( out vec4 O, vec2 U )
{
    U = abs(U+U - (O.xy=iResolution.xy)) / O.y;
    O += 1. - 2.*pow((  pow(2.*U.x, f) 
                      + pow(U.x + U.y*1.7, f) 
                      + pow(abs(U.x - U.y*1.7), f)
                     )/3., 1./f) -O;
}