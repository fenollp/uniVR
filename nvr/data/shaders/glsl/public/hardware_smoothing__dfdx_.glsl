// Shader downloaded from https://www.shadertoy.com/view/XdfXzH
// written by shadertoy user FabriceNeyret2
//
// Name: hardware smoothing (dFdx)
// Description: cheap smoothing using hardware derivative (limited, but basically for free).
//    Space to toggle ON/OFF
#define SMOOTH .5 // 0., 1., or sub-relaxation
vec2 FragCoord;

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}
//  End of Created by inigo quilez

bool keyToggle(int ascii) 
{	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }


// --- the smoothing function using the neighboor pixels value

float smooth(float v) 
{
	float vx = -dFdx(v)*(2.*mod(FragCoord.x-.5,2.)-1.),
		  vy = -dFdy(v)*(2.*mod(FragCoord.y-.5,2.)-1.);

	return v + SMOOTH*(vx+vy)/3.;
}

vec4 smooth(vec4 v) 
{
	vec4  vx = -dFdx(v)*(2.*mod(FragCoord.x-.5,2.)-1.),
		  vy = -dFdy(v)*(2.*mod(FragCoord.y-.5,2.)-1.);

	return v + SMOOTH*(vx+vy)/3.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
    FragCoord=fragCoord;
    
#define IMAGE 2 // test case

#if IMAGE == 1
	float v = mod(uv.x+uv.y,2.);
#elif IMAGE == 11
	float v = (uv.x-uv.y < 0.) ? 1. : 0.;
#elif IMAGE == 2
	float v = noise(vec3(4.*uv,0.));
#elif IMAGE == 3
	vec4 v = texture2D(iChannel0, 2.*uv/iResolution.xy,0.);
#endif
	
#define TEST 0 // smoothing (0) vs debug visualization (>0) 
	
#if TEST == 0
	if (keyToggle(32)) {
		v = smooth(v);
		if (length(uv/iResolution.y-vec2(.1,.1))<.05) { fragColor = vec4(1.,0.,0.,0.); return; }
	}
	else
		if (abs(.05-length(uv/iResolution.y-vec2(.1,.1)))<.003) { fragColor = vec4(1.,0.,0.,0.); return; }
	
	//fragColor = vec4(v/2.); // to check values > 1.
	fragColor = vec4(v);

#elif TEST == 1
	fragColor = vec4(.5*(dFdx(v)+1.),
						.5*(dFdy(v)+1.),
						0.,1.); 
#elif TEST == 2
	fragColor = vec4(mod(fragCoord.x-.5,2.), 
						mod(fragCoord.y-.5,2.), 
						0.,1.); 
#elif TEST == 3
	fragColor = vec4(.5*((2.*mod(fragCoord.x,2.)-1.)+1.), 
						.5*((2.*mod(fragCoord.y,2.)-1.)+1.),
						0.,1.); 
#elif TEST == 4
	fragColor = vec4(.5*(dFdx(v)*(2.*mod(fragCoord.x,2.)-1.)+1.), 
						.5*(dFdy(v)*(2.*mod(fragCoord.y,2.)-1.)+1.),
						0.,1.); 
#endif
	
}