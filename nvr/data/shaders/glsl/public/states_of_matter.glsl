// Shader downloaded from https://www.shadertoy.com/view/ltlXzS
// written by shadertoy user miloszmaki
//
// Name: states of matter
// Description: Shader presenting different states of matter (solid, liquid, gas / plasma). Made for competition on warsztat.gd
const float MELTING = 5.0;
const float EVAPORATING = 5.0;
const float DURATION = MELTING + EVAPORATING;
const float RADIUS = 1.0;
const int ITERATIONS = 100;
const vec3 UPDIR = vec3(0, 1, -0.3);
const vec3 EYE = vec3(0, 0, -4);
const float VISIBILITY = 10.0;

float sphere(vec3 p, vec3 pos, float rad)
{
    return length(p - pos) - rad;
}

float plane(vec3 p, vec3 n, float d)
{
    return dot(p, normalize(n)) - d;
}

float circle(vec3 p, vec3 pos, vec3 n, float d, float rad)
{
    return max(sphere(p, pos, rad), plane(p, n, d));
}

float scene(vec3 p, float t)
{
    if (t > MELTING + 0.5*EVAPORATING) t = 0.0;
    t = clamp(t / MELTING, 0.0, 1.0);
    vec3 spos = t * -normalize(UPDIR) * 2.0*RADIUS;
    float d = sphere(p, spos, RADIUS);
    d = min(d, plane(p, UPDIR, -RADIUS));
    d = min(d, circle(p, vec3(0), UPDIR, -RADIUS*0.8, sqrt(t)*RADIUS*3.0));
    return d;
}

vec3 shade(vec3 pos)
{
    float d = 1.0 - length(pos) / VISIBILITY;
    float a = clamp(plane(pos, UPDIR, -RADIUS), 0.0, 1000.0);
    return d * mix(vec3(0.6),vec3(0,0.8,1.0),a*1.5);
}

float plasma(vec2 pos, float rep, float w1, float w2, float w3)
{
    float t = iGlobalTime;
    return sin(rep * (sin(w1*pos.x + t) + sin(w2*pos.y + 5.8*t) + sin(w3*(pos.x - pos.y) + 1.2 * t)));
}

vec3 render(vec3 dir, float t)
{
    vec3 st = dir * (VISIBILITY / float(ITERATIONS));
    vec3 pos = EYE + dir * VISIBILITY;
    vec3 color = vec3(0.0);
    for (int i=0; i<ITERATIONS; i++)
    {
        float d = scene(pos, t);
        if (d <= 0.0) color = shade(pos);
        pos -= st;
    }
    
    float ft = clamp((t - MELTING) / EVAPORATING, 0.0, 1.0);
    float dens = mix(15.0, 5.0, ft*ft);
    float fog = plasma(dens*dir.xy, 5.0, 45.0, -52.0, 35.0);
    ft = clamp(-4.5*ft*(ft-1.0), 0.0, 1.0);
    color = mix(color, vec3(0.4,0.8,1.0)*fog, ft);
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 dir = normalize(vec3(uv, 2.0));
    
    float time = mod(iGlobalTime, DURATION);
	
    vec3 color = render(dir, time);
    
    //color = mix(color, vec3(1), 0.2 * mod(iGlobalTime, 1.0));
    
    fragColor = vec4(color,1.0);
}