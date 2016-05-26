// Shader downloaded from https://www.shadertoy.com/view/XdKGWt
// written by shadertoy user FabriceNeyret2
//
// Name: IEEE 'bug': -0 vs +0
// Description: Did you know 0 has a sign :-)  (this would work the same in C/C++)
//    On some operation it can makes a difference (including bugs). Here the most trivial: sign of inverse.
//    Top: is -0 = or &lt; +0
//    Bottom : is 1./-0 = or &lt; 1./+0
// see also https://en.wikipedia.org/wiki/Signed_zero
//          http://www.johndcook.com/blog/2010/06/15/why-computers-have-signed-zero/

void mainImage( out vec4 O, in vec2 U )
{
    U = U/iResolution.xy - .5;
    
    float  m = -0.,   p = +0., // this are equals for == , but encoded differently (bit sign is set)
          im = 1./m, ip = 1./p;
    
	O = vec4(
                U.y>0. ? 
                     U.x<0.  ?  m ==  p :  m <  p   // top :    is -0 = or < +0
                :    U.x<0.  ? im == ip : im < ip   // bottom : is 1./-0 = or < 1./+0
        );

    U = abs(U); if (min(U.x,U.y)<.005) O = vec4(1,0,0,1);
}