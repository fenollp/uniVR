// Shader downloaded from https://www.shadertoy.com/view/4ddGzf
// written by shadertoy user 4rknova
//
// Name: Truchet Tiles, Diagonal
// Description: Simple truchet diagonal pattern.
// by Nikos Papadopoulos, 4rknova / 2016
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define EPS  .01
#define ZOOM 4.
#define WGHT 9. * EPS

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7))) * 43758.5453123);
}

float df_line(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);	
	return length(pa - ba * h);
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

float df_pattern(vec2 st, vec2 uv)
{
    return sharpen(df_line(uv, vec2(0), vec2(1)), WGHT);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.) * ZOOM;
    uv.x *= iResolution.x / iResolution.y;
    
    vec2 st = floor(uv);
    uv = fract(uv);
 
    if (hash(st * floor(iGlobalTime))>.7) uv.x = 1. - uv.x;    
    vec3 col = vec3(df_pattern(st, uv));    
	fragColor = vec4(col, 1);
}