// Shader downloaded from https://www.shadertoy.com/view/Xdc3R8
// written by shadertoy user aiekick
//
// Name: Easy RM (287c =&gt; 172c)
// Description: based on shader // https://www.shadertoy.com/view/4ljSDt from gilesruscoe 
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
based on shader // https://www.shadertoy.com/view/4ljSDt from gilesruscoe 
*/

// new version by 834144373, coyote, FabriceNeyret2 172c 
void mainImage( out vec4 f, vec2 v )
{
    f.xyz = iResolution;
	
	for (int i = 0; i < 60; i++) 
        f.z += length((v-f.xy*.5)*f.z/f.y + sin(f.z - 3.*iDate.w + vec2(1.6,0))) - 2.;

    f = vec4(1,2,3,1) / (2. + .2*f*f).z;
}/**/

/* new version by FabriceNeyret2 180c
void mainImage( out vec4 f, vec2 v )
{
    vec3 R = iResolution;
    v = (v - R.xy*.5)/R.y;
	
	float s=0.;
    for (int i = 0; i < 60; i++) 
        s += length(v*s + sin(s - 3.*iDate.w + vec2(1.6,0))) - 2.;

	f = vec4(1,2,3,1) / (2. + .2*s*s);
}*/

/* new version with help of the team golf :) FabriceNeyret2 & Coyote 200c
void mainImage( out vec4 f, vec2 v )
{
    vec3 R = iResolution,
        V = normalize(vec3(v - R.xy*.5, R.y));
	
	v /= v;
    for (int i = 0; i < 60; i++) 
        v += length(V.xy * v + sin(V.z * v.x - 3.*iDate.w + vec2(1.6,0))) - 2.;

	f = vec4(1,2,3,1) / (2. + v * v * .2).x;
}*/

/* original 222c
void mainImage( out vec4 f, vec2 v )
{
    f = vec4(normalize(vec3((v + v - (v = iResolution.xy)) / v.y, 2)), iDate.w * 3.);
	
	v /= v;
    for (int i = 0; i < 80; i++)
        v += length(f.xy * v + vec2(cos(f.z * v.x - f.w), sin(f.z * v.x - f.w))) - 2.;

	f = vec4(1,2,3,0) * .5 / (1. + v * v *.1).x;
}*/

/* original code before reducing 287c
void mainImage( out vec4 f, vec2 v )
{
    vec2 s = iResolution.xy;
	vec2 uv = (2.*v - s) / s.y;
    
    float fov = 2.0;
    vec3 r = normalize(vec3(uv, fov));
	vec3 o = vec3(0,0,-iGlobalTime * 3.);
	
   	float t = 0.;
	vec3 p;
    for (int i = 0; i < 80; ++i)
    {
		p = o + r * t;
        p.xy += vec2(cos(p.z),sin(p.z));
        t += length(p.xy) - 2.;
    }

	f.rgb = vec3(.5,1,1.5) / (1. + t * t * .1);
}*/