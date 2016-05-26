// Shader downloaded from https://www.shadertoy.com/view/ll2GWc
// written by shadertoy user 4rknova
//
// Name: Filter: Solarization
// Description: A simple solarization filter
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define THRESHOLD vec3(1.,.92,.1)

vec3 sample(in vec2 uv)
{
    return texture2D(iChannel0, uv).xyz;
}

vec3 filter(in vec2 uv)
{
    vec3 val = sample(uv);
    if (val.x < THRESHOLD.x) val.x = 1. - val.x;
    if (val.y < THRESHOLD.y) val.y = 1. - val.y;
    if (val.z < THRESHOLD.z) val.z = 1. - val.z;
	return val;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y = 1. - uv.y;
    
    float m = iMouse.x / iResolution.x;
    
    float l = smoothstep(0., 1. / iResolution.y, abs(m - uv.x));
    
    vec3 cf = filter(uv);
    vec3 cl = sample(uv);
    vec3 cr = (uv.x < m ? cl : cf) * l;
    
    fragColor = vec4(cr, 1);
}