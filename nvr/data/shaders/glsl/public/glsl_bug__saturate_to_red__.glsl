// Shader downloaded from https://www.shadertoy.com/view/llSXDd
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug: saturate to red !
// Description: on linux, red if  line #7   numerator is not 1 , otherwise white !!!
void mainImage( out vec4 o,  vec2 U )
{
    U -= iResolution.xy/2.;
    o = vec4(0);
    
    for (int i=0; i<2; i++) { // i<1: no bug !
        o += 100./dot(U,U);  // on my machine, red if numerator is not 1. !!!
     // o += 2.*U.x;         // same
     // o += 2.*U.x+1.;      // no bug !
     // o += 1.*U.x;         // no bug !
     // o += 2.+U.x;         // no bug !
     // o = o-o+ 2.*U.x;     // no bug !
     // o += vec4(2.)*U.x;   // no bug !
    }
 
    o = clamp(o,0.,1.);    // just to check, but bug already there before
}