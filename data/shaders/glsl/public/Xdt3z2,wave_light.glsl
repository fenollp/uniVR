// Shader downloaded from https://www.shadertoy.com/view/Xdt3z2
// written by shadertoy user masaki
//
// Name: wave light
// Description: wave light
#define t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.y -= 0.5;
    float wave1 = 1.0 - pow(abs(sin(uv.x * 1.0 +t) *0.3 + uv.y),0.12);
    float wave2 = 1.0 - pow(abs(sin(uv.x * 5.0 +t) *0.15 + uv.y),0.12);
    float wave3 = 1.0 - pow(abs(sin(uv.x * 2.0 +t*1.8) *0.1 + uv.y),0.12);
    float wave4 = 1.0 - pow(abs(sin(uv.x * 13.0 +t*5.1) *0.22 + uv.y),0.12);
    vec3 color = vec3(wave1,wave1*0.9,wave1*0.8)
       + vec3(wave2*0.8,wave2,wave2*0.9)
       + vec3(wave3*0.8,wave3*0.9,wave3)
       + vec3(wave4,wave4*.8,wave4*0.85);
    fragColor = vec4(vec3(color),1.0);
}