// Shader downloaded from https://www.shadertoy.com/view/MddGR8
// written by shadertoy user FabriceNeyret2
//
// Name: OS-dependent look: complex exp
// Description: Many GLSL behaviors are OS/lib/browser/compiler dependent. This one is one of the nasty: a sub-expression (v=...) inside a complex expression is pre-evaluated on Linux, and not on Windows (or version ?), so that these expressions get different results. 
// these disk implementations were proposed by AntoineC in https://www.shadertoy.com/view/XddGR8

void mainImage( out vec4 o, vec2 u )
{
    o-=o;
    
    // windows: white disk?. Linux: red/yellow/white concentric circles. Mac: ?

    o -= 2.*length(u+u - (o.xy=iResolution.xy)) - o.y;

    
    // windows: white disk?. linux: all black. Mac: ?
    
   // o -= 2.*length(u+u - (u=iResolution.xy)) - u.y;
}