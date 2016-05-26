// Shader downloaded from https://www.shadertoy.com/view/ls3XRl
// written by shadertoy user finalman
//
// Name: 2D Smoke
// Description: Nothing special, just playing around with ways to generate good looking smoke.
const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.0 * PI;

mat2 rotate2D(float a)
{
    float c = cos(a);
    float s = sin(a);
    return mat2(
        c, -s,
        s, c
    );
}

float smokeBase(vec2 pos)
{
    float v = clamp(pos.x * 1.5, -1.0, 1.0);
    return 1.0 - exp(-cos(v * PI * 0.5) * smoothstep(0.0, -1.0, pos.y) * 3.0);
}

vec2 swirl(vec2 center, float angle, float radius, vec2 pos)
{
    pos -= center;
    angle *= exp(-length(pos) / radius);
    pos *= rotate2D(angle);
    pos += center;
    return pos;
}

vec2 movingSwirl(vec2 start, vec2 end, float angle, float radius, float frequency, vec2 pos)
{
    float phase = fract((iGlobalTime + 10.0) * frequency);
    angle *= (1.0 - cos(phase * TAU)) * 0.5;
    vec2 center = mix(start, end, phase);
    return swirl(center, angle, radius, pos);
}

vec2 swirls(vec2 pos)
{
    pos = movingSwirl(vec2( 0.0, -1.5), vec2( 0.3, 2.0),  5.0, 0.5, 0.10, pos);
    pos = movingSwirl(vec2( 0.0, -1.5), vec2(-0.3, 2.0), -4.0, 0.5, 0.11, pos);
    pos = movingSwirl(vec2( 0.2, -1.1), vec2( 0.5, 1.8),  4.5, 0.4, 0.12, pos);
    pos = movingSwirl(vec2(-0.2, -1.3), vec2(-0.4, 1.2), -3.8, 0.4, 0.13, pos);
    pos = movingSwirl(vec2( 0.1, -1.5), vec2(-0.3, 1.5),  4.7, 0.3, 0.14, pos);
    pos = movingSwirl(vec2(-0.1, -1.4), vec2( 0.4, 1.6), -3.8, 0.3, 0.15, pos);
    pos = movingSwirl(vec2( 0.0, -1.5), vec2( 0.3, 2.0),  5.0, 0.5, 0.16, pos);
    pos = movingSwirl(vec2( 0.0, -1.5), vec2(-0.3, 2.0), -4.0, 0.5, 0.17, pos);
    pos = movingSwirl(vec2( 0.2, -1.1), vec2( 0.5, 1.8),  4.5, 0.4, 0.18, pos);
    pos = movingSwirl(vec2(-0.2, -1.3), vec2(-0.4, 1.2), -3.8, 0.4, 0.19, pos);
    pos = movingSwirl(vec2( 0.1, -1.5), vec2(-0.3, 1.5),  4.7, 0.3, 0.20, pos);
    pos = movingSwirl(vec2(-0.1, -1.4), vec2( 0.4, 1.6), -3.8, 0.3, 0.21, pos);
    
    return pos;
}

float smoke(vec2 pos)
{
    pos = swirls(pos);
    return smokeBase(pos);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * (fragCoord.xy - iResolution.xy * 0.5) / iResolution.y;
    
    float gamma = 2.2;
    
    vec3 bg = pow(texture2D(iChannel0, uv * vec2(0.5, 0.7)).xyz, vec3(gamma)) * vec3(0.5, 0.5, 0.6);
    float smokeWhite = smoke(uv);
    float smokeShadow = smoke(uv + vec2(-0.15, 0.1));
    
    vec3 color = mix(bg * mix(1.0, 0.3, smokeShadow), vec3(1.0), smokeWhite);
    
    fragColor = vec4(pow(color, vec3(1.0 / gamma)), 1.0);
}