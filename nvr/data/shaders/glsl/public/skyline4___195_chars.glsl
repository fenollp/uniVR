// Shader downloaded from https://www.shadertoy.com/view/XlsXRM
// written by shadertoy user FabriceNeyret2
//
// Name: Skyline4 - 195 chars
// Description: another variant  of  GregRostami https://www.shadertoy.com/view/MtXSR7 variant of  gsingh93 shader  https://www.shadertoy.com/view/4tXSRM#  :-D
#define S(k) i*i/1e4*sin(k*2e2*u.x/i+9.*i+iDate.w/k)
    
void mainImage(out vec4 f, vec2 u) {
    u /= iResolution.xy;
    for (float i=1.; i < 22.; i++) 
		f = u.y < .7-.03*i  +2.*S(1.)+S(2.)+.5*S(5.) ? i*vec4(0,.03,1,1) : f+.05; 
}