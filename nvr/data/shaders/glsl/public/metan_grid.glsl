// Shader downloaded from https://www.shadertoy.com/view/XtlXRs
// written by shadertoy user miloszmaki
//
// Name: metan grid
// Description: experimenting with raymarching
const int RAYMARCH_ITER = 50;
const float RAYMARCH_EPS = 0.01;
const float PI = 3.14159265;

float dPlane(vec3 p) { return p.y; }
float dSphere(vec3 p, float r) { return length(p) - r; }
float dBox(vec3 p, vec3 s) { return length(max(abs(p) - s, 0.)); }

vec2 dUnion(vec2 d1, vec2 d2) { return (d1.x < d2.x) ? d1 : d2; }

vec3 pMov(vec3 p, vec3 t) { return p - t; }
vec3 pRep(vec3 p, vec3 s) { return mod(p+.5*s, s) - .5*s; }

void addSphere(inout vec2 d, vec3 pos, vec3 t, float mtl)
{
    d = dUnion(d, vec2(dSphere(pRep(pMov(pos, t), vec3(10,4,5)), 0.35), mtl));
}

vec2 scene(vec3 pos)
{
    vec2 d = vec2(dPlane(pMov(pos, vec3(0,-2,0))), 1.0);
    addSphere(d, pos, vec3(0,1,0), 1.0);
    addSphere(d, pos, vec3(0,-1,0), 1.0);
    addSphere(d, pos, vec3(1,0,0), 1.0);
    addSphere(d, pos, vec3(-1,0,0), 1.0);
    addSphere(d, pos, vec3(0,0,1), 1.0);
    addSphere(d, pos, vec3(0,0,-1), 1.0);
    addSphere(d, pos, vec3(0,0,0), 1.0);
    return d;
}

float rayMarch(vec3 eye, vec3 dir, float zn, float zf, out float mtl)
{
    float z = zn;
    mtl = -1.0;
    
    for (int i=0; i < RAYMARCH_ITER; i++)
    {
        vec2 d = scene(eye + z * dir);
        mtl = d.y;
        if (d.x < RAYMARCH_EPS || z > zf) break;
        z += d.x;
    }
    
    if (z > zf) mtl = -1.0;
    return z;
}

vec3 render(vec3 eye, vec3 dir)
{
    float mtl;
    float dist = rayMarch(eye, dir, 1., 100., mtl);
    
    vec3 color = vec3(dist / 100.);
    //if (mtl > 0.) color *= mtl;
    
    return clamp(color, 0., 1.);
}

vec3 lookAtDir(vec2 uv, vec3 eye, vec3 at, vec3 up, float fov)
{
    vec3 f = normalize(at - eye);
    vec3 r = normalize(cross(up, f));
    vec3 u = normalize(cross(f, r));
    return normalize(f + fov * (uv.x*r + uv.y*u));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    vec2 uv0 = uv;
    uv.x *= iResolution.x / iResolution.y;
    
    float angle = iGlobalTime * 0.3 + 0.5;
    if (iMouse.z > 0.) angle = iMouse.x / iResolution.x * 2. * PI;
    vec3 eye = vec3(sin(angle), 0.5 + sin(angle * 4.5)*0.1, cos(angle));
    eye *= 8. + 2. * sin(iGlobalTime * 0.6);
    vec3 dir = lookAtDir(uv, eye, vec3(0, 0, 0), vec3(0, 1, 0), 1.0);
	
    float at = 0.005 + 0.008 * fract(sin(iGlobalTime) * 204.512598);
    vec3 color;
    color.r = render(eye, dir + vec3(-1,1,0)*at).x;
    color.g = render(eye, dir).x;
    color.b = render(eye, dir + vec3(0,-1,0)*at).x;
    
    color *= 1. - pow(max(0., length(uv0)-.5), 3.);
    
    fragColor = vec4(color, 1.0);
}