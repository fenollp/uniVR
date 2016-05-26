// Shader downloaded from https://www.shadertoy.com/view/4stGWX
// written by shadertoy user tsone
//
// Name: Gaussian AA Test
// Description: Testing anti-aliasing with coverage estimated with Gaussian. No multisampling. Click to show the render without anti-aliasing. Based on eiffie's shader: https://www.shadertoy.com/view/ldSGRz
/*

Copyright 2016 Valtteri "tsone" Heikkilä

This work is licensed under the Creative Commons Attribution 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

*/

#define SQRT2    1.414213562373095
#define SQRT3    1.732050807568877

// Number of edges to record (=size of "edge stack"). Possible values: 1,2
#define AA_EDGES 2

// Define for static marching threshold (useful for older GPUs...)
//#define MARCH_THRESHOLD  .000001
#ifdef MARCH_THRESHOLD
#define MARCH_ITERATIONS 96
#else
#define MARCH_ITERATIONS 128
#endif

#define FISHEYE_AMOUNT   (-.3 - .3*sin(.3*iGlobalTime))
#define MAX_DEPTH 220.


float sqr(float x) { return x*x; }


mat3 rot_mat;

float pxg; // Pixel cone radius coeff for Gaussian coverage.
float pxn; // -"- for normal/gradient calculation.
float pxm; // -"- for dynamic threshold for marching.


mat3 rot_y(in float a)
{
	float ca = cos(a);
	float sa = sin(a);
	return mat3(
		ca,0.0,sa,
		0.0,1.0,0.0,
		-sa,0.0,ca
	);
}

mat3 rot_x(in float a)
{
	float ca = cos(a);
	float sa = sin(a);
	return mat3(
		1.0,0.0,0.0,
		0.0,ca,sa,
		0.0,-sa,ca
	);
}

float BoxRounded(in vec3 p, in vec3 s, float r)
{
    p = max(abs(p) - s, 0.);
	return length(p) - r;
}

float Map(in vec3 p)
{
    p = mod(p + 6., 12.) - 6.;
    p = abs(p);
	float d0 = BoxRounded(p, vec3(2.7), .1);
	float d1 = BoxRounded(p+vec3(-2.8), vec3(1.7), .1);
    return max(d0, -d1);
}

vec3 CameraRayDir(in vec2 fragCoord)
{
	vec2 uv = (2.*fragCoord - iResolution.xy) / length(iResolution.xy);
	return normalize(vec3(SQRT2 * uv, 1. + FISHEYE_AMOUNT * dot(uv, uv)));
}

void Camera(out vec3 P, out vec3 D, in vec2 fragCoord)
{
    D = CameraRayDir(fragCoord);
    
    // Calc 'px' as delta of D (=ray direction) to neighboring farthest pixel.
    vec3 D2 = CameraRayDir(fragCoord + sign(D.xy));
    float px = length(D2 - D);
    // SQRT3 scale distance to cover a sphere around px cube.
    pxn = SQRT3 * px;
    // SQRT2 is from 1/2 scaler in the exponent in Gaussian distribution.
    // See: https://en.wikipedia.org/wiki/Gaussian_filter
    pxg = SQRT2 * px;
    // Ad-hoc, scaler should be small to eliminate surface peeling artefacts.
    pxm = .0375 * px;
    
    // Position and rotate camera.
    P = rot_mat * vec3(0.0,-.5,-10.);
	D = rot_mat * D;
}

vec3 Normal(in vec3 p, float t)
{
    vec2 v = vec2(t * pxn, 0.);
	float d1 = Map(p-v.xyy), d2 = Map(p+v.xyy);
	float d3 = Map(p-v.yxy), d4 = Map(p+v.yxy);
	float d5 = Map(p-v.yyx), d6 = Map(p+v.yyx);
	return normalize(vec3(-d1+d2,-d3+d4,-d5+d6));
}

struct MarchResult
{
#if AA_EDGES == 1
    vec2 edge;
#elif AA_EDGES == 2
    vec4 edge;
#endif
    float t;
    float d;
};
    
vec3 Shade(in vec3 P, in vec3 D, float t, in vec3 L)
{
    P += t * D;
	vec3 N = Normal(P, t);
    float NdotL = max(dot(N, L), 0.);
    return vec3(NdotL);
}

vec3 SampleGauss(in vec3 srccolor, in vec3 dstcolor, float t, float d)
{
    // Divisor 3 sets the distribution cover 99% of the value inside px distance.
    // See: https://en.wikipedia.org/wiki/Gaussian_filter
    return mix(srccolor, dstcolor, exp(-sqr(d) / sqr(t*pxg / 3.)));
}

vec3 Color(in vec3 P, in vec3 D, in vec3 L, in MarchResult r, bool disable_aa)
{
    vec3 color = vec3(sqr(.5*D.y + .5));
#ifdef MARCH_THRESHOLD
    if (disable_aa && r.d < MARCH_THRESHOLD) {
#else
    if (disable_aa && r.d < pxm*r.t) {
#endif
    	color = Shade(P, D, r.t, L);
    } else {
        color = SampleGauss(color, Shade(P, D, r.t, L), r.t, r.d);
#if AA_EDGES == 1
	    color = SampleGauss(color, Shade(P, D, r.edge.y, L), r.edge.y, r.edge.x);
#elif AA_EDGES == 2
	    color = SampleGauss(color, Shade(P, D, r.edge.w, L), r.edge.w, r.edge.z);
	    color = SampleGauss(color, Shade(P, D, r.edge.y, L), r.edge.y, r.edge.x);
#endif
    }
    return color;
}

MarchResult March(in vec3 ro, in vec3 rd, float rnd)
{
    float t = Map(ro) * (1. - .25*rnd);
    float t2 = t;
    float d = t;
    float od = MAX_DEPTH;

#if AA_EDGES == 1
    vec2 edge = vec2(MAX_DEPTH);
#elif AA_EDGES == 2
    vec4 edge = vec4(MAX_DEPTH);
#endif
    
	for (int j = 0; j < MARCH_ITERATIONS; ++j) {
		d = Map(ro + t*rd);
        
#if AA_EDGES == 1
        if (od < d && od < edge.x && od < t2*pxg) {
            edge = vec2(od, t2);
        }
#elif AA_EDGES == 2
        if (od < d && od < edge.z && od < t2*pxg) {
            edge = vec4(edge.zw, od, t2);
        }
#endif
        t2 = t;
        t += d;
        od = d;
#ifdef MARCH_THRESHOLD
		if (d < MARCH_THRESHOLD || t > MAX_DEPTH) {
#else
		if (d < pxm*t || t > MAX_DEPTH) {
#endif
			break;
		}
	}

    return MarchResult(edge, t, d);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec3 P, D;
	int i;
    
    float rnd = texture2D(iChannel0, fragCoord / iChannelResolution[0].xy).r;

    float time = .1 * iGlobalTime;
    rot_mat = rot_y(time) * rot_x(.75);
    
	Camera(P, D, fragCoord);
	MarchResult r = March(P, D, rnd);
    vec3 L = rot_mat * normalize(vec3(-.15,.3,-1.));
    
    vec3 final = Color(P, D, L, r, iMouse.z > 0.);
    // Reduce banding by adding noise.
    final += rnd / 512.0;
    // Gamma encode.
    final = pow(final, vec3(1./2.2));
	fragColor = vec4(final, 1.);
}