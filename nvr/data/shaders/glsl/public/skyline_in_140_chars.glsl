// Shader downloaded from https://www.shadertoy.com/view/MtXSR7
// written by shadertoy user GregRostami
//
// Name: Skyline in 140 chars
// Description: This is a reduction of gsingh93's shader down to one tweet (138 chars).
//    https://www.shadertoy.com/view/4tXSRM#
//    Thanks to 834144373, FabriceNeyret2 and 104 we went from 174 chars down to 138 chars!
//Thanks to 834144373, FabriceNeyret2, 104 and iapafoto we went from 174 to 138 chars!
void mainImage(out vec4 f, vec2 u)
{
    f-=f;
    u /= iResolution.xy;
    for (float i = 1.; i < 20.; i++) 
		f = u.y < sin( ceil(2e2*u.x/i+i*i+iDate.w) ) - .04*i ? f-f+i/20. : f; 
}