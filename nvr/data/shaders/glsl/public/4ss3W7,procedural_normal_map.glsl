// Shader downloaded from https://www.shadertoy.com/view/4ss3W7
// written by shadertoy user 4rknova
//
// Name: Procedural Normal Map
// Description: Procedural generation of normal maps from diffuse maps.
//    Use the mouse to move the light position on the xy plane.
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define ENABLE_LIGHTING
#define ENABLE_SPECULAR

#define OFFSET_X 1
#define OFFSET_Y 1
#define DEPTH	 7.5

vec3 sample(const int x, const int y, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy * iChannelResolution[0].xy;
	uv = (uv + vec2(x, y)) / iChannelResolution[0].xy;
	return texture2D(iChannel0, uv).xyz;
}

float luminance(vec3 c)
{
	return dot(c, vec3(.2126, .7152, .0722));
}

vec3 normal(in vec2 fragCoord)
{
	float R = abs(luminance(sample( OFFSET_X,0, fragCoord)));
	float L = abs(luminance(sample(-OFFSET_X,0, fragCoord)));
	float D = abs(luminance(sample(0, OFFSET_Y, fragCoord)));
	float U = abs(luminance(sample(0,-OFFSET_Y, fragCoord)));
				 
	float X = (L-R) * .5;
	float Y = (U-D) * .5;

	return normalize(vec3(X, Y, 1. / DEPTH));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec3 n = normal(fragCoord);

#ifdef ENABLE_LIGHTING
	vec3 lp = vec3(iMouse.xy / iResolution.xy * iChannelResolution[0].xy, 200.);
	vec3 sp = vec3(fragCoord.xy / iResolution.xy * iChannelResolution[0].xy, 0.);
	
	vec3 c = sample(0, 0, fragCoord) * dot(n, normalize(lp - sp));

#ifdef ENABLE_SPECULAR
    float e = 64.;
    vec3 ep = vec3(iChannelResolution[0].x * .5, (iChannelResolution[0].y) * .5, 500.);
	c += pow(clamp(dot(normalize(reflect(lp - sp, n)), 
					   normalize(sp - ep)), 0., 1.), e);
#endif /* ENABLE_SPECULAR */
	
#else
	vec3 c = n;
	
#endif /* ENABLE_LIGHTING */
	
	fragColor = vec4(c, 1);
}