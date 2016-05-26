// Shader downloaded from https://www.shadertoy.com/view/MddXzl
// written by shadertoy user finalman
//
// Name: Quantum Foam
// Description: if you gaze long into an abyss, the abyss also gazes into you
const int MAX_STEPS = 12;
const float EPSILON = 1e-10;
const vec4 HASHSCALE4 = vec4(1031, .1030, .0973, .1099);


vec4 hash43(vec3 p)
{
    // By Dave_Hoskins
	vec4 p4 = fract(vec4(p.xyzx)  * HASHSCALE4);
    p4 += dot(p4, p4.wzxy+19.19);
	return fract(vec4((p4.x + p4.y)*p4.z, (p4.x + p4.z)*p4.y, (p4.y + p4.z)*p4.w, (p4.z + p4.w)*p4.x));
}

vec4 sphereAt(vec3 p)
{
    vec4 sphere = hash43(p) + vec4(p, 0.0);
    
    sphere.w *= smoothstep(1.0, 8.0, distance(sphere.xyz, vec3(0, 0, iGlobalTime * 0.5)));
    
    return sphere;
}

float df(vec3 p)
{
    vec3 tile = floor(p);
    float result = 1.0;
    
    for (int z = -1; z <= 1; z++)
    {
        for (int y = -1; y <= 1; y++)
        {
            for (int x = -1; x <= 1; x++)
            {
                vec4 sphere = sphereAt(tile + vec3(float(x), float(y), float(z)));
                if (sphere.w > 0.0)
                {
                	result = min(result, distance(p, sphere.xyz) - sphere.w);
                }
            }
        }
    }
    
    return result;
}

vec3 normal(vec3 p)
{
    float N = 0.01;
    float c = df(p);
    return normalize(vec3(
        (df(p + vec3(N, 0, 0)) - c) / N,
        (df(p + vec3(0, N, 0)) - c) / N,
        (df(p + vec3(0, 0, N)) - c) / N
	));
}

vec3 march(vec3 o, vec3 d)
{
    for (int i = 0; i < MAX_STEPS; i++)
    {
        float dist = df(o);
        
        o += d * dist * 10.0;
        
        if (dist < EPSILON)
        {
            break;
        }
    }
    
    return o;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 o = vec3(sin(iGlobalTime), 0, iGlobalTime * 0.5);
    vec3 d = normalize(vec3((fragCoord.xy - iResolution.xy * 0.5) / iResolution.y, 0.7));
	
    vec3 p = march(o, d);
    vec3 n = normal(p);
    
	vec3 color = vec3(dot(n, normalize(vec3(-0.5, 1.0, -2.0))));
                      
    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}