// Shader downloaded from https://www.shadertoy.com/view/4tSSDK
// written by shadertoy user Duke
//
// Name: Tornado 1
// Description: Port of tornado example from this [url]http://www.html5rocks.com/en/tutorials/casestudies/oz/[/url] topic with some optimizations.
// Port of tornado example from this http://www.html5rocks.com/en/tutorials/casestudies/oz/ topic with some optimizations.
// I express deep gratitude to Dmytry Lavrov for creating and assistance in porting this shader

//The "Storm Shader" by Dmytry Lavrov, Copyright 2012 (http://dmytry.com/) with permission from Moritz Helmsteadter at
//The Max Plank Institute is licensed under a Creative Commons attribution license http://creativecommons.org/licenses/by/3.0/
//free to share and remix for any purpose as long as it includes this note.
//Uses 'Computed noise' by Flavien Brebion.
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

const float spin_speed=1.0;

const int number_of_steps=160; // number of isosurface raytracing steps
const float base_step_scaling=0.6; // Larger values allow for faster rendering but cause rendering artifacts. When stepping the isosurface, the value is multiplied by this number to obtain the distance of each step
const float min_step_size=0.4; // Minimal step size, this value is added to the step size, larger values allow to speed up the rendering at expense of artifacts.

const float tornado_bounding_radius=35.0;

#define pi 3.14159265
#define R(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)

/* original noise
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )/// 'Computed noise' by Flavien Brebion.
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0+p.z*137.0;
    float res = 1.0-2.0*mix(
	    mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
	    mix(mix( hash(n+  137.0), hash(n+  138.0),f.x), mix( hash(n+ 57.0+137.0), hash(n+ 58.0+137.0),f.x),f.y),
	    f.z
    );
    return res;
}
*/

// iq's noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}

mat2 Spin(float angle){
	return mat2(cos(angle),-sin(angle),sin(angle),cos(angle));
}

float ridged(float f){
	return 1.0-2.0*abs(f);
}

// The isosurface shape function, the surface is at o(q)=0
float Shape(vec3 q)
{
    q.y += 45.0;
    float h = 90.0;
	float t=spin_speed*iGlobalTime;
	//if(q.y<0.0)return length(q);
	vec3 spin_pos=vec3(Spin(t-sqrt(q.y))*q.xz,q.y-t*5.0);
	float zcurve=pow(q.y,1.5)*0.03;
	float v=abs(length(q.xz)-zcurve)-5.5-clamp(zcurve*0.2,0.1,1.0)*noise(spin_pos*vec3(0.1,0.1,0.1))*5.0;
	v=v-ridged(noise(vec3(Spin(t*1.5+0.1*q.y)*q.xz,q.y-t*4.0)*0.3))*1.2;
    v=max(v, q.y - h);
	return min(max(v, -q.y),0.0)+max(v, -q.y);
}

// Calculates fog colour, and the multiplier for the colour of item behind the fog. 
// If you do two intervals consecutively it will calculate the result correctly.
void FogStep(float dist, vec3 fog_absorb, vec3 fog_reemit, inout vec3 colour, inout vec3 multiplier)
{
    vec3 fog=exp(-dist*fog_absorb);
	colour+=multiplier*(vec3(1.0)-fog)*fog_reemit;
	multiplier*=fog;
}

void RaytraceFoggy(vec3 org, vec3 dir, float min_dist, float max_dist, inout vec3 colour, inout vec3 multiplier)
{
    // camera
    vec3 q=vec3(0.0);

	float d=0.0;
	float dist=min_dist;

	float step_scaling=base_step_scaling;

	const float extra_step=min_step_size;
	for(int i=0;i<number_of_steps;i++)
	{
        q=org+dist*dir;
		float shape_value=Shape(q);
		float density=-shape_value;
		d=max(shape_value*step_scaling,0.0);
		float step_dist=d+extra_step;
		if(density>0.0){
			float brightness=exp(-0.6*density);
			FogStep(step_dist*0.2, clamp(density, 0.0, 1.0)*vec3(1,1,1),vec3(1)*brightness, colour, multiplier);
		}

		if(dist>max_dist || multiplier.x<0.01){
			return;
		}
		dist+=step_dist;
	}
	return;
}

// bounding cylinder from Dmytry Lavrov
bool RayCylinderIntersect(vec3 org, vec3 dir, out float min_dist, out float max_dist)
{ 
	vec2 p=org.xz;
	vec2 d=dir.xz;
	float r=tornado_bounding_radius;
	float a=dot(d,d)+1.0E-10;/// A in quadratic formula , with a small constant to avoid division by zero issue
	float det, b;
	b = -dot(p,d); /// -B/2 in quadratic formula
	/// AC = (p.x*p.x + p.y*p.y + p.z*p.z)*dd + r*r*dd 
	det=(b*b) - dot(p,p)*a + r*r*a;/// B^2/4 - AC = determinant / 4
	if (det<0.0){
		return false;
	}
	det= sqrt(det); /// already divided by 2 here
	min_dist= (b - det)/a; /// still needs to be divided by A
	max_dist= (b + det)/a;	
	
	if(max_dist>0.0){
		return true;
	}else{
		return false;
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 background_color=vec3(0.4, 0.4, 0.7);
    vec3 org = vec3(0., 0., -100.);  
    vec3 dir = normalize(vec3((fragCoord.xy-0.5*iResolution.xy)/iResolution.y, 1.));
    R(dir.yz, -iMouse.y*0.01*pi*2.);
    R(dir.xz, iMouse.x*0.01*pi*2.);
    R(org.yz, -iMouse.y*0.01*pi*2.);
    R(org.xz, iMouse.x*0.01*pi*2.);

    //Raymarching the isosurface:
	float dist=0.0;
	vec3 multiplier=vec3(1.0);
	vec3 color=vec3(0.0);
    float min_dist=0.0;
    float max_dist=200.0;

    if(RayCylinderIntersect(org, dir, min_dist, max_dist))
    {
        min_dist=max(min_dist,0.0);    
        RaytraceFoggy(org, dir, min_dist, max_dist, color, multiplier);
        vec3 col=color*0.5+multiplier*background_color;    
		fragColor=vec4(col , 1.0);
    }
    else
    {
        fragColor=vec4(background_color, 1.0);
    }
}
