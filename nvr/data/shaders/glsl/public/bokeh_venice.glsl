// Shader downloaded from https://www.shadertoy.com/view/ldG3W3
// written by shadertoy user Dave_Hoskins
//
// Name: Bokeh Venice
// Description: The exact same Venice shader from Reinder, with my Bokeh Disc shader added on the next buffer. Just as an experiment. It's not correct, but it still looks kinda groovy... &amp;lt;img src=&amp;quot;/img/emoticonHappy.png&amp;quot;/&amp;gt;
// Bokeh disc.
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Buf A - Venice. Created by Reinder Nijhoff 2013


// The Golden Angle is (3.-sqrt(5.0))*PI radians.
#define GOLDEN_ANGLE 2.39996323

#define ITERATIONS 100

mat2 rot = mat2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

//-------------------------------------------------------------------------------------------
vec3 Bokeh(sampler2D tex, vec2 uv, float radius, float zed)
{
    radius*= .008;
	vec3 acc = vec3(0.0), div = acc;
    vec2 pixel = vec2(.002 *iResolution.y / iResolution.x, .002);
    float r = 1.0;
    vec2 vangle = vec2(0.0,radius); // Start angle
	for (int j = 0; j < ITERATIONS; j++)
    {  
        r += 1. / r;
	    vangle = rot * vangle;
        vec4 col = texture2D(tex, uv + pixel * (r-1.) * vangle);
        float dim = smoothstep(150.0, -10., zed-col.w);
		vec3 bokeh = (pow(col.xyz, vec3(9.0)) * 20.+.4) * dim;//..Varies depending on intensity needed..
		acc += col.xyz * bokeh;
		div += bokeh;
	}
	return acc / div;
}

//-------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    float zed = texture2D(iChannel0, uv).w;
    zed = min(zed, 150.0);
  
	fragColor = vec4(Bokeh(iChannel0, uv, zed, zed), 1.0);
  
    
}