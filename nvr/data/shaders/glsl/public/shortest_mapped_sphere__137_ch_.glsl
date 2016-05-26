// Shader downloaded from https://www.shadertoy.com/view/XstXzs
// written by shadertoy user FabriceNeyret2
//
// Name: shortest mapped sphere (137 ch)
// Description: Could somebody get shorter ? :-) (with same geometry and scalability).
//    
// variant of https://www.shadertoy.com/view/XsdXRl#
// coyote: -1 char   Dave_Hoskins: -2 char

void mainImage( out vec4 O, vec2 U )
{ 	U = 2.2 * U/iResolution.y - 1.1;  
    U.x = acos( U.x / cos( U.y = asin(U.y) )) - iDate.w;
    O = texture2D(iChannel0, .5*U) + 1./U.x;                // 137 black background
  //O = texture2D(iChannel0, .5+.5*U + 1./U.x);             // 140 brown background
  //O = texture2D(iChannel0, .5+.5*U);                      // 133 stripped background
}






/* About the maths:

   Xe = cos(theta)cos(phi)
   Ye = sin(phi)               -> phi = asin(Ye) -> theta = acos(Xe/cos(phi))
   uv = vec2(theta-time,phi) 

   Black background:

   acos = NaN out of the disk
   as a color, Nan is black
   so + 1./Ux forces black out of the disk
*/