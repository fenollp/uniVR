// Shader downloaded from https://www.shadertoy.com/view/XdfSD8
// written by shadertoy user 4rknova
//
// Name: Nucleus Rave
// Description: It is what it is.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS .001


#define TM iGlobalTime * 3.5
#define FT 2.5 * EPS * hash(TM)
#define SM 50
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
    
    vec2 c = vec2(0,1);
    
    return mix(mix(hash(i + c.xx), 
                   hash(i + c.yx), f.x),
               mix(hash(i + c.xy), 
                   hash(i + c.yy), f.x), f.y);
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
	float t0 = sin(t * 0.9) * .46;
	float t1 = sin(t * 2.4) * .39;
	float t2 = cos(t * 1.4) * .57;

	float r = metaball(p - vec2(t1 * .98, t2 * .36), noise(vec2(TM) *.8))
			+ metaball(p + vec2(t2 * .55, t0 * .27), noise(vec2(TM) *.7))
			+ metaball(p - vec2(t0 * .33, t1 * .52), noise(vec2(TM) *.9))
			+ metaball(p + vec2(t2 * .22, t1 * .23), noise(vec2(TM) *.6))
			+ metaball(p - vec2(t1 * .85, t1 * .55), noise(vec2(TM) *.2));
	
	r = max(r, .2);
	
	r *= FT;

	return (r > .5)
		? (vec3(step(.1, r*r*r)) * CI)
		: (r < 1000.9 ? CO : CI);
}

vec3 bg(vec2 p, vec3 c)
{
	return vec3(0.01);
}

vec3 sample(vec2 uv, in vec2 fragCoord)
{
	if (abs(EPS + uv.y) >= .4 || mod(floor(fragCoord.y),2.) > 0.) { 
		return vec3(0);
	}
		
	vec3  c = vec3(0);
	
	for (int i = 0; i < SM; ++i) {
		float dt = TM + 30. * fbm(vec2(uv + 90.)) / float(i);
		c += blob(uv - noise(vec2(uv) * 0.4), dt) / float(SM);
	}
	
	vec3 fx = vec3(smoothstep(0., .3, iGlobalTime) * c);
	
	fx += bg(uv, fx);

	// PostFX
	float snow = hash((hash(uv.x) + uv.y) * iGlobalTime) * 0.025;
	float fade = smoothstep(EPS, 2.5, iGlobalTime);
	
	return fade * (snow + fx);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
			* vec2(iResolution.x / iResolution.y, 1);

	fragColor = vec4(sample(uv, fragCoord), 1);
}