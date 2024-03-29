// Shader downloaded from https://www.shadertoy.com/view/Ms3SW2
// written by shadertoy user finalman
//
// Name: Bokehlicious
// Description: Click and drag to adjust focal depth and aperture
const int NUM_PARTICLES = 128;
const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.0 * PI;

float bokeh(vec2 p, vec2 a, float r)
{
    float l = length(p - a);
    
    if (l > r + 0.1)
    {
        return 0.0;
    }
    
    float s = 0.01;
    float d = l * exp(sin(9.0 * atan(p.y - a.y, p.x - a.x)) * 0.02);
    float g = mix(0.9, 0.6, texture2D(iChannel0, 4.0 * p - a * 1.9).x);
    float t = smoothstep(r + s, r - s, d);
    
    return 0.001 * mix(0.0, mix(g, t, clamp(l / r, 0.0, 1.0)), t) / (r * r);
}
    
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{	
    float aperture = 0.5;
    float focus = 3.5;
    
    if (iMouse.z > 0.0)
    {
        aperture = iMouse.x / iResolution.x;
        focus = 7.0 * iMouse.y / iResolution.y;
    }

    vec2 uv = (fragCoord.xy - iResolution.xy * 0.5) / iResolution.y;
    vec3 c = vec3(0);
    
    for (int i = 0; i < NUM_PARTICLES; i++)
    {
        vec3 color;
        vec3 pos;
        float radius;

        float t = float(i) / float(NUM_PARTICLES);
        float p = t + iGlobalTime * 0.03;
        color = normalize(vec3(sin(t * TAU * 1.0) + 5.1, cos(t * TAU * 2.0) + 1.1, cos(t * TAU * 3.0) + 1.1));
        pos = vec3(2.0 * sin(t * TAU * 5.0 + p * 0.7),
                                abs(sin(p * 3.0 * TAU)) - 0.5,
                                4.0 * cos(t * TAU + p * 0.8));
        float d = pos.z + 2.5;
        
        if (d > 0.0)
        {
            pos.xy /= d;
            radius = max(abs(1.0 / d - 1.0 / focus) * aperture, 0.0001);
            c += color * bokeh(uv, pos.xy, radius);
        }
    }
    
	c = pow(c, vec3(1.0 / 2.2));
	fragColor = vec4(c, 1.0);
}