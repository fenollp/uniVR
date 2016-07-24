// Shader downloaded from https://www.shadertoy.com/view/ldtGWr
// written by shadertoy user 4rknova
//
// Name: Pseudo 3D Tunnel III
// Description: The classic tunnel effect with bump mapping.
// by nikos papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define SAMPLES 64
#define OFFSET_X .005
#define OFFSET_Y .005
#define DEPTH	  15.

vec3 sample(float x, float y, in vec2 uv)
{
	return texture2D(iChannel1, uv + vec2(x,y)).xyz;
}

float luminance(vec3 c)
{
	return dot(c, vec3(.2126, .7152, .0722));
}

vec3 normal(in vec2 uv)
{
	float R = abs(luminance(sample( OFFSET_X,0., uv)));
	float L = abs(luminance(sample(-OFFSET_X,0., uv)));
	float D = abs(luminance(sample(0., OFFSET_Y, uv)));
	float U = abs(luminance(sample(0.,-OFFSET_Y, uv)));
				 
	float X = (L-R) * .5;
	float Y = (U-D) * .5;

	return normalize(vec3(X, Y, 1. / DEPTH));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2  o = fragCoord.xy / iResolution.xy;
    float a = iResolution.x / iResolution.y; 
	vec2  p = (2. * o - 1.)
		    * vec2(a,1.);
    vec2  v = p * p * vec2(1.,2.);
    vec2  t = vec2(atan(p.x, p.y) / 3.1416, 1. / length(p));
	
	vec2  z = vec2(4, .6);
	vec3  r = vec3(0);    
    vec2  s = iGlobalTime * vec2(.1, 1);
    
    for (int i = 0; i < SAMPLES; ++i)
    {
    	r += texture2D(iChannel0, t * z + s + float(i)*.01).xyz / (t.y + .5) / float(SAMPLES); 
    }

    vec3 lp = vec3((.5-o) * iChannelResolution[0].xy, 200.);
	
    vec3 n = normal(t * z + s);
    fragColor = vec4(r * dot(n, normalize(lp)), 1);
}