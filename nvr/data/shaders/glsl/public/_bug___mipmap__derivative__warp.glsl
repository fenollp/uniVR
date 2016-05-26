// Shader downloaded from https://www.shadertoy.com/view/XscSz2
// written by shadertoy user FabriceNeyret2
//
// Name: 'bug', MIPmap, derivative, warp
// Description: tuto and explaination about classical bugs that indeed are not glsl bugs,, but related to calculation of derivative on GPU.

/* MIPmap LOD are based on texture coordinates derivatives.
   by default approximate derivative are obtained based on the GPU SIMD parallelism, 
   using the value of neighbor pixel within a 2x2 fix neighborhood.
   (SIMD granuarity is within a warp of 32 pixels or less, but at least a 2x2 fix neighborhood).

   Here we draw a black line and return at R.y/2 + .5 on the right, and R.Y/2 - .5 on the left
   ( pixels coordinates are integers + .5 ).

   This prevent the derivatives to be computed correctly for the neighboor pixels on the same warp.

   On my machine at usual resolution, the buggy line is thus asymetric and different on left vs right size.

   -> when using MIPmap and having texture masked by something at some places, 
      take care to still compute the texture coordinates.
      (this might be tricky close to the border of a patch. at Least, clamp).

   So, slight offset in the image might cause or hide a bug, e.g. the wrap of atan().
   ( if it occurs inside a warp the derivarive will be huge, while if it occurs between
     2 warps it won't ).

   Note also than R/2 is not always even, with can impact this kind of things at centering.
   (red disk at bottom left corner).

   see also https://www.shadertoy.com/view/Xd3Xz2
*/


void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy;
    if (fract(R.y/2.)!=0. && length(U)<30.) { O=vec4(1,0,0,1); return;}
  //O = vec4(fract(U.y)==.5); return;
    U -= R/2.;  // attention: for odds iResolution.y, U.y are now integers !
    
    if (U.y==.5*sign(U.x)) { O=vec4(0.); return;}  // try commenting this one.
    
    O = (texture2D(iChannel0,U/R,6.)-.5)*3.+.5;
        
    if (U.y==.5*sign(U.x)) { O=vec4(0.); return;}  
}