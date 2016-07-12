// Shader downloaded from https://www.shadertoy.com/view/XsVGWR
// written by shadertoy user epicabsol
//
// Name: Carbon Fiber
// Description: I can't quite seem to get the texture or specular right.

vec3 pattern(in vec2 uv)
{
    float row = floor(uv.y * 50.0);
    float value = mod(floor(uv.x * 50.0 + row * 0.5), 2.0);
    //float spec = mix(0.0, 0.8, 0.3 + pow((1.0 - abs(uv.x - 0.5)) * (1.0 - abs(uv.y - 0.7)), 4.0));
    float spec = mix(0.3, 0.5, pow(1.5 - pow(pow((uv.x - 0.5) * 0.5, 2.0) + pow(uv.y - 0.6, 2.0), 0.25), 6.0));
    float c = mix(0.2,  spec, value);
    return vec3(c, c, c);
}

vec4 shade(in vec2 uv)
{
    //return vec4(.0,.0,.0,.0);
    float s = mix(0.2, 0.0, uv.y);
    s = s + abs(uv.x - 0.5) * 0.15;
    return vec4(s, s, s, 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(pattern(uv), 1.0) - shade(uv);
}
