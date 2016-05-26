// Shader downloaded from https://www.shadertoy.com/view/lllGWj
// written by shadertoy user mpcomplete
//
// Name: Alien magma
// Description: Testing noise, fbm,and color rotation.
float time = iGlobalTime * 0.15;

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// hq texture noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);

	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z);
	vec2 rg1 = texture2D( iChannel0, (uv+ vec2(0.5,0.5))/256.0, -100.0 ).yx;
	vec2 rg2 = texture2D( iChannel0, (uv+ vec2(1.5,0.5))/256.0, -100.0 ).yx;
	vec2 rg3 = texture2D( iChannel0, (uv+ vec2(0.5,1.5))/256.0, -100.0 ).yx;
	vec2 rg4 = texture2D( iChannel0, (uv+ vec2(1.5,1.5))/256.0, -100.0 ).yx;
	vec2 rg = mix( mix(rg1,rg2,f.x), mix(rg3,rg4,f.x), f.y );
	
	return mix( rg.x, rg.y, f.z );
}

//x3
vec3 noise3( in vec3 x)
{
	return vec3( noise(x+vec3(123.456,.567,.37)),
				noise(x+vec3(.11,47.43,19.17)),
				noise(x) );
}

// https://code.google.com/p/fractalt}erraingeneration/wiki/Fractional_Brownian_Motion
vec3 fbm(in vec2 p)
{
    const float gain = 0.5;
    const float lacunarity = 2.;

    vec3 total = vec3(0);
	float amplitude = gain;

	for (int i = 1; i < 7; i++) {
		total += noise3(vec3(p, time)) * amplitude;
		amplitude *= gain;
		p *= lacunarity;
	}
	return total;
}

mat3 rotation(float angle, vec3 axis)
{
    vec3 a = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc * a.x * a.x + c,        oc * a.x * a.y - a.z * s,  oc * a.z * a.x + a.y * s,
                oc * a.x * a.y + a.z * s,  oc * a.y * a.y + c,        oc * a.y * a.z - a.x * s,
                oc * a.z * a.x - a.y * s,  oc * a.y * a.z + a.x * s,  oc * a.z * a.z + c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	p.x *= iResolution.x/iResolution.y;

    p.x = p.x*(1. + .2*sin(time*2.));
    p.y = p.y*(1. + .2*sin(time*2.));
    p += vec2(6.5, 6.5);

    vec3 color = fbm(3.5*p);

#if 0
    color = mod(time + color*1.5, 1.);
    color = hsv2rgb(vec3(color.x, .8, .8));
#else
    color = time*vec3(0.9, 0.7, 0.25) + color;

    float c1 = color.x*3.;
    float c2 = color.y*9.;
    vec3 col1 = 0.5 + 0.5*sin(c1 + vec3(0.0,0.5,1.0));
	vec3 col2 = 0.5 + 0.5*sin(c2 + vec3(0.5,1.0,0.0));
	color = 2.0*pow(col1*col2,vec3(0.8));

    vec3 axis = fbm(p*2.75);
    color = rotation(.9*length(axis)*sin(8.*time), axis)*color;
#endif

    fragColor.xyz = color;
}