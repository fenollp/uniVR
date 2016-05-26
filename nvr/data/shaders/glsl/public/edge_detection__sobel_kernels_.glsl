// Shader downloaded from https://www.shadertoy.com/view/4ss3Dr
// written by shadertoy user 4rknova
//
// Name: Edge Detection (Sobel kernels)
// Description: A simple Sobel based edge detection filter.
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

// Sobel Kernel - Horizontal
// -1 -2 -1
//  0  0  0
//  1  2  1

// Sobel Kernel - Horizontal
// -1  0 -1
// -2  0 -2
// -1  0 -1

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

vec3 filter(in vec2 fragCoord)
{
	vec3 hc =sample(-1,-1, fragCoord) *  1. + sample( 0,-1, fragCoord) *  2.
		 	+sample( 1,-1, fragCoord) *  1. + sample(-1, 1, fragCoord) * -1.
		 	+sample( 0, 1, fragCoord) * -2. + sample( 1, 1, fragCoord) * -1.;		

    vec3 vc =sample(-1,-1, fragCoord) *  1. + sample(-1, 0, fragCoord) *  2.
		 	+sample(-1, 1, fragCoord) *  1. + sample( 1,-1, fragCoord) * -1.
		 	+sample( 1, 0, fragCoord) * -2. + sample( 1, 1, fragCoord) * -1.;

	return sample(0, 0, fragCoord) * pow(luminance(vc*vc + hc*hc), .6);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float u = fragCoord.x / iResolution.x;
    float m = iMouse.x / iResolution.x;
    
    float l = smoothstep(0., 1. / iResolution.y, abs(m - u));
    
    vec2 fc = fragCoord.xy;
    fc.y = iResolution.y - fragCoord.y;
    
    vec3 cf = filter(fc);
    vec3 cl = sample(0, 0, fc);
    vec3 cr = (u < m ? cl : cf) * l;
    
    fragColor = vec4(cr, 1);
}