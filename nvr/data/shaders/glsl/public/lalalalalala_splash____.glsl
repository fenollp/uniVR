// Shader downloaded from https://www.shadertoy.com/view/4tlXWl
// written by shadertoy user aiekick
//
// Name: lalalalalala Splash !!!
// Description: :)
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


//#define pattern sin(1.5)

// thanks to FabriceNeyret2
#define pattern sin(1.+fract(.7971*floor(iDate.w/2.)))

#define extent 7.2

// from dgreensp => https://www.shadertoy.com/view/4ljGDd
float magicBox(vec3 p) 
{
    vec3 uvw = p;
	p = 1. - abs(1. - mod(uvw, 2.));
    float lL = length(p), nL = lL, tot = 0., c = pattern;
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
	vec2 uv = 12.*(2.*g-s)/s.y * .2;

	float a = 0.;
	if (uv.x >= 0.) a = atan(uv.x, uv.y) * .275;
    if (uv.x < 0.) a =  3.14159 - atan(-uv.x, -uv.y) * 1.66;
    
	float t = mod(iDate.w, 2.);
	t = exp(t*50.-10.);
	if (t>extent) t = extent;
	
	float fc = magicBox(vec3(uv,a)) + 1.;
	fc = 1.-smoothstep(fc, fc+0.001, t/dot(uv,uv));
	
	vec3 tex = texture2D(iChannel0, g/s).rgb;
	vec3 splash = vec3(1.-fc)*vec3(.42, .02, .03);
	
	f.rgb = mix(tex,splash, (splash.r==0.?0.:1.));
}