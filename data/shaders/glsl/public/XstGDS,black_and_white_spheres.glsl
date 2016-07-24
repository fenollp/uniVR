// Shader downloaded from https://www.shadertoy.com/view/XstGDS
// written by shadertoy user PauloFalcao
//
// Name: Black and White Spheres
// Description: USE YOUR MOUSE!!!
//    
//    A variation of Cubes and Spheres (black and white version)
//    With stochastic sampling anti-aliasing
//    Using buffers for accumulation
//    
//    Original made in Jan 2012 for glslsandbox - http://glslsandbox.com/e#1215.0
//    
// Black and White Spheres / Cubes with anti-aliasing and dof using buffers
// by @paulofalcao
//
// Original made in Jan 2012 for glslsandbox
//
// http://glslsandbox.com/e#1215.0
// 
// ================================
//
// A variation of Cubes and Spheres (black and white version)
// With stochastic sampling anti-aliasing
// Using the backbuffer for acumulation
//
// I love Monte Carlo rendering tecniques! :)
//

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv=fragCoord.xy/iResolution.xy;
	vec4 c=texture2D(iChannel0,uv);
	fragColor=c;
}
