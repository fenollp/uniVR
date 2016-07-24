// Shader downloaded from https://www.shadertoy.com/view/ls3GRS
// written by shadertoy user anisoptera
//
// Name: purple pulsar
// Description: a pulsar i came up with after a bit of hacking around. actually hurts your eyes a bit
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pos = fragCoord.xy / iResolution.xy;
    float t = iGlobalTime;

    vec2 circlePoint = vec2(sin(t), cos(t));
    vec2 center = 0.5 + (circlePoint * 0.03);

    float minBright = 0.01;
    float maxBright = 0.04;
    float magnitude = (minBright + abs(sin(t) * (maxBright - minBright)));
    
    vec2 dist = abs(center - pos);
    // add pointiness
    float longDist = max(dist.x, dist.y);
    dist += longDist / 40.0;
    vec2 uv = magnitude / dist;

    float brightness = (uv.x + uv.y) / 2.0;
    
    vec3 rgb = vec3(brightness);
    
    rgb.r += 0.1+0.25*sin(t);
    rgb.b += 0.75+0.25*sin(t);

    fragColor = vec4(rgb,1.0);
}