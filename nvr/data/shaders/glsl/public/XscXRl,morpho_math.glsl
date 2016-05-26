// Shader downloaded from https://www.shadertoy.com/view/XscXRl
// written by shadertoy user FabriceNeyret2
//
// Name: morpho math
// Description: morphological mathematics transform. Choose operator, radius and brush in Buf B and C.
//    E.g. closing = dilatation then erosion, opening = erosion then dilation
//    (for dilatation or erosion only, choose neutral as second operation).
// here, use of the morphological operator

void mainImage( out vec4 O,  vec2 U )
{
    O = texture2D(iChannel0,U/iResolution.xy);
  //O = pow(O,vec4(1./3.));
}