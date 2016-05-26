// Shader downloaded from https://www.shadertoy.com/view/lddGWM
// written by shadertoy user ap
//
// Name: Holiday lights
// Description: Made something while I was bored. Reminds me of Indian Diwali lights.


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


vec3 moonImage(vec2 loc)
{
    float moonRad = 0.3;
    vec2 moonDiffVec = loc - vec2(0.0, 0.0);
    float dist = length(moonDiffVec);
    
    return mix(
    	vec3(0.6, 0.6, 0.5),
        vec3(0.0),
        smoothstep(moonRad * 0.9, moonRad * 1.1, dist / moonRad));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.y;

    vec2 freq = vec2(5.0, 15.0);
    vec2 gap = vec2(1.0/freq.x, 1.0/freq.y);
    vec2 jitterrad = vec2((0.02 + 0.02 * (1.-uv.y)) * gap.x , 0.01 * gap.y);
    float ballrad = 0.2 * gap.y;

    vec2 param_pos = uv - vec2(0.5);
  
    vec2 closest_center = floor(param_pos * freq + vec2(0.5)) / freq;
    
    vec3 color = vec3(
        rand(closest_center.x * 379.0 + closest_center.y * 0.0 + 333.0),
        rand(closest_center.x * 379.0 + closest_center.y * 0.0 + 796.0),
        rand(closest_center.x * 379.0 + closest_center.y * 0.0 + 221.0));
    
    color = color / max(max(color.x, color.y), max(color.z, 0.1));
    
    color = mix(color, vec3(1.0, 1.0, 0.5), 0.25);
        
    float black_or_white = 0.5 + 0.5 * sin(
        2.0 * 3.14159 * 
        (rand((closest_center.x + 347.0) * (closest_center.y + 7.0 * 129.0)) + iGlobalTime * 0.5));
    
    black_or_white = pow(black_or_white, 10.0);
    
    float near_bottom = pow(1.0-uv.y, 3.0);

    closest_center = closest_center + jitterrad * 1.0 *
        sin((iGlobalTime * 0.8 + rand2(closest_center)) * 6.28 +
        sin((iGlobalTime * 0.2 + rand2(closest_center.yx)) * 6.28) +
        sin((iGlobalTime * 0.5 + rand2(closest_center.xx * 93.0 + 127.0)) * 6.28)) +
        vec2((0.2 * near_bottom * gap.x) * sin(2.0*iGlobalTime + 2. * 6.28 * rand(closest_center.x)), 0.0);

    vec2 distvec = param_pos - closest_center;
    distvec.x /= (1.-black_or_white);
    float dist = length(distvec); 

    float s = (dist * dist) / (ballrad * ballrad);

    fragColor = mix(
        mix(
            vec4(color, 1.0), 
            v4Black, black_or_white), 
        mix(vec4(0.1,0.1,0.3,1.0), vec4(0.0,0.0,0.2,1.0), smoothstep(0.0,0.25,uv.y)), 
        smoothstep(ballrad*0.9, ballrad*1.1, dist));

}