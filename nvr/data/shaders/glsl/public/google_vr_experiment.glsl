// Shader downloaded from https://www.shadertoy.com/view/ldVGz3
// written by shadertoy user jackdavenport
//
// Name: Google VR Experiment
// Description: A test of using the Shadertoy app to create a VR app for Google Cardboard
#define MAX_ITERATIONS 256
#define MIN_DISTANCE  .001

#define LIGHT_DIR normalize(vec3(45.,30.,-45.))

struct Ray { vec3 ori; vec3 dir; };
struct Dst { float dst; int id;  };
struct Hit { vec3 p; int id; 	 };
    
Dst dstSphere(vec3 p, vec3 pos, float r) {

    return Dst(length(pos - p) - r, 0);
    
}

Dst dstFloor(vec3 p, float y) {
 
    return Dst(p.y - y, 1);
    
}

Dst minDst(Dst a, Dst b) {
 
    if(a.dst < b.dst) return a;
    return b;
    
}

Dst dstScene(vec3 p) {
 
    p.x -= 1.;
    
    Dst dst = dstSphere(p, vec3(1.,0.,0.), 1.);
    dst = minDst(dst, dstSphere(p, vec3(9.,0.,2.), 1.));
    dst = minDst(dst, dstFloor(p, -1.));
    
    return dst;
    
}

Hit raymarch(Ray ray) {
 
    vec3 p = ray.ori;
    int id = -1;
    
    for(int i = 0; i < MAX_ITERATIONS; i++) {
     
        Dst scn = dstScene(p);
        p += ray.dir * scn.dst * .5;
        
        if(scn.dst < MIN_DISTANCE) {
         
            id = scn.id;
            break;
            
        }
        
    }
    
    return Hit(p,id);
    
}

vec3 calcNormal(vec3 p) {
 
    vec2 eps = vec2(.001,0.);
    vec3   n = vec3(dstScene(p + eps.xyy).dst - dstScene(p - eps.xyy).dst,
                    dstScene(p + eps.yxy).dst - dstScene(p - eps.yxy).dst,
                    dstScene(p + eps.yyx).dst - dstScene(p - eps.yyx).dst);
    return normalize(n);
    
}
    
vec3 calcLighting(vec3 p, vec3 ld, vec3 n) {
 
    float d = max(dot(ld,n),0.);
    
    Ray sr = Ray(p + ld * .04, ld);
    Hit sh = raymarch(sr);
    if(sh.id != -1) d = 0.;
    
    return vec3(d);
    
}

vec3 shade(Ray ray) {
 
    Hit scn  = raymarch(ray);
    vec3 col = textureCube(iChannel0, ray.dir).xyz;
    
    if(scn.id == 0) {
     
        vec3 n = calcNormal(scn.p);
        vec3 d = calcLighting(scn.p,LIGHT_DIR,n);
        
        vec3 r = normalize(reflect(ray.dir,n));
       	vec3 s = pow(max(dot(r,LIGHT_DIR), 0.), 60.) * d;
        
        col = vec3(1.,0.,0.) * d + s;
        
    } else if(scn.id == 1) {
     
        vec3 n = calcNormal(scn.p);
        vec3 d = calcLighting(scn.p,LIGHT_DIR,n);
        
        col = texture2D(iChannel1,mod(scn.p.xz / 4., 1.)).xyz * d;
        
    }
    
    return col;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    if(uv.x > .5) fragCoord.x -= iResolution.x * .5;
    
    //fragCoord.xy *= 5.;
    
    vec3 ori = vec3(.03 * (uv.x > .5 ? -1. : 1.) + 4.5 + sin(iGlobalTime), 0., -5.);
    vec3 dir = vec3((fragCoord - iResolution.xy * .5) / iResolution.y, 1.);
    
    vec3 col = shade(Ray(ori,dir));
    fragColor = vec4(col, 1.);
}