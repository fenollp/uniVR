// Shader downloaded from https://www.shadertoy.com/view/4dcSRX
// written by shadertoy user Zavie
//
// Name: Valve's screen space dither
// Description: Experimenting with the dithering mentioned in Alex Vlachos's GDC2015 talk. Without dithering on the left; with dithering on the right.
//    
//    For comparison with other dithering functions, see: https://www.shadertoy.com/view/MslGR8
//    
/*

This shader tests how the Valve fullscreen dithering
shader affects color and banding.

The function is adapted from slide 49 of Alex Vlachos's
GDC2015 talk: "Advanced VR Rendering".
http://alex.vlachos.com/graphics/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf

--
Zavie

*/


float gamma = 2.2;
float colorDepth = mix(2.0, 255.0, pow(clamp(mix(-0.2, 1.2, abs(2.0 * fract(iGlobalTime / 11.0) - 1.0)), 0., 1.), 2.0));

// ---8<----------------------------------------------------------------------

vec3 ScreenSpaceDither(vec2 vScreenPos)
{
    // lestyn's RGB dither (7 asm instructions) from Portal 2 X360, slightly modified for VR
    vec3 vDither = vec3(dot(vec2(131.0, 312.0), vScreenPos.xy + iGlobalTime));
    vDither.rgb = fract(vDither.rgb / vec3(103.0, 71.0, 97.0)) - vec3(0.5, 0.5, 0.5);
    return (vDither.rgb / colorDepth) * 0.375;
}

// ---8<----------------------------------------------------------------------

// The functions that follow are only used to generate
// the color gradients for demonstrating dithering effect.

float h00(float x) { return 2.*x*x*x - 3.*x*x + 1.; }
float h10(float x) { return x*x*x - 2.*x*x + x; }
float h01(float x) { return 3.*x*x - 2.*x*x*x; }
float h11(float x) { return x*x*x - x*x; }
float Hermite(float p0, float p1, float m0, float m1, float x)
{
	return p0*h00(x) + m0*h10(x) + p1*h01(x) + m1*h11(x);
}

// Source:
// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 generateColor(vec2 uv)
{
	float a = sin(iGlobalTime * 0.5)*0.5 + 0.5;
	float b = sin(iGlobalTime * 0.75)*0.5 + 0.5;
	float c = sin(iGlobalTime * 1.0)*0.5 + 0.5;
	float d = sin(iGlobalTime * 1.25)*0.5 + 0.5;
	
	float y0 = mix(a, b, uv.x);
	float y1 = mix(c, d, uv.x);
	float x0 = mix(a, c, uv.y);
	float x1 = mix(b, d, uv.y);
    
    float h = fract(mix(0., 0.1, Hermite(0., 1., 4.*x0, 4.*x1, uv.x)) + iGlobalTime * 0.05);
    float s = Hermite(0., 1., 5.*y0, 5.*y1, 1. - uv.y);
    float v = Hermite(0., 1., 5.*y0, 5.*y1, uv.y);

	return hsv2rgb(vec3(h, s, v));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 color = pow(generateColor(uv), vec3(1. / gamma));
    vec3 ditheredColor = color + ScreenSpaceDither(fragCoord.xy);

    float separator = 1. - smoothstep(0.497, 0.499, uv.x) * smoothstep(0.503, 0.501, uv.x);
    vec3 finalColor = mix(color, ditheredColor, smoothstep(0.499, 0.501, uv.x)) * separator;
    
	fragColor = vec4(floor(finalColor * colorDepth) / colorDepth, 1.0);
}
