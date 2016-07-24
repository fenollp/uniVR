// Shader downloaded from https://www.shadertoy.com/view/4slXWn
// written by shadertoy user FabriceNeyret2
//
// Name: Hyper-lightweight2 XOR ...
// Description: Anyway, I prefer this softer look (also smaller code)
//    
//    ( see https://www.shadertoy.com/view/XslXWn , after https://www.shadertoy.com/view/4ssSWn challenge )
#define f(a,b) sin( 50.3* length( u/iResolution.xy*4.-vec2(cos(a),sin(b) ) -3.))
void mainImage( out vec4 o, vec2 u ){float t=iGlobalTime; o = vec4(f(t,t)*f(1.4*t,.7*t));}