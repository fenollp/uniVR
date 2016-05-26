// Shader downloaded from https://www.shadertoy.com/view/Md3XW2
// written by shadertoy user FabriceNeyret2
//
// Name: 2D shuffle 2 ( 127 chars )
// Description: short version of https://www.shadertoy.com/view/MdtXRf
//    (ok, it's a joke, this one is not a real tiling :-) )
void mainImage( out vec4 O, in vec2 U )
{
    O = texture2D(iChannel1, fract(U*= 6./iResolution.xy)/6. + texture2D(iChannel0,floor(U)/8.).x);

  /*
    O = texture2D(iChannel1, fract(U*= 6./iResolution.xy)/6. 
                  + vec2 (texture2D(iChannel0,floor(U)/8.).x,
                          texture2D(iChannel0,floor(U+4.)/8.).x));

  */
}