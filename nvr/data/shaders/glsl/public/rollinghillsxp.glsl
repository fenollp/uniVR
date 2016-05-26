// Shader downloaded from https://www.shadertoy.com/view/4scGW7
// written by shadertoy user nslottow
//
// Name: RollingHillsXP
// Description: Understanding raymarching via iq's nice article: http://www.iquilezles.org/www/articles/terrainmarching/terrainmarching.htm

float f(float x, float z)
{
    return sin(x + cos(z * 3.0 + iGlobalTime * 0.5)) * sin(z + iGlobalTime);
}

bool castRay(vec3 ro, vec3 rd, out float resT)
{
    const float mint = 0.001;
    const float maxt = 20.0;
    const float dt = 0.08;
    float lh = 0.0;
    float ly = 0.0;
    
    float t = mint;
    
    for (float t = mint; t < maxt; t += dt)
    {
        vec3 p = ro + rd * t;
        float h = f(p.x, p.z);
        if (p.y < h)
        {
            resT = t - dt + dt * (lh - ly) / (p.y - ly - h + lh);
            return true;
        }
        lh = h;
        ly = p.y;
    }
    
    return false;
}

vec3 getNormal(vec3 p)
{
    const float eps = 0.02;
    vec3 n = vec3(
        f(p.x - eps, p.z) - f(p.x + eps, p.z),
        2.0 * eps,
        f(p.x, p.z - eps) - f(p.x, p.z + eps));
    return normalize(n);  
}

vec3 getShading(vec3 p, vec3 n)
{
    return dot(n, vec3(0.0, 1.0, 0.0)) * vec3(0.2, 0.7, 0.2);
}

vec3 terrainColor(vec3 ro, vec3 rd, float t)
{
    vec3 p = ro + rd * t;
    vec3 n = getNormal(p);
    vec3 s = getShading(p, n);
    
    return s;
}

vec3 skyColor(vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    return vec3(0.4, 0.6, 0.9 * uv.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x / iResolution.y;
    const float hfov = 45.0 * 0.5 * 3.1415926535 / 180.0;
    const float tanhfov = tan(hfov);
    const float near = 0.1;
    const float far = 1.0;
    
    vec2 uv = fragCoord.xy / (iResolution.xy * 0.5) - vec2(1.0, 1.0);
    float dx = tanhfov * uv.x / aspect;
    float dy = tanhfov * uv.y;
    
    vec3 viewRayDir = normalize(vec3(dx, dy, 1.0) * (far - near));
    
    float bob = -0.4 + 0.1 * cos(iGlobalTime * 0.5);
    mat4 inverseViewMatrix = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, bob, 1.0, 0.0,
        0.0, 0.0, 0.0, 0.0
        );
    
    const vec3 ro = vec3(0.0, 7.0, 0.0);
    vec3 rd = (inverseViewMatrix * vec4(viewRayDir, 0.0)).xyz;
    float resT;
    
    if (castRay(ro, rd, resT))
    {
        fragColor = vec4(terrainColor(ro, rd, resT), 1.0);
    }
    else
    {
        fragColor = vec4(skyColor(fragCoord), 1.0);
    }
}