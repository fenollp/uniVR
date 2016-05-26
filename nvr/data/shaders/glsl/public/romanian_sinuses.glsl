// Shader downloaded from https://www.shadertoy.com/view/Xt2XD3
// written by shadertoy user Freelancer2000
//
// Name: Romanian Sinuses
// Description: Based on Epicbasol's Rainbow Laser Beam, which I'd like to thank in advance ^_^
vec3 Cord(in vec2 fragCoord, in vec3 colour, in float hoffset, in float hscale, in float vscale, in float timescale)
{
    float glow = 0.1 * iResolution.y;
    float twopi = 6.28318530718;
    float curve = 1.0 - abs(fragCoord.y - (sin(mod(fragCoord.x * hscale / 100.0 / iResolution.x * 1000.0 + iGlobalTime * timescale + hoffset, twopi)) * iResolution.y * 0.25 * vscale + iResolution.y / 2.0));
    float i = clamp(curve, 0.0, 1.0);
    i += clamp((glow + curve) / glow, 0.0, 1.0) * 0.4 ;
    return i * colour;
}


vec3 InverseMuzzle(in vec2 fragCoord, in float timescale)
{
    float theta = atan(iResolution.y / 10.0 - fragCoord.y, iResolution.x - fragCoord.x + 1.13 * iResolution.x);
	return vec3(theta);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float timescale = 4.0;
	vec3 c = vec3(0, 0, 0);
    c += Cord(fragCoord, vec3(1.0, 1.0, 0), 0.7934 + 1.0 * 10.0, 10.0, 0.80, -10.0);
    c += Cord(fragCoord, vec3(1.0, 0.0, 0.0), 0.645 + 1.0 + sin(iGlobalTime) * 1.0, 10.5, 0.40, -10.3);
    c += Cord(fragCoord, vec3(0.0, 0.0, 1.0), 0.735 + 1.0 * 30.0, 10.3, 0.20, -8.0 * timescale);

    c += clamp(InverseMuzzle(fragCoord, timescale), 0.0, 0.1);
	fragColor = vec4(c.r, c.g, c.b, 1.0);
}
