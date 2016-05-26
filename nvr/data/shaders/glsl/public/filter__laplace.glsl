// Shader downloaded from https://www.shadertoy.com/view/MtXGWf
// written by shadertoy user 4rknova
//
// Name: Filter: LaPlace
// Description: A simple edge detection filter
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

// La place kernel
//  0  1  0
//  1 -4  1
//  0  1  0

float luminance(vec3 c)
{
	return dot(c, vec3(.2126, .7152, .0722));
}

vec3 sample(const int x, const int y, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy * iChannelResolution[0].xy;
	uv = (uv + vec2(x, y)) / iChannelResolution[0].xy;
	return texture2D(iChannel0, uv).xyz;
}

vec3 filter(in vec2 fragCoord)
{
    vec3 scc = sample( 0,  0, fragCoord);
    
    vec3 sum = sample(-1,  0, fragCoord)
             + sample( 0, -1, fragCoord)
             + sample( 0,  1, fragCoord)
             + sample( 1,  0, fragCoord)
             - scc * 4.;
    
	return scc * pow(luminance(sum * 6.), 1.25);
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