// Shader downloaded from https://www.shadertoy.com/view/4ddGzX
// written by shadertoy user 4rknova
//
// Name: Truchet Tiles, Smith
// Description: Simple truchet Smith pattern.
// by Nikos Papadopoulos, 4rknova / 2016
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define ZOOM 3.
#define WGHT .04

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7))) * 43758.5453123);
}

float df_circ(in vec2 p, in vec2 c, in float r)
{
    return abs(r - length(p - c));
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

float df_pattern(vec2 st, vec2 uv)
{
    float l1 = sharpen(df_circ(uv, vec2(0), .5), WGHT);
    float l2 = sharpen(df_circ(uv, vec2(1), .5), WGHT);
    return max(l1,l2);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.) * ZOOM;
    uv.x *= iResolution.x / iResolution.y;
    
    vec2 st = floor(uv);
    uv = fract(uv);
 
    if (hash(st * floor(iGlobalTime)) >.7) uv.x = 1. - uv.x;
    vec3 col = vec3(df_pattern(st, uv));
	fragColor = vec4(col, 1);
}