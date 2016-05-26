// Shader downloaded from https://www.shadertoy.com/view/4tXSWs
// written by shadertoy user aiekick
//
// Name: Warp Experiment 4
// Description: use the mouse for move the warp
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// uv, offset, force, range
vec2 warp(vec2 uv, vec2 m, float f, float z) 
{
	vec2 mo = 5.*(2.*m-iResolution.xy)/min(iResolution.x,iResolution.y), mouv = mo-uv;;
	return uv - f*exp(-dot( mouv, mouv)/abs(z)) * mouv;
}

void mainImage( out vec4 f, in vec2 g )
{
	// base uv
	vec2 uv = 5.*(2.*g-iResolution.xy)/min(iResolution.x,iResolution.y);
	
    // mouse pos (init : screen center)
    vec2 m = iResolution.xy/2.;
    if (iMouse.z>0.) m = iMouse.xy;
    
	// main warp
    float ft = sin(iGlobalTime*.2)*5.;
    uv = warp(uv, m, ft, 16.);

	// repeat
	vec2 rp = vec2(1);
	uv = mod(uv, rp) -rp/2.;
	
	// Color
    vec3 c = vec3(0.8,0.2,0.2);
    
    // vertical lines
    float vlines = smoothstep(.16, .25, dot(uv.x, uv.x)); // meta axis x
    
    // horizontal line
    float hlines = smoothstep(.16, .25, dot(uv.y, uv.y)); // meta axis y
	
    c *= vlines + hlines;
    
	f = c.xyzx;
}