// Shader downloaded from https://www.shadertoy.com/view/4tsXRM
// written by shadertoy user FabriceNeyret2
//
// Name: Skyline3 - 156 chars
// Description: my variant  of  GregRostami https://www.shadertoy.com/view/MtXSR7 variant of  gsingh93 shader  https://www.shadertoy.com/view/4tXSRM#  :-D
void mainImage(out vec4 f, vec2 u) {
    u /= iResolution.xy;
    f.g=.3;
    for (float i=1.; i < 20.; i++) 
		f = u.y < .7+.2*sin(2e2*u.x/i+9.*i+iDate.w) -.04*i ? i*vec4(.1,.04,.01,1) : f; 
}