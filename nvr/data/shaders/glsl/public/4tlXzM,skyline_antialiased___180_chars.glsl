// Shader downloaded from https://www.shadertoy.com/view/4tlXzM
// written by shadertoy user FabriceNeyret2
//
// Name: Skyline antialiased - 180 chars
// Description: antialiased version of  GregRostami https://www.shadertoy.com/view/MtXSR7 variant of  gsingh93 shader  https://www.shadertoy.com/view/4tXSRM#  :-D
//    NB: replace 15* by 5* if you want a motion-blur effect :-)
void mainImage(out vec4 f, vec2 u) {
    u /= iResolution.xy; 
    float x,c;
    for (float i = 1.; i < 20.; i++)   
		f = u.y+.04*i < sin(c=floor(x= 2e2*u.x/i + 9.*i + iDate.w)) ? 
                             f + min(15.*((x-=c)-x*x),1.) *(i/20.-f)  : f; 

}