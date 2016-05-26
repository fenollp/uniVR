// Shader downloaded from https://www.shadertoy.com/view/XdlGzX
// written by shadertoy user 4rknova
//
// Name: Procedural Noise Cubemap
// Description: Use the mouse to control the camera.
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define USE_MOUSE
#define ANIMATE

#define PI			3.14159265359
#define RADIAN		180. / PI
#define CAMERA_FOV	60.4 * RADIAN

float hash(in vec3 p)
{
    return fract(sin(dot(p,vec3(127.1,311.7, 321.4)))*43758.5453123);
}

float noise(in vec3 p)
{
#ifdef ANIMATE
	p.z += iGlobalTime * .75;
#endif
	
    vec3 i = floor(p);
	vec3 f = fract(p); 
	f *= f * (3.-2.*f);

    vec2 c = vec2(0,1);

    return mix(
		mix(mix(hash(i + c.xxx), hash(i + c.yxx),f.x),
			mix(hash(i + c.xyx), hash(i + c.yyx),f.x),
			f.y),
		mix(mix(hash(i + c.xxy), hash(i + c.yxy),f.x),
			mix(hash(i + c.xyy), hash(i + c.yyy),f.x),
			f.y),
		f.z);
}

float fbm(in vec3 p)
{
	float f = 0.;
	f += .50000 * noise(1. * p);
	f += .25000 * noise(2. * p);
	f += .12500 * noise(4. * p);
	f += .06250 * noise(8. * p);
	return f;
}

struct Camera	{ vec3 p, t, u; };
struct Ray		{ vec3 o, d; };

void generate_ray(Camera c, out Ray r, in vec2 fragCoord)
{
	float ratio = iResolution.x / iResolution.y;

	vec2  uv = (2.0 * fragCoord.xy / iResolution.xy - 1.)
			 * vec2(ratio, 1.0);
	
	r.o = c.p;
	r.d = normalize(vec3(uv.x, uv.y, 1.0 / tan(CAMERA_FOV * .5)));
	
	vec3 cd = c.t - c.p;

	vec3 rx,ry,rz;
	rz = normalize(cd);
	rx = normalize(cross(rz, c.u));
	ry = normalize(cross(rx, rz));
	
	mat3 tmat = mat3(rx.x, rx.y, rx.z,
			  		 ry.x, ry.y, ry.z,
					 rz.x, rz.y, rz.z);

	r.d = normalize(tmat * r.d);
}

vec3 cubemap(vec3 d, vec3 c1, vec3 c2)
{
	return fbm(d) * mix(c1, c2, d * .5 + .5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	Camera c;
	c.p = vec3(0., 0., 75.);
	c.u = vec3(0., 1., 0.);

#ifdef USE_MOUSE
	c.t = vec3(iMouse.x / iResolution.x * 180. -90., 
			   iMouse.y / iResolution.y * 180. -90., 0.);
#else
	c.t = vec3( 26. * sin(mod(iGlobalTime * .64, 2. * PI)),
			    28. * cos(mod(iGlobalTime * .43, 2. * PI)),
			   -25. * cos(mod(iGlobalTime * .20, 2. * PI)));
#endif		

	Ray r;
	generate_ray(c, r, fragCoord);
	
	fragColor = vec4(cubemap(r.d,vec3(.5,.9,.1), vec3(.1,.1,.9)), 1);
}