// Shader downloaded from https://www.shadertoy.com/view/lt2GWc
// written by shadertoy user 4rknova
//
// Name: Filter: Inversion
// Description: A simple inversion filter
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

vec3 sample(in vec2 uv)
{
    return texture2D(iChannel0, uv).xyz;
}

vec3 filter(in vec2 uv)
{
	return 1. - sample(uv);
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