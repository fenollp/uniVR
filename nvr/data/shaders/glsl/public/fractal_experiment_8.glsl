// Shader downloaded from https://www.shadertoy.com/view/ltfXDs
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 8
// Description: use mouse axis x for varying the magic coef of the magicBox Fractal
//    The fractal is extracted from the shader of dgreensp [url=https://www.shadertoy.com/view/4ljGDd]Magic Fractal[/url]
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// from dgreensp => https://www.shadertoy.com/view/4ljGDd
float magicBox(vec3 p) 
{
    p = 1. - abs(1. - mod(p, 2.));
    float lL = length(p), nL = lL, tot = 0., c = 1.;
    if (iMouse.z>0.) c = iMouse.x/iResolution.x;
    for (int i=0; i < 13; i++) 
	{
      p = abs(p)/(lL*lL) - c;
      nL = length(p);
      tot += abs(nL-lL);
      lL = nL;
    }
    return tot;
}

void mainImage(out vec4 f, vec2 g)
{
	vec2 s = iResolution.xy;
	
	vec2 uv = (2.*g-s)/s.y * .2;

	// count arms
	float n = 15.0;
	
	// angle 
	float a = atan(uv.y,uv.x);
	
	// ratio y
	float ry = sqrt(g/s).y;
	
	// bg
	vec3 topColor = vec3(.96,.98,.21);
	vec3 bottomColor = vec3(1,.32,.2);
	f.rgb = mix( topColor, bottomColor, ry );
	
	// fractal
	float fc = magicBox(vec3(uv,.005/dot(uv*ry,uv))) + a*n + iDate.w*3.;
	fc = cos(fc) + .001/dot(uv,uv);
	fc = 1.-smoothstep(fc, fc+0.001, ry);
	
	f.rgb += fc;
}