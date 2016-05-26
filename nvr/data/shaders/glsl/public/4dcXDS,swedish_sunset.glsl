// Shader downloaded from https://www.shadertoy.com/view/4dcXDS
// written by shadertoy user finalman
//
// Name: Swedish Sunset
// Description: Go fullscreen and relax for a bit
const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.0 * PI;
const float BIG = 1e30;
const float EPSILON = 1e-10;

struct Ray
{
    vec3 o;
    vec3 d;
};
    
struct Intersection
{
    float dist;
    vec3 normal;
};
    
struct Trees
{
    float dist;
    float alpha;
};


mat3 rotate3Z(float v)
{
    float s = sin(v);
    float c = cos(v);
    return mat3(
        c,-s, 0,
        s, c, 0,
        0, 0, 1
	);
}

mat3 rotate3X(float v)
{
    float s = sin(v);
    float c = cos(v);
    return mat3(
        1, 0, 0,
        0, c,-s,
        0, s, c
	);
}
    
Intersection water(Ray r)
{
    Intersection result;
    result.dist = r.o.y / -r.d.y;
    vec3 pos = r.o + r.d * result.dist;
    result.normal = normalize(vec3(
        sin(pos.z + iGlobalTime) * 0.2,
        10.0 + (pos.z + 15.0) * 0.33,
        cos(pos.x + iGlobalTime * 0.1) * 0.05));
    return result;
}

Trees trees(Ray r)
{
    Trees result;
    result.dist = (r.o.z - 200.0) / -r.d.z;
    vec3 pos = r.o + r.d * result.dist;
    float n = pos.y;
    n *= (smoothstep(0.0, 600.0, abs(pos.x + 30.0)) + 0.18);
    n *= (smoothstep(0.0, 200.0, abs(pos.x + 300.0)));
    n += sin(pos.x + pos.y * 2.0) * 0.05;
    n += (texture2D(iChannel0, vec2(pos.x * 0.004, pos.x * 0.003)).x - 0.5) * 0.5;
    float t = max(0.1, length(vec2(dFdx(n), dFdy(n))));
    result.alpha = smoothstep(4.0 + t, 4.0 - t, n);
    return result;
}

vec3 palette(vec3 a, vec3 b, vec3 c, float t)
{
    float x = smoothstep(0.0, 0.7, t);
    float y = smoothstep(0.5, 1.0, t);
    return mix(a, mix(c, b, y), x);
}

vec3 stars(Ray r)
{
    vec3 f = texture2D(iChannel0, r.d.xy * 2.0).xyz;
    float p = length(pow(f, vec3(100.0, 75.0, 50.0)) * vec3(0.05, 0.02, 0.01));
    return vec3(p);
}

vec3 venus(Ray r)
{
    vec2 n = vec2(0.5, 0.1) - r.d.xy;
    float t = length(dFdx(n));
    float v = smoothstep(t * 2.2, t * 0.2, length(n));
    return v * vec3(0.17, 0.16, 0.15);
}

vec4 clouds(Ray r)
{
    float dist = (r.o.y + 2000.0) / r.d.y;
    vec3 pos = r.o + r.d * dist;
    pos.z += sin(pos.x * 0.0005 + 2.0) * 500.0;
    float a = max(0.0, sin(pos.z * 0.003 + pos.x * 0.001) * 0.5 + 0.6);
    float m = smoothstep(13000.0, 5000.0, distance(pos.xz, vec2(-15000, 10000)));
    float t = a * m * 0.4;
    return vec4(mix(vec3(0.0), vec3(0.20, 0.07, 0.01) * 0.4, t), t);
}

vec3 sun(Ray r)
{
    vec3 dir = normalize(vec3(-0.04, -0.26 - iGlobalTime * 0.0008, 0.4));
    float n = dot(normalize(r.d), dir) * 0.5 + 0.62 - r.d.y * 0.3;
    n = pow(n, 16.0);
    return palette(vec3(0.003, 0.003, 0.050), vec3(0.95, 0.85, 0.8), vec3(1.2, 0.5, 0.1), n);
}

vec3 sky(Ray r)
{
    vec3 power = vec3(iGlobalTime * 0.001 + 1.0);
    vec4 c = clouds(r);
    c.xyz = pow(c.xyz, power);
    vec3 s = pow(sun(r), power) + venus(r) + stars(r);
    return mix(s, c.xyz, c.w);
}

vec3 render(Ray r)
{
    float b = 1.0;
    Intersection w = water(r);
    Trees t = trees(r);
    
    if (w.dist > 0.0 && w.dist < t.dist)
    {
        b = pow(1.1 - abs(dot(w.normal, r.d)), 5.0);
        
        r.o += r.d * w.dist;
        r.o = min(r.o, 199.9); // Fixes a glitch on Intel
        r.d = reflect(r.d, w.normal);
        t = trees(r);
    }
    
    vec3 s = sky(r);
    
    return mix(s, vec3(0, 0, 0), t.alpha) * b;
}

vec3 toneMap(vec3 color)
{
    return pow(color, vec3(1.0 / 2.2));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    Ray r;
    r.o = vec3(0.0, 2.0, -10.0);
    r.d = normalize(vec3((fragCoord.xy - iResolution.xy * 0.5) / iResolution.y, 0.8));
    
    r.d *= rotate3X(-0.04);
    
    vec3 color = render(r);
    
    color = toneMap(color);
    
    color += texture2D(iChannel0, fragCoord.xy / 256.0).xyz / 100.0;
    
    fragColor = vec4(color, 1.0);
}