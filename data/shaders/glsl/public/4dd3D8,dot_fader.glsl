// Shader downloaded from https://www.shadertoy.com/view/4dd3D8
// written by shadertoy user masaki
//
// Name: dot fader
// Description: fade in-out dot color
#define PI 3.141592
#define ALT  0.48

void mainImage( out vec4 fragColor, vec2 p)
{
    
	vec2 uv = p / iResolution.xy;
    float t = sin(iGlobalTime);
    uv = .5 * sin(uv * PI) + .5;
    float f = ALT * (t + 1.0);
    float s = smoothstep(f, 1.0, uv.x * uv.y);
    p = step(2.,mod(p.xy, 3.));
    
    fragColor = p.x * p.y * vec4(0., .7*s, 1.*s, 1.);
}



