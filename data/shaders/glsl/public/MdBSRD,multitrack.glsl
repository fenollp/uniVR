// Shader downloaded from https://www.shadertoy.com/view/MdBSRD
// written by shadertoy user Sebbert
//
// Name: multitrack
// Description: Aaaaand it's 4am...
precision highp float;

const float TAU = 6.2831;

const float TEMPO = 130.0;

const float b1_4 = 60.0 / TEMPO;
const float b1_1   = b1_4  * 4.0;
const float b1_8   = b1_4  / 2.0;
const float b1_16  = b1_8  / 2.0;
const float b1_32  = b1_16 / 2.0;

const float b1_4t  = b1_1  / 3.0;
const float b1_8t  = b1_4  / 3.0;
const float b1_16t = b1_8  / 3.0;
const float b1_32t = b1_16 / 3.0;

vec2 coord;

float clamp_c(float mn, float mx, float n)
{
    return max(mn, min(mx, n));
}

float map(float n, float a, float b, float c, float d)
{
    return (n-a)/(b-a) * (d-c) + c;
}

vec2 map(vec2 n, float a, float b, float c, float d)
{
    return vec2(map(n.x, a, b, c, d), map(n.y, a, b, c, d));
}

vec2 map(vec2 n, vec2 a, vec2 b, vec2 c, vec2 d)
{
    return (n-a)/(b-a) * (d-c) + c;
}

float adsr(vec4 adsr, float t)
{
    float a = adsr.x;
    float d = adsr.y;
    float s = adsr.z;
    float r = adsr.w;
    
    // Note off
    if(t <= 0.0)
    {
        return 0.0;
    }
    
    // Attack
    if(t < a)
    {
        return t / a;
    }
    
    // Decay/sustain
    if(t < a + d)
    {
        return map(t - a, 0.0, d, 1.0, s);
    }
    
    // Release
    return max(map(t - a - d, 0.0, r, s, 0.0), 0.0);
}

float circle(vec2 p, float r, float smooth)
{
    return smoothstep(-abs(smooth), 0.0, clamp(0.0, 1.0, (r - distance(coord, p)) / r));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    coord = vec2(
        (fragCoord.x - iResolution.x / 2.0) / iResolution.y,
        (fragCoord.y / iResolution.y) - 0.5);
    
    float total = 0.0;
    
    float period = mod(iGlobalTime, b1_1) / b1_1;
    
    for(int i = 0; i < 16; ++i)
    {
        float n = float(i);
        float a = n / 16.0;
        float pt = mod(period + 0.06 - a, 1.0);
        float env = adsr(vec4(0.06, 0.3, 0.2, 0.2), pt);
        
        float am;
        am = clamp_c(0.0, 1.0, env) * 0.6;
        
        if(mod(n + 4.0, 4.0) == 0.0)
            am += adsr(vec4(0.06, 0.25, 0.15, 0.2), pt) * 3.5;
        
        vec2 p = vec2(
             cos(TAU * (a - 90.0 + sin(iGlobalTime))),
            -sin(TAU * (a - 90.0 + cos(iGlobalTime)))
            );
        
        p *= 0.3;
        
        float o = 0.0;
        o += circle(p * 1.5, 0.03 * am, 0.6);
        o += circle(p, 0.03, map(am, 0.0, 1.0, -0.0, 8.0));
        
        o *= am;
        
        total += o;
    }
    
     vec4 oc = vec4(total, total, total, 1.0);
    vec4 bg = vec4(coord.x + 1.0, coord.y + 1.0, 1.0, 1.0);
    oc *= bg * 0.5;
    fragColor = oc;
}