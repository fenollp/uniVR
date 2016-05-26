// Shader downloaded from https://www.shadertoy.com/view/Ml2GWc
// written by shadertoy user 4rknova
//
// Name: Filter: Gamma Correction
// Description: A simple gamma correction filter
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define GAMMA 2.2

vec3 gamma(vec3 col, float g)
{
    float i = 1. / g;
    return vec3(pow(col.x, i)
              , pow(col.y, i)
              , pow(col.z, i));
}

vec3 sample(in vec2 uv)
{
    return texture2D(iChannel0, uv).xyz;
}

vec3 filter(in vec2 uv)
{
    vec3 val = sample(uv);    
	return gamma(val, GAMMA);
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