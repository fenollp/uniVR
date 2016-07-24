// Shader downloaded from https://www.shadertoy.com/view/MdyGRW
// written by shadertoy user Dave_Hoskins
//
// Name: Fractal Explorer DOF
// Description:  More fractal fun! This time with a single pass depth of field effect 
//    
// Hashed blur
// https://www.shadertoy.com/view/XdjSRw
// David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Can go down to 10 or so, and still be usable, probably...
#define ITERATIONS 15
#define TAU  6.28318530718

//-------------------------------------------------------------------------------------------
// Use last part of hash function to generate new random radius and angle...
vec2 Sample(inout vec2 r)
{
    r = fract(r * vec2(37.3983, 59.4427));
    return r-.5;
}

//-------------------------------------------------------------------------------------------
#define HASHSCALE 443.8975
vec2 Hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE);
    p3 += dot(p3, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

//-------------------------------------------------------------------------------------------
vec3 Blur(vec2 uv, float radius, float zed)
{
    vec2 circle = vec2(radius* .04) * vec2((iResolution.y / iResolution.x), 1.);
	vec2 random = Hash22(uv);

    // Do the blur...
	vec3 acc = vec3(0.0);
	for (int i = 0; i < ITERATIONS; i++)
    {
		vec4 v = texture2D(iChannel0, uv + circle * Sample(random));
        if (v.w >= zed-1.)
        {
            acc += v.xyz;
        }else
        {
            acc += texture2D(iChannel0, uv, -99.0).xyz;
        }
    }
	return acc / float(ITERATIONS);
}

//-------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float zed = texture2D(iChannel0, uv).w;
	float radius = abs(zed-1.)*.02;
	fragColor = vec4(Blur(uv, radius, zed), 1.0);
}