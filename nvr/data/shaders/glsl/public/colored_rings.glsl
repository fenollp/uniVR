// Shader downloaded from https://www.shadertoy.com/view/ldK3WG
// written by shadertoy user Cubeleo
//
// Name: Colored Rings
// Description: Just some clean colored rings to warm up my brain for the day.
//iq's smooth HSV to RGB
vec3 hsv2rgb_smooth( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing	

	return c.z * mix( vec3(1.0), rgb, c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= vec2(.5);
    uv.x *= (iResolution.x / iResolution.y);
    
    float d = distance(uv, vec2(0));
    
    // scale the figure
    d *= 30.;
    
    float hue = floor(d) / 20. + iGlobalTime * .1;
    
    float value = .9;
    
    // create space between the rings
    value *= smoothstep(0., .2, fract(d));
    value *= smoothstep(.9, .7, fract(d));
    
    // limit the number of rings
    value *= float(d > 2.) * float(d < 13.);
    
    vec3 color = hsv2rgb_smooth(vec3(hue, .75, value));
    
	fragColor = vec4(color, 1.0);
}
