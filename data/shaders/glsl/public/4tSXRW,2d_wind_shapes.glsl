// Shader downloaded from https://www.shadertoy.com/view/4tSXRW
// written by shadertoy user aiekick
//
// Name: 2D Wind Shapes
// Description: if this a 2d wind for you ?
//    Mouse x =&gt; period
//    Mouse y =&gt; Amplitude
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
if this a 2d wind cartoon style for you ?

Mouse x => period
Mouse y => Amplitude
*/

// PerAmpThickDec => Period / Amplitude / Thcikness / Decalage X
// res => repeat distance
float getAirWave(vec2 uv, vec4 PerAmpThickDec, float rep, float time)
{
	float 
        val = abs(PerAmpThickDec.z / (uv.y + PerAmpThickDec.y * sin(uv.x / PerAmpThickDec.x + PerAmpThickDec.w))), 
        mask = 0.;
	uv.x += time;
	uv.x = mod(uv.x,rep) - rep * .5;
	val += -2./dot(uv,uv);
	uv.x += rep/2.;
	val += -2./dot(uv,uv);
	uv.x -= rep/4.;
	mask = rep/2./dot(uv,uv);
	val = step(val, .5) + step(mask, 1.);
	return step(val,.5);
}

void mainImage( out vec4 f, in vec2 g )
{
	vec2 s = iResolution.xy;
	
	vec2 uv = 5.*(2.*g - s)/max(s.x,s.y);
	
	vec4 bg = texture2D(iChannel0, g/vec2(s.x,-s.y));

	vec3 col = vec3(0.);
	
    vec4 params = vec4(.65,.37,.198,1.5);
    
    if (iMouse.z>0.) params.x = iMouse.x/s.x;
    if (iMouse.z>0.) params.y = iMouse.y/s.y;
    
	col += vec3(0,.41,1) * getAirWave(uv, params, 10., iGlobalTime * 5.);
	
    col += vec3(0,.41,1) * getAirWave(uv + vec2(5., 2.), params, 10., iGlobalTime * 2.5);
	
	col += vec3(0,.41,1) * getAirWave(uv + vec2(10., -2.), params, 10., iGlobalTime * 7.5);
	
	bg.rgb += col;
    
	f = bg;
}