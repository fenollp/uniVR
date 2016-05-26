// Shader downloaded from https://www.shadertoy.com/view/XstXD2
// written by shadertoy user finalman
//
// Name: Darksine
// Description: Experimented with iq's method for estimating the distance to an isoline when suddenly unintentional glitch art happened.
float iso(vec2 v)
{
    v.y += 0.001;
    v.x += sin(v.y * 20.0 + iGlobalTime * 0.1) * 0.2;
    return length(v) - 0.4;
}

vec2 grad(vec2 v)
{
    float E = 0.00000002 * exp(1.25 * sin(iGlobalTime * 5.0));
    float c = iso(v);
    float x = iso(v + vec2(E, 0)) - iso(v - vec2(E, 0));
    float y = iso(v + vec2(0, E)) - iso(v - vec2(0, E));
    return vec2(x, y) / E;
}

float dist(vec2 v)
{
    float i = iso(v);
    vec2 g = grad(v);
    return abs(i) / length(g);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy * 0.5) / iResolution.y;
    float d = dist(uv);
    vec3 color = mix(vec3(0, 0, 0), vec3(1, 0, 0), smoothstep(0.02, 0.022, d));
	fragColor = vec4(color, 1.0);
}