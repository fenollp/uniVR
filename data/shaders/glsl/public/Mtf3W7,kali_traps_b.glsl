// Shader downloaded from https://www.shadertoy.com/view/Mtf3W7
// written by shadertoy user bergi
//
// Name: kali-traps b
// Description: variation of https://www.shadertoy.com/view/MtX3DM
//    called &quot;patients is rewarded&quot;
/*	kali-traps by bergi in 2015
	
	only cruising around here, what a fractal
	praise kalibob

	forked from https://www.shadertoy.com/view/MtX3DM, now
	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
*/


// needs some more iters - lowered for webgl
const int  NUM_ITERS = 			45;

const vec3 KALI_PARAM = 		vec3(.5, .396, 1.5007);
//const vec3 KALI_PARAM = 		vec3(.4993, .4046, 1.5);
//const vec3 KALI_PARAM = 		vec3(.47);
const int  KALI_ITERS = 		33;

// animation time
float ti = iGlobalTime * 0.02 + 140.;



/** kali set as usual. 
	returns last magnitude step and average */
vec4 average;
float kali(in vec3 p)
{
    average = vec4(0.);
	float mag;
    for (int i=0; i<KALI_ITERS; ++i)
    {
        mag = dot(p, p);
        p = abs(p) / mag;
        average += vec4(p, mag);
        p -= KALI_PARAM;
    }
	average /= 32.;
    return mag;
}

// steps from pos along dir and samples the cloud
// stp is 1e-5 - 1e+?? :)
vec3 ray_color(vec3 pos, vec3 dir, float stp)
{
    vec3 p, col = vec3(0.);
	float t = 0.;
	for (int i=0; i<NUM_ITERS; ++i)
	{
		p = pos + t * dir;
		float d = kali(p);

		// define a surface and get trapped
		d = (1.3-100.*t) - abs(1.33 - d);
		
		// always step within a certain range
		t += max(0.001, min(0.01, d )) * (stp + 3. * t);

		// some color
		col += (.5+.5*sin(average.rgb*vec3(3.+col.g,5,7)*4.)) 
		// by distance to surface
            / (1. + d * d * 400.);
	}
    
    return clamp(col / float(NUM_ITERS) * 3., 0., 1.);
}

// by David Hoskins https://www.shadertoy.com/view/XlfGWN
float hash(in vec2 uv)
{
	vec3 p  = fract(vec3(uv,ti) / vec3(3.07965, 7.1235, 4.998784));
    p += dot(p.xy, p.yx+19.19);
    return fract(p.x * p.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // ray stepsize - or focus scale 
    float foc = 0.004 + 0.001*sin(ti*0.9);

    // some position
	// - a circular path depending on the stepsize
    float rti = ti * 0.5;
	float rad = 0.04;
    
    if (iMouse.z > .5) {
        foc = pow(iMouse.y / iResolution.y, 2.)/6.;
		//rad = iMouse.x / iResolution.x;
    }
    
	vec3 pos = (vec3(-2.3, 1.19, -3.4)
				+ (0.001+rad)*vec3(2.*sin(rti),cos(rti),0.2*sin(rti/4.)) );
    
	vec2 uv = (fragCoord.xy - iResolution.xy*.5) / iResolution.y * 2.;
    vec3 dir = normalize(vec3(uv, 2.5-length(uv))).xzy;
    rti = ti * 4.;
    dir.xz = vec2(sin(rti)*dir.x-cos(rti)*dir.z, cos(rti)*dir.x+sin(rti)*dir.z);
    
    pos += dir * hash(uv*1114.+ti) * 0.05 * foc;
	
    vec3 col = ray_color(pos, dir, foc)
//			+ 1.5 * ray_color(pos, dir, 0.04)
        ;

	fragColor = vec4(pow(col,vec3(1./1.8)), 1.);	
}
