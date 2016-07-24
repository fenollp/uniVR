// Shader downloaded from https://www.shadertoy.com/view/XslSDN
// written by shadertoy user huttarl
//
// Name: Gold and silver spirals
// Description: The golden spiral and silver spiral.
// See http://en.wikipedia.org/wiki/Golden_spiral
// and http://en.wikipedia.org/wiki/Silver_ratio

const float phi = 1.618034; // golden ratio
const float invlogphi = 2.0780869; // 1.0 / log(phi)
const float ds = 2.414213562; // silver ratio = 1 + sqrt(2)
const float invlogds =  1.13459265711; // 1.0 / log(ds); used for taking log base ds
const float pi = 3.141592654;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

	float minRes = min(iResolution.x, iResolution.y);
	// vec2 offset = (iResolution.xy - vec2(minRes)) * 0.5;

	vec2 center = 0.5 * iResolution.xy;
	// 	vec2(sin(iGlobalTime * 2.7), cos(iGlobalTime * 3.6)) * minRes * 0.1;

	// point in unit-ish coordinates, with origin in the middle of the viewport
	// vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	vec2 p = 2.2 * (fragCoord.xy - center) / minRes;
	
	// TODO: factor out sqrt
	float r = sqrt(dot(p,p));
	float rotspd = 5.0; // (sin(iGlobalTime * 0.1 * (fi + 1.0)) + 0.5) * 0.01;
	float a = atan(p.y, p.x);
	float a1 = a + iGlobalTime * rotspd;
	float a2 = a - iGlobalTime * rotspd;
	// a = mod(a, pi2);
	
	// The radius is close to what power of ds?
	float lr = log(r);
	float ani = mod(lr * invlogds - a1 + pi, pi + pi) - pi;
	vec3 col = vec3(1.0 - smoothstep(0.0, 0.1, abs(ani * r)));
	// golden ratio
	ani = mod(lr * invlogphi + a2 + pi, pi + pi) - pi;
	float lum = 1.0 - smoothstep(0.0, 0.1, abs(ani * r));
	col += lum * vec3(1.0, 0.8, 0.3);
	
	fragColor = vec4(col, 1.0);
	
}