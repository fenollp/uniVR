// Shader downloaded from https://www.shadertoy.com/view/4dfGWN
// written by shadertoy user tsone
//
// Name: Twister Thingy
// Description: Shadertoy remake of a classic demoscene effect.
#define OLDSKOOL
#define ADDBASE
#define ADDNOISE
#define PI 3.14159265359
#define STEPS 16.0
#define STEPSTART 0.777
#define RES 30.0
#define NOISESCALE 2.0

float time = 1.0 * iGlobalTime;


// Based on iq's 'Noise - value noise' shader:
// https://www.shadertoy.com/view/lsf3WH
float hash(in vec2 p) {
	float h = dot(p, vec2(127.1,311.7));
    return fract(sin(h) * 43758.5453123);
}

float vnoiseh2(in vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash(i + vec2(0.0,0.0));
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));
	return mix(mix(a, b, u.x),
			   mix(c, d, u.x), u.y);
}

// Normal calculation separated from height to reduce loop complexity.
// If both height and normal are needed in same place, then it would make
// sense to combine the calculations.
// Noise derivates/normal based on iq's article:
// http://www.iquilezles.org/www/articles/morenoise/morenoise.htm
// NOTE: Result is unnormalized.
vec3 vnoisen2(in vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 dl = 6.0 * f * (1.0 - f);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash(i + vec2(0.0,0.0));
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));
	return vec3(
		dl.x * mix((b - a), (d - c), u.y),
		dl.y * mix((c - a), (d - b), u.x),
		-1.0
	);
}

float baseh(in vec2 a) {
	vec2 s = sin(a);
	vec2 s2 = s * s;
	return (s2.y * s2.x);
}

// Height map normal calculation explained:
// http://http.developer.nvidia.com/GPUGems/gpugems_ch01.html
vec3 basen(in vec2 a) {
	vec2 s = sin(a);
	vec2 c = cos(a);
	vec2 s2 = s * s;
	return normalize(vec3(
		2.0 * c.x * s.x * s2.y,
		2.0 * c.y * s.y * s2.x,
		-1.0
	));
}

float height(in vec2 a) {
	float h = 0.74;
#ifdef ADDBASE
	h += 0.2 * baseh(a);
#endif
#ifdef ADDNOISE
	h += 0.06 * vnoiseh2(NOISESCALE * a);
#endif
	return h;
}

vec3 normal(in vec2 a) {
	vec3 n = vec3(0.0);
#ifdef ADDBASE
	n += basen(a);
#endif
#ifdef ADDNOISE
	n += 0.25 * vnoisen2(NOISESCALE * a);
#endif
	return normalize(n);
}

void run(out float _a, inout vec2 _p, in vec2 uv) {
	uv *= 1.333;
	
	_a = -PI;

	float dz = -STEPSTART / STEPS;
	vec3 v = vec3(uv.x, uv.y * RES * 0.25 * PI, STEPSTART);
#ifdef OLDSKOOL
	v.y = floor(v.y + 0.5);
#endif
	
	vec2 offs = vec2(RES * (0.5 * PI
			* (0.8 + 0.2 * cos(time)) * sin(2.0 * time + 0.5 * v.y / RES)),
			v.y
	);
#ifdef OLDSKOOL
	offs = floor(offs + 0.5);
#endif
	
	for (int i = 0; i < int(STEPS); i++) {
		v.z += dz;
		float a = atan(v.x, v.z) * RES;
#ifdef OLDSKOOL
		a = floor(a + 0.5);
#endif
		vec2 p = offs + vec2(a, 0.0);
		p *= 4.0 / RES;
		float r = length(v.xz);
		float h = height(p);
		if (r < h) {
			_a = a / RES;
			_p = p;
			v.x = 1e10;
		}
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - 1.0;
	float a;
	vec2 p;
	run(a, p, uv);
	vec3 n = normal(p);
	vec3 c;
	a = -a;
	float tx = n.x;
	n.x = n.x * cos(a) - n.z * sin(a);
	n.z = n.z * cos(a) + tx * sin(a);
	vec3 l = -normalize(vec3(cos(time),sin(time),1.0));
	float ndotl = max(0.0, dot(n, l));
	c = vec3(0.50,0.35,0.20)
		+ vec3(0.60,0.70,0.80) * ndotl*ndotl;
	c *= c * step(a, 0.5 * PI);
	fragColor = vec4(c,1.0);
}