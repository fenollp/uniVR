// Shader downloaded from https://www.shadertoy.com/view/4sXSD8
// written by shadertoy user 4rknova
//
// Name: Dancing Particles
// Description: Pretty random
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS .001


#define TM iGlobalTime * 1.75
#define FT 2.5 * EPS * hash(TM)
#define SM 45
#define CI vec3(1) 
#define CO vec3(r, 0, 0)

float hash(in float n) { return fract(sin(n)*43758.5453123); }

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p)
{
    vec2 i = floor(p), f = fract(p); 
	f *= f*f*(3.-2.*f);
    return mix(mix(hash(i + vec2(0.,0.)), 
                   hash(i + vec2(1.,0.)), f.x),
               mix(hash(i + vec2(0.,1.)), 
                   hash(i + vec2(1.,1.)), f.x), f.y);
}

float fbm(in vec2 p)
{
	return	.5000 * noise(p)
		   +.2500 * noise(p * 2.)
		   +.1250 * noise(p * 4.)
		   +.0625 * noise(p * 8.);
}

float metaball(vec2 p, float r)
{
	return vec2(noise(vec2(FT,1)/r)).x / dot(p, p);
}

vec3 blob(vec2 p, float t)
{
	float t0 = sin(t * 1.9) * .46;
	float t1 = sin(t * 2.4) * .39;
	float t2 = cos(t * 1.4) * .57;

	float r = metaball(p - vec2(t1 * .9, t2 * .3), noise(vec2(TM) *.1))
			+ metaball(p + vec2(t2 * .5, t0 * .4), noise(vec2(TM) *.2))
			+ metaball(p - vec2(t0 * .3, t1 * .5), noise(vec2(TM) *.4));
	
	r = max(r, .2);
	
	r *= FT;

	return (r > .5)
		? (vec3(step(.1, r*r*r)) * CI)
		: (r < 1000.9 ? CO : CI);
}

vec3 sample(vec2 uv, in vec2 fragCoord)
{
	if (abs(EPS + uv.y) >= .4 || mod(floor(fragCoord.y),2.) > 0.) { 
		return vec3(0);
	}
		
	vec3  c = vec3(0);
	
	for (int i = 0; i < SM; ++i) {
		float dt = TM - 4. * fbm(vec2(uv * 10.)) / float(i);
		c += blob(uv - noise(vec2(uv) * 0.1), dt) / float(SM);
	}
	
	vec3 fx = vec3(smoothstep(0., 3.5, iGlobalTime) * c) + vec3(.01);

	// PostFX
	float snow = hash((hash(uv.x) + uv.y) * iGlobalTime) * .025;
	float fade = smoothstep(EPS, 2.5, iGlobalTime);
	
	return fade * (snow + fx);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
			* vec2(iResolution.x / iResolution.y, 1);
	fragColor = vec4(sample(uv, fragCoord), 1);
}