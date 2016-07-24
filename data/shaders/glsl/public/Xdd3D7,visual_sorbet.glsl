// Shader downloaded from https://www.shadertoy.com/view/Xdd3D7
// written by shadertoy user ap
//
// Name: Visual sorbet
// Description: Simple program to bleach your eyes after watching something for a long time.


float rand(float n)
{
    return fract(sin(n) * 43758.5453123);
}

vec2 rand2(in vec2 p)
{
    return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

#define v4White vec4(1.0, 1.0, 1.0, 1.0)
#define v4Black vec4(0.0, 0.0, 0.0, 1.0)
#define v4Grey  vec4(0.5, 0.5, 0.5, 1.0)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.y;

    float freq = 10.0;
    float gap = 1.0/freq;
    float ballrad = 0.3 * gap;
    float jitterrad = 0.2 * gap;

    vec2 param_pos = fract(uv + vec2(iGlobalTime / 10.0, 0.0));

    param_pos = uv;

    vec2 closest_center = floor(param_pos * freq + vec2(0.5)) / freq;

    float black_or_white = 0.5 + 0.5 * sin(
        2.0 * 3.14159 * 
        (rand((closest_center.x + 347.0) * (closest_center.y +129.0)) + iGlobalTime * 1.0));

    closest_center = closest_center + jitterrad * 1.0 *
        sin((iGlobalTime * 0.8 + rand2(closest_center)) * 6.28 +
        sin((iGlobalTime * 0.2 + rand2(closest_center.yx)) * 6.28) +
        sin((iGlobalTime * 0.5 + rand2(closest_center.xx * 93.0 + 127.0)) * 6.28)
           );

    float dist = length(param_pos - closest_center);  

    float s = (dist * dist) / (ballrad * ballrad);

    fragColor = mix(
        mix(
            mix(v4White, v4Black, 0.0), 
            mix(v4Black, v4White, 0.0), black_or_white), 
        mix(v4White, v4Black, 0.5), 
        smoothstep(ballrad*0.95, ballrad*1.05, dist));

}