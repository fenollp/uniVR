// Shader downloaded from https://www.shadertoy.com/view/lsf3D7
// written by shadertoy user 4rknova
//
// Name: AudioSurf II
// Description: Yet another audio visualization.
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define	PI         3.14159265359
#define THICKNESS  .4

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float u = fragCoord.x / iResolution.x;
	float fft = texture2D(iChannel0, vec2(u,.25)).x;  
	float wav = texture2D(iChannel0, vec2(u,.75)).x;
	
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
	vec2 wv = uv + vec2(0., wav - .5);

	float f = pow(abs(fft * tan(iGlobalTime - uv.y / wv.y)), .1);
	float h = pow(abs(wv.x - pow(abs(uv.y), cos(fft * PI * .25))), f);
	float g = abs(THICKNESS * .02 / (sin(wv.y) * h));

	vec3 c = g * clamp(vec3(fft, fract(fft) / fract(wav), g * wav), 0., 1.);
	
	fragColor = vec4(c, 1);
}