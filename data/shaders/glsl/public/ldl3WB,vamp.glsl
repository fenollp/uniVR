// Shader downloaded from https://www.shadertoy.com/view/ldl3WB
// written by shadertoy user Dave_Hoskins
//
// Name: Vamp
// Description: Vampire fun, using a recently posted edge detector. Sorry about the crappy moon! - as an excuse, it mixes well with the 80s vibe of the whole thing. ;)

float Hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

//--------------------------------------------------------------------------
float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    float res = mix(mix( Hash(n+  0.0), Hash(n+  1.0),f.x),
                    mix( Hash(n+ 57.0), Hash(n+ 58.0),f.x),f.y);
    return res-.5;
}

float Intensity(vec2 uv)
{
	float edginess = 0.0;
	float fudge2 = 25.0;
	float fudge = 14.0;

	
	for (int i = 0; i < 30; i++)
	{
		vec4 texColorA = texture2D(iChannel0, uv);
		float texBW = distance(vec3(0.0, .0, 0.0), texColorA.xyz*iResolution.x*.002);
		float clampedder = (max(abs(fwidth(texBW)), 0.05) - 0.5) / 0.85;
		edginess += exp(clampedder * fudge) * fudge2;
		uv.y += .0035;
		uv.x += Noise(uv*50.0)*.0015;
		fudge2 *= .93;
	}
	return edginess;
}

vec3 Sky(vec2 uv)
{
	uv.x *= iResolution.x / iResolution.y;
	vec3 col = mix(vec3(.75, .62, .4), vec3(.1, .0, .0), min(uv.y*1.4, 1.0));
	float moon = pow(max(1.0-length(uv-vec2(.2, .9)), 0.0), 10.0)*43.7;
	
	if (moon > 2.5)
	{
		moon *= .25+smoothstep(2.5, 18.5, moon);	
		moon = min(moon, 1.0);
		float f = .95	+ Noise(uv*19.5+vec2(4.5, 3.3))*.75
						+ Noise(uv*39.0)*.45
						+ Noise(uv*93.0)*.25
						+ Noise(uv*203.0)*.15;
		moon = min(moon*f, 1.1);
	}else moon *= .2;
	col = mix(col, vec3(1.0, .85, .65), moon);
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float bri = clamp(Intensity(uv), 0.0, 1.0);
	vec3 vid = texture2D(iChannel0, uv).xyz;
	vec3 col =  mix(vid, vec3(Noise(uv*13.3)*.2+.3, 0.0, 0.0), bri);
	
    float maxrb = max( vid.r, vid.b);
    float k = clamp((vid.g-maxrb)*11.0,0.0,1.0);
    col = mix(col, Sky(uv), k);
	fragColor = vec4(vec3(col), 1.0);
}