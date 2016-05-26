// Shader downloaded from https://www.shadertoy.com/view/4dsGDn
// written by shadertoy user 4rknova
//
// Name: Chromatic Aberration Filter
// Description: A simple chromatic aberration effect.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 c0 = texture2D(iChannel0,fragCoord.xy/iResolution.xy);
	
	if (mod(floor(fragCoord.y),2.) > 0.)
	{
		float l = dot(c0.xyz, vec3(.2126, .7152, .0722));
		fragColor = l * c0;
		return;
	}
	
	float t = pow((((1. + sin(iGlobalTime * 10.) * .5)
		 *  .8 + sin(iGlobalTime * cos(fragCoord.y) * 41415.92653) * .0125)
		 * 1.5 + sin(iGlobalTime * 7.) * .5), 5.);
	
	vec4 c1 = texture2D(iChannel0, fragCoord.xy/(iResolution.xy+vec2(t * .2,.0)));
	vec4 c2 = texture2D(iChannel0, fragCoord.xy/(iResolution.xy+vec2(t * .5,.0)));
	vec4 c3 = texture2D(iChannel0, fragCoord.xy/(iResolution.xy+vec2(t * .9,.0)));
	
	fragColor = vec4(c3.r, c2.g, c1.b, 1.);
}