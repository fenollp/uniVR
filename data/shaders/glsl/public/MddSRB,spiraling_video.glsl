// Shader downloaded from https://www.shadertoy.com/view/MddSRB
// written by shadertoy user FabriceNeyret2
//
// Name: spiraling video
// Description: .
void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy; U = (U+U-R)/R.y; 
    U = vec2(atan(U.y,U.x)*3./3.1416,log(length(U))); // conformal polar
    // multiply U for smaller tiles
    U.y += U.x/6.; // comment for concentric circles instead of spiral
    O = texture2D(iChannel0, fract(-U+iDate.w));
}
