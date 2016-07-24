// Shader downloaded from https://www.shadertoy.com/view/XsG3WG
// written by shadertoy user piotrekli
//
// Name: Gray-Scott (faster version)
// Description: Version of XdG3WG using 4 buffers like in Knighty's reaction-diffusion shader (MdVGRh).
float sampleLightY(sampler2D channel, vec2 fragCoord)
{
    float light;
#   define S(DX, DY, WEIGHT) light += texture2D(channel, (fragCoord+vec2(DX, DY))/iResolution.xy).y*WEIGHT;
    S( 0,  1, -0.2)
    S( 0, -1,  0.2)
    S( 1,  0,  0.2)
    S(-1,  0, -0.2)
#   undef S
    return light;
}

vec3 hsv2rgb(vec3 hsv)
{
    vec3 rgb;
    float h = mod(hsv.x * 6.0, 6.0);
    float q = h-float(int(h));
    if      (h < 1.0) rgb = vec3( 1.0,    q,  0.0);
    else if (h < 2.0) rgb = vec3(1.-q,  1.0,  0.0);
    else if (h < 3.0) rgb = vec3( 0.0,  1.0,    q);
    else if (h < 4.0) rgb = vec3( 0.0, 1.-q,  1.0);
    else if (h < 5.0) rgb = vec3(   q,  0.0,  1.0);
    else if (h < 6.0) rgb = vec3( 1.0,  0.0, 1.-q);
    rgb = hsv.z*(1.0-hsv.y*(1.0-rgb));
    return rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float uValue = texture2D(iChannel0, uv).x;
    float light = sampleLightY(iChannel0, fragCoord)*8.0;
	fragColor = vec4(hsv2rgb(vec3(1.0-uValue*0.8-0.16,
                                  light > 0.0 ? 1.-light : 1.,
                                  light > 0.0 ? 1. : 1.+light)), 1.0);
}