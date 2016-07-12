// Shader downloaded from https://www.shadertoy.com/view/lscXWX
// written by shadertoy user FabriceNeyret2
//
// Name: int32 or int24 ?
// Description: white if your GPU have 32 bit 
//    black or compile error is your GPU use less than 32bits or use floats for int arithmetic.
  #define MAXINT 2147483647  // 32 bits   // try +1 or -1, just to check :-)
//#define MAXINT    8388608  // 24 bits
//#define MAXINT      32768  // 16 bits

void mainImage( out vec4 O,  vec2 U )
{
	U /= iResolution.xy;
    int i = MAXINT - int(fract(U.x));  // to forbid optimization
	O = vec4(i-(MAXINT-1));
  //O = vec4(float(i)-float(MAXINT-1));
}