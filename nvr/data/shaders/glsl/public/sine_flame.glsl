// Shader downloaded from https://www.shadertoy.com/view/XstGR8
// written by shadertoy user epicabsol
//
// Name: Sine Flame
// Description: Just a quick adaptation of my previous rainbow shader to give a flame effect.
vec3 Strand(in vec2 fragCoord, in vec3 color, in float hoffset, in float hscale, in float vscale, in float timescale)
{
    float glow = 0.01 * iResolution.x;
    fragCoord.x += vscale * 100.0;
    float twopi = 6.28318530718;
    float curve = 1.0 - abs(fragCoord.x - (sin(mod(fragCoord.y * hscale / 100.0 / iResolution.y * 1000.0 + iGlobalTime * timescale + hoffset, twopi)) * iResolution.x * 0.25 * vscale + iResolution.x / 2.0));
    float i = clamp(curve, 0.0, 1.0) * 0.3;
    i += clamp((glow * 2.0 + curve) / (glow * 2.0), 0.0, 1.0) * 0.3 ;
    i += clamp((glow * 8.03 + curve) / (glow * 8.03), 0.0, 1.0) * 0.25 ;
    i += clamp((glow * 50.03 + curve) / (glow * 50.03), 0.0, 1.0) * 0.05 ;
	
	float len = sin(hoffset * timescale * 0.01 + hscale * timescale * 0.0001) * 10.0 + sqrt(pow(fragCoord.x - iResolution.x * 0.5, 2.0) + pow(fragCoord.y * 0.5, 2.0));
    float d = (len + (vscale * 3.0 - 0.5) * iResolution.y) / (0.1 * iResolution.y);
    return clamp(i, 0.0, 1.0) * (3.0 - d) * color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float timescale = -5.0;
	vec3 c = vec3(0, 0, 0);
    c += Strand(fragCoord, vec3(1.0, 0.25, 0), 0.7934 + iGlobalTime * 30.0, 1.0, 0.05, 10.0 * timescale);
    c += Strand(fragCoord, vec3(0.9, 0.21, 0), 0.645 + iGlobalTime * 30.0, 1.5, 0.2, 10.3 * timescale);
    c += Strand(fragCoord, vec3(0.85, 0.3, 0), 0.735 + iGlobalTime * 30.0, 1.3, 0.19, 8.0 * timescale);
    c += Strand(fragCoord, vec3(0.93, 0.23, 0.0), 0.9245 + iGlobalTime * 30.0, 3.0, 0.14, 12.0 * timescale);
    c += Strand(fragCoord, vec3(0.97, 0.19, 0), 0.7234 + iGlobalTime * 30.0, 1.9, 0.23, 14.0 * timescale);
    c += Strand(fragCoord, vec3(0.83, 0.24, 0), 0.84525 + iGlobalTime * 30.0, 1.2, 0.29, 9.0 * timescale);
    
    
	fragColor = vec4(c.r, c.g, c.b, 1.0);
}
