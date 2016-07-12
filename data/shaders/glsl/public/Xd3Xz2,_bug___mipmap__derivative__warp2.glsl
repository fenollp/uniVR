// Shader downloaded from https://www.shadertoy.com/view/Xd3Xz2
// written by shadertoy user FabriceNeyret2
//
// Name: 'bug', MIPmap, derivative, warp2
// Description: tuto and explaination about classical bugs that indeed are not glsl bugs, but related to calculation of derivative on GPU.

/* MIPmap LOD are based on texture coordinates derivatives.
   by default approximate derivative are obtained based on the GPU SIMD parallelism, 
   using the value of neighbor pixel within a 2x2 fix neighborhood.
   (SIMD granuarity is within a warp of 32 pixels or less, but at least a 2x2 fix neighborhood).

   So, slight offset in the image might cause or hide a bug,
   here, the wrap of atan() along the horizontal line at the left of the center:

   if it occurs inside a warp the derivarive will be huge, while if it occurs between
   2 warps it won't.
   Here, we display the derivatives of atan() in y and x, 
   and we offset the left half by one vertical pixel to change the alignement with warp.
   The line that should appear would cause a MIPmap blur if atan() was used as texture coord.


   Note also than R/2 is not always even, with can impact this kind of things at centering.
   (red disk at bottom left corner).

   see also https://www.shadertoy.com/view/XscSz2
*/


void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy;
    if (fract(R.y/2.)!=0. && length(U)<30.) { O=vec4(1,0,0,1); return;}
 
    U = (U+U-R)/R.y; 
    float  t = iGlobalTime, eps = float(U.x<-.9)*2./R.y, 
           r = length(U), a = atan(U.y+eps, U.x);

    O = .5+.5*10.*vec4(dFdy(a),dFdx(a),0,1);
}