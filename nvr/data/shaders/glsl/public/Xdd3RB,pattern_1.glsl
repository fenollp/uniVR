// Shader downloaded from https://www.shadertoy.com/view/Xdd3RB
// written by shadertoy user aiekick
//
// Name: Pattern 1
// Description:  Based on the pattern used in https://www.shadertoy.com/view/4sfSzf from nimitz
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// Based on the pattern used in https://www.shadertoy.com/view/4sfSzf from nimitz

float uZoom = 10.;
float uSlider = 0.;
float uColOffset = 0.5;
#define uTime iGlobalTime
vec3 uSlider1 = vec3(1.8,1,2);
float uCellZoom = 0.5;
float uGLow = 1.5;
vec3 uColor2 = vec3(0.2,0.27,0.4);
#define uScreenSize iResolution.xy

void mainImage( out vec4 f, in vec2 g)
{
	vec2 uv = uZoom * (2.*g - uScreenSize)/uScreenSize.y;
	
	uv.y += floor(uv.x + uSlider) * (uColOffset + sin(floor(uv.x) * 0.2 + uTime) * 0.2);
	
	uv = abs(fract(uv)-0.5);
	
	float x = uv.x*uSlider1.x;
	float y = uv.y*uSlider1.y;
	float z = uv.y*uSlider1.z;
	
	float pattern = abs( max(x + y, z) - uCellZoom) * uGLow;
	
	f.rgb = clamp(uColor2/pattern, 0.2,1.2) - 0.2;
}