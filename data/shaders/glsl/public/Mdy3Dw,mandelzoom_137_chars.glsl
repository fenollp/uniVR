// Shader downloaded from https://www.shadertoy.com/view/Mdy3Dw
// written by shadertoy user GregRostami
//
// Name: Mandelzoom 137 chars
// Description: Trying to get a semi-pretty Mandelbrot zoom in one tweet. Please help.
//    The Mandelbrot code is from Fabrice's https://www.shadertoy.com/view/4sK3Dz
//    The zoom code is a modification of iq's https://www.shadertoy.com/view/lllGWH
// The Mandelbrot code is from FabriceNeyret2 and the zoom is a mod of iq's 2TC Mandelzoom.
// Thanks to coyote we saved another 3 chars:
/**/
void mainImage( out vec4 O, vec2 p ) 
{
    O-=O;
    for (int i=0; i < 97; i++) 
       O.gr = .55 - mat2(O.gr,-O.r,O.g)*O.gr + (p/iResolution.y-.8)*(1.+cos(.2*iDate.w));
}
/**/

// Mandelbrot facing the correct direction and centered (147 chars):
/*
void mainImage( out vec4 O, vec2 p ) 
{
    O-=O;
    p = p/iResolution.y-.2;
    p.x -= .6;
    for (int i=0; i < 97; i++) 
       O.gr = .55 - mat2(O.gr,-O.r,O.g)*O.gr - p*(1.+cos(.2*iDate.w));
}
*/

// Here's a version that's bigger than one tweet with better motion (144 chars):
/*
void mainImage( out vec4 O, vec2 p )
{
    O-=O;
    for (int i=0; i < 97; i++)
    O.gr = .56 - mat2(O.gr,-O.r,O.g)*O.gr + (p/iResolution.y-.8)*pow(.01,.9+cos(.2*iDate.w));
}
*/

// The original code at 140 chars
/*
void mainImage( out vec4 O, vec2 p ) 
{
    O-=O;
    for (int i=0; i < 99; i++) 
       O.yx = -(mat2(O.yx,-O.x,O.y)*O.yx-.55+(p/iResolution.y-.5)*(1.+cos(iDate.w*.2)));
}
*/