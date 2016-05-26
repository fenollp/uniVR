// Shader downloaded from https://www.shadertoy.com/view/XllSzs
// written by shadertoy user miloszmaki
//
// Name: plants
// Description: lifecycle of plants, made for competition on warsztat.gd
//    this is one of my first attempts on raymarching, any ideas on how to optimize it are welcome (or maybe my poor notebook is the problem)
const int NUM_PLANTS_SQRT = 3;
const float LIFE_TIME = 10.0;
const vec2 DIMENSIONS = vec2(20);
#define REPEAT

const int RAYMARCH_ITER = 50;
const float RAYMARCH_EPS = 0.01;
const float DITHERING = 2.0;

const float PI = 3.14159265;

#define saturate(x) clamp(x, 0., 1.)

float rand(float x) { return fract(sin(x * 42.5723) * 12571.1385); }
float rand(vec2 x) { return fract(sin(dot(x, vec2(13.3571,65.1495))) * 32718.2741); }

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = p - i;
	vec2 u = f*f*(3.0-2.0*f);
    return mix( mix( rand( i + vec2(0,0) ), 
                     rand( i + vec2(1,0) ), u.x),
                mix( rand( i + vec2(0,1) ), 
                     rand( i + vec2(1,1) ), u.x), u.y);
}

float noise(vec3 x)
{
    vec3 p = floor(x);
    vec3 f = x - p;
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( rand(n+  0.0), rand(n+  1.0),f.x),
                   mix( rand(n+157.0), rand(n+158.0),f.x),f.y),
               mix(mix( rand(n+113.0), rand(n+114.0),f.x),
                   mix( rand(n+270.0), rand(n+271.0),f.x),f.y),f.z);
}

float fbm(vec2 x)
{
    float r = 0.0;
    float w = 1.0, s = 1.0;
    for (int i=0; i<5; i++)
    {
        w *= 0.5;
        s *= 2.0;
        r += w * noise(s * x);
    }
    return r;
}

float fbm(vec3 x)
{
    float r = 0.0;
    float w = 1.0, s = 1.0;
    for (int i=0; i<5; i++)
    {
        w *= 0.5;
        s *= 2.0;
        r += w * noise(s * x);
    }
    return r;
}

float dPlane(vec3 p) { return p.y; }
float dSphere(vec3 p, float r) { return length(p) - r; }
float dBox(vec3 p, vec3 s) { return length(max(abs(p) - s, 0.)); }
float dRoundBox(vec3 p, vec3 s, float r) { return length(max(abs(p) - s, 0.)) - r; }

vec2 dUnion(vec2 d1, vec2 d2) { return (d1.x < d2.x) ? d1 : d2; }

vec3 pMov(vec3 p, vec3 t) { return p - t; }
vec3 pRep(vec3 p, vec3 s) { return mod(p+.5*s, s) - .5*s; }
vec3 pRotY(vec3 p, float a) { float s=sin(a), c=cos(a); return vec3(mat2(c,-s,s,c)*p.xz, p.y).xzy; }

void addLeaf(inout vec2 d, vec3 pos, vec3 ext, float skew, float mtl)
{
    pos.y -= ext.y;
    float h1 = pos.y / ext.y;
    float h2 = abs(h1);
    h1 = h1 * .5 + .5;
    ext.xz *= vec2(0.01, 0.1) + (1. - h2*h2);
    pos.z += h1*h1 * skew;
    d = dUnion(d, vec2(dRoundBox(pos, ext, 0.02), mtl));
}

float plantMtl(float age, float f)
{
    return age * (1. - f) + f;
}

void addPlant(inout vec2 d, vec3 pos, float age)
{
    vec4 h;
    h.x = 1.09091-0.1/(age+0.1); h.y = h.x*h.x; h.z = h.y*h.x; h.w = 1.0;
    float s = smoothstep(0.5, 1.0, age);
    vec3 h2 = vec3(1., 1.-s, 1.);
    
    float th = 0.1;    
    vec3 ls1 = vec3(1.5,3.2,th), ls2 = vec3(2.2,4.8,th),
         ls3 = vec3(1.1,2.4,th), ls4 = vec3(0.5,5.6,th);
    
    vec4 sk = h.yzyx * vec4(2.5, 4.0, 2.0, 0.8);
    sk = mix(sk, vec4(ls1.y,ls2.y,ls3.y,ls4.y), s);
    
    float mtl = age + 1.0;
    
    addLeaf(d, pMov(pos, vec3(0,0,-0.2)),				h2*h.zyw*ls1, sk.x, plantMtl(age,0.05));
    addLeaf(d, pRotY(pMov(pos, vec3(0.0,0,0.3)), 2.5),	h2*h.yxw*ls2, sk.y, plantMtl(age,0.08));
    addLeaf(d, pRotY(pos, -1.9),						h2*h.zxw*ls3, sk.z, plantMtl(age,0.1));
    addLeaf(d, pRotY(pMov(pos, vec3(0.2,0,0.2)), -1.2),	h2*h.zzw*ls4, sk.w, plantMtl(age,0.0));
}

vec2 scene(vec3 pos)
{
    vec2 d = vec2(dPlane(pMov(pos, vec3(0,0.4,0))), 2.0);
    
    vec3 dim = vec3(DIMENSIONS.x, 1000, DIMENSIONS.y);
    vec2 grid = dim.xz / float(NUM_PLANTS_SQRT);
    
    for (int i=0; i<NUM_PLANTS_SQRT; i++)
        for (int j=0; j<NUM_PLANTS_SQRT; j++)
    {
        float t = rand(float(i*NUM_PLANTS_SQRT+j+1)) + iGlobalTime / LIFE_TIME;
        float f = floor(t);
        float age = t - f;
        vec3 p = vec3(0);
        p.xz = vec2(rand(f), rand(f+53.5421)) * 0.4 + 0.3;
        p.xz += vec2(i,j);
        p.xz *= grid;
        p.xz -= 0.5 * dim.xz;
        p = pMov(pos, p);
        #ifdef REPEAT
        p = pRep(p, dim);
        #endif
    	addPlant(d, p, age);
    }
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
        z += d.x * 0.5;
    }
    
    if (z > zf) mtl = -1.0;
    return z;
}

vec3 calcNormal(vec3 p)
{
	vec3 e = vec3(0.001,0.,0.);
	return normalize(vec3(
        	scene(p+e.xyy).x - scene(p-e.xyy).x,
			scene(p+e.yxy).x - scene(p-e.yxy).x,
			scene(p+e.yyx).x - scene(p-e.yyx).x ));
}

float calcAO(vec3 p, vec3 n)
{
	float ao = 0.0;
    float s = 1.0;
    for (int i=0; i<5; i++)
    {
        float hr = 0.01 + 1.5*float(i)/4.0;
        float dd = scene(n * hr + p).x;
        ao += -(dd-hr)*s;
        s *= 0.5;
    }
    return saturate(1.0 - 0.4 * ao);
}

float groundNoise(vec3 pos)
{
    return fbm(0.2*pos.xz);
}

vec3 groundNorm(vec3 pos)
{
    vec3 e = vec3(0.01,0.,0.);
    float n = groundNoise(pos);
    return normalize(vec3(groundNoise(pos+e.xyy) - n, 0.01,
                          groundNoise(pos+e.yyx) - n));
}


vec3 render(vec3 eye, vec3 dir)
{
    float zn = 5., zf = 200.;
    float mtl;
    float dist = rayMarch(eye, dir, zn, zf, mtl);
    vec3 pos = eye + dist * dir;
    vec3 norm = calcNormal(pos);
    vec3 light = normalize(vec3(0.7,1.,0.));
	vec3 refl = reflect(dir, norm);
    
    if (mtl > 1.0) norm = groundNorm(pos);
    
    float ndl = dot(norm, light);
    float back = saturate(-ndl);
    ndl = saturate(ndl);
    
    vec3 albedo = vec3(step(0.,mtl));
    vec3 plant_alb = mix(vec3(0.3,0.9,0.1), vec3(0.6,0.4,0.15), saturate(mtl));
    plant_alb *= fbm(0.8*pos) * 0.3 + 0.7;
	vec3 ground_alb = mix(vec3(0.36,0.23,0.17), 0.8*vec3(0.23,0.16,0.1), groundNoise(pos));
    albedo *= mix(plant_alb, ground_alb, saturate(mtl - 1.0));
    
    vec3 scat = albedo * vec3(1.2, 1.4, 1.0);
    scat *= back*back;
    
    float spec = pow(saturate(dot(refl, light)), 32.);
    
    float ao = calcAO(pos, norm);
    vec3 ambient = 0.2 * albedo * ao;
    spec *= ao;
        
	vec3 color = ambient + albedo * (1. + 0.5 * spec) * ndl + scat;
    float fog = dist / zf;
    color = mix(color, vec3(0.7,0.8,1.0)*1.3, saturate(fog));
                         
    return saturate(color);
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
    uv.x *= iResolution.x / iResolution.y;
    
    float angle = iGlobalTime * 0.1;
    angle += iMouse.x / iResolution.x * 2. * PI;
    vec3 eye = vec3(sin(angle), 1.0 + 0.2 * sin(angle * 4.5)*0.1, cos(angle));
    eye *= 15.;
    vec3 dir = lookAtDir(uv, eye, vec3(0, 0, 0), vec3(0, 1, 0), 1.0);
	
    vec3 color;
    eye += dir * rand(uv + angle) * DITHERING;
    color = render(eye, dir);
    
    fragColor = vec4(color, 1.0);
}