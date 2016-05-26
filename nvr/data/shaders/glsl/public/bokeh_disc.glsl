// Shader downloaded from https://www.shadertoy.com/view/4d2Xzw
// written by shadertoy user Dave_Hoskins
//
// Name: Bokeh disc
// Description: Uses evenly distributed samples from this idea:- http://blog.marmakoide.org/?p=1 with a few changes, like not using square roots.
//    Update: Removed trig from the loop.
//    
// Bokeh disc.
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define USE_MIPMAP

// The Golden Angle is (3.-sqrt(5.0))*PI radians, which doesn't precompiled for some reason.
// The compiler is a dunce I tells-ya!!
#define GOLDEN_ANGLE 2.39996323

#define ITERATIONS 140

mat2 rot = mat2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

//-------------------------------------------------------------------------------------------
vec3 Bokeh(sampler2D tex, vec2 uv, float radius, float amount)
{
	vec3 acc = vec3(0.0);
	vec3 div = vec3(0.0);
    vec2 pixel = 1.0 / iResolution.xy;
    float r = 1.0;
    vec2 vangle = vec2(0.0,radius); // Start angle
    amount += radius*500.0;
    
	for (int j = 0; j < ITERATIONS; j++)
    {  
        r += 1. / r;
	    vangle = rot * vangle;
        // (r-1.0) here is the equivalent to sqrt(0, 1, 2, 3...)
        #ifdef USE_MIPMAP
		vec3 col = texture2D(tex, uv + pixel * (r-1.) * vangle, radius*1.25).xyz;
        #else
        vec3 col = texture2D(tex, uv + pixel * (r-1.) * vangle).xyz;
        #endif
        col = col * col * 1.5; // ...contrast it for better highlights - leave this out elsewhere.
		vec3 bokeh = pow(col, vec3(9.0)) * amount+.4;
		acc += col * bokeh;
		div += bokeh;
	}
	return acc / div;
}

//-------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float time = iGlobalTime*.2 + .5;
	float r = .8 - .8*cos(time * 6.283);
       
	float a = 40.0;
    if (iMouse.w >= 1.0)
    {
    	r = (iMouse.x/iResolution.x)*3.0;
        a = iMouse.y/iResolution.y * 50.0;
    }
    
    uv *= vec2(1.0, -1.0);
    
    if (mod(time-.5, 3.0) < 1.0)
    {        
		fragColor = vec4(Bokeh(iChannel0, uv, r, a), 1.0);
    }else
    if (mod(time-.5, 3.0) < 2.0)
    {
        fragColor = vec4(Bokeh(iChannel1, uv, r, a), 1.0);    
    }else
    {
		fragColor = vec4(Bokeh(iChannel2, uv, r, a), 1.0);
    }
    
}