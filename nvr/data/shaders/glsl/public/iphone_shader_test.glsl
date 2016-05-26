// Shader downloaded from https://www.shadertoy.com/view/MdtGzj
// written by shadertoy user jackdavenport
//
// Name: iPhone Shader Test
// Description: Just got a new phone, so now that my phone can load basic shaders without slowing to 15fps, I'm just writing this shader to test out different kinds of raymarchers on it.
#define MAX_ITERATIONS 256
#define MAX_ITERATIONS_S 128
#define MIN_DISTANCE .01

struct Ray { vec3 ori; vec3 dir; };
struct Dst { float dst; int id;  };
struct Hit { vec3 p; int id;     };

float dSphere(vec3 p, vec3 pos, float radius) {

    return length(pos - p) - radius;
    
}

float dFloor(vec3 p, float y) {
 
    return p.y - y;
    
}

Dst distScene(vec3 p) {
 
    float flor = dFloor(p, -1.);
    float sph1 = dSphere(p, vec3(sin(iGlobalTime), 0., 0.), 1.);
    
    float dst = min(flor,sph1);
    return Dst(dst, dst == sph1 ? 0 : 1);
    
}

Hit raymarch(Ray ray, bool secondary) {

    vec3 p = ray.ori;
    int id = -1;
    
    for(int i = 0; i < MAX_ITERATIONS_S; i++) {
     
        Dst scn = distScene(p);
        p += ray.dir * scn.dst;
        
        if(scn.dst < MIN_DISTANCE) {
         
            id = scn.id;
            break;
            
        }
        
    }
    
    return Hit(p,id);
    
}
    
vec3 clearColor(vec3 dir) {
 
    return textureCube(iChannel0, dir).xyz;
    
}

vec3 getLightDirection(vec3 p) {
 
    return vec3(1.,1.5,-1.) - p;
    
}

vec3 calcNormal(vec3 p) {
 
    vec2 eps = vec2(.001, .0);
    vec3 n = vec3(distScene(p + eps.xyy).dst - distScene(p - eps.xyy).dst,
                  distScene(p + eps.yxy).dst - distScene(p - eps.yxy).dst,
                  distScene(p + eps.yyx).dst - distScene(p - eps.yyx).dst);
    return normalize(n);
    
}

vec3 getDiffuse(Hit hit, vec3 n) {
 
    const float a = .2;
    vec3 ld = getLightDirection(hit.p);
    float d = a + max(dot(normalize(ld),n), 0.);
    d *= 1. - clamp(length(ld) / 20., 0., 1.);
    
    ld = normalize(ld);
    Ray sr = Ray(hit.p + (ld * MIN_DISTANCE), ld);
    Hit sh = raymarch(sr, true);
    
    if(sh.id != -1) d = a;
    return vec3(d);
    
}

vec3 shadePlane(Hit scn, Ray ray) {
    
    vec3 n = calcNormal(scn.p);
    vec3 d = getDiffuse(scn, n);
        
    return vec3(1.) * d;
    
}

vec3 shade(Ray ray) {
 
    Hit scn = raymarch(ray, false);
    
    if(scn.id == 0) {
     
        vec3 n = calcNormal(scn.p);
		vec3 rd = reflect(ray.dir, n);
        Ray rr = Ray(scn.p + (rd * MIN_DISTANCE), rd);
        Hit rh = raymarch(rr, true);
        
        if(rh.id == 1) {
         
            return shadePlane(rh,rr);
            
        }
        
        return clearColor(rd);
        
    } else if(scn.id == 1) {
     
        return shadePlane(scn, ray);
        
    }
    
    return clearColor(ray.dir);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy / 2.) / iResolution.y;
    
    vec3 ori = vec3(0.,0.,-3.);
    vec3 dir = vec3(uv, 1.);
    
    vec3 col = shade(Ray(ori,dir));
	fragColor = vec4(col,1.0);
}