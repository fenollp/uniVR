// Shader downloaded from https://www.shadertoy.com/view/XsdGDM
// written by shadertoy user jackdavenport
//
// Name: Volumetric Light
// Description: My first attempt at volumetric lighting! Built upon this amazing shader: https://www.shadertoy.com/view/4dsGRn
#define MAX_ITERATIONS 64
#define MIN_DISTANCE .001
#define SAMPLES 5
#define AMBIENT .2

struct Ray {
  vec3 ori;
  vec3 dir;
};
struct Dist {
  float dst;
  int id;
};
struct Hit {
  vec3 p;
  float dst;
  int id;
};
struct Light {
  vec3 p;
  float r;
};
   
// Source: http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 co) {
    
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);

}
    
float distSphere(vec3 p, vec3 pos, float radius) {

    return length(pos - p) - radius;
    
}

Dist distScene(vec3 p) {
 
    float dSphere = distSphere(p, vec3(0.,0.,0.), 1.);
    return Dist(dSphere, 0);
    
}

Hit raymarch(Ray ray) {
 
    vec3 p  = ray.ori;
    float d = 0.;
    int  id = -1;
    
    for(int i = 0; i < MAX_ITERATIONS; i++) {
        
   		p = ray.ori + ray.dir * d;
    	Dist dst = distScene(p);
        
        d += dst.dst * .75;
        
        if(dst.dst < MIN_DISTANCE) {
         
            p  = ray.ori + ray.dir * d;
            id = dst.id;
            break;
            
        }
        
    }
    
    return Hit(p,d,id);
    
}

Light getLight() {
 
    float t = iGlobalTime;
    if(iMouse.z > 0.) t = 2. * (iMouse.x / iResolution.x) * 2. - 1.;
    return Light(vec3(-3. * cos(t),2. * sin(t), 2. * sin(t)), 40.);
    
}

vec3 calcIrradiance(Light l, vec3 p) {
 
    return vec3(1. - clamp(length(l.p - p) / l.r, 0., 1.));
    
}

vec3 calcNormal(vec3 p) {
 
    vec2 eps = vec2(MIN_DISTANCE, 0.);
    vec3 n = vec3(distScene(p + eps.xyy).dst - distScene(p - eps.xyy).dst,
                  distScene(p + eps.yxy).dst - distScene(p - eps.yxy).dst,
                  distScene(p + eps.yyx).dst - distScene(p - eps.yyx).dst);
    return normalize(n);
    
}

vec3 calcLighting(Ray ray, Hit hit, vec3 n) {
 
    Light l = getLight();
    vec3  i = calcIrradiance(l, hit.p);
    
    if(i == vec3(0.)) {
     
        return vec3(AMBIENT);
        
    }
    
    vec3 ld = normalize(l.p - hit.p);
    float d = max(dot(ld,n), 0.);
    
    return clamp(AMBIENT + vec3(d) * i, 0., 1.);
    
}

vec3 calcVolumetric(Ray ray, float maxDist) {
 
    vec3 col = vec3(0.);
    
    Light l   = getLight();
    float is  = maxDist / 50.;
    float vrs = maxDist / float(SAMPLES - 1);
    float rs  = rand(gl_FragCoord.xy) + vrs;
    
    Ray volRay = Ray(ray.ori + ray.dir * rs, vec3(0.));
    
    for(int v = 0; v < SAMPLES; v++) {
     
        vec3 lv    = l.p - volRay.ori;
        float ld   = length(lv);
        volRay.dir = lv / ld;
        Hit i      = raymarch(volRay);
        
        if(i.dst > ld) {
         
            col += calcIrradiance(l, volRay.ori) * is;
            
        }
        
        volRay.ori += ray.dir * vrs;
        
    }
    
    return col;
    
}

vec3 clearColor(vec3 dir) {
 
    return textureCube(iChannel0, dir).xyz * .1;
    
}

vec3 shade(Ray ray) {
 
    Hit scene = raymarch(ray);
    vec3 col = vec3(0.);
    
    if(scene.id == 0) {
     
        vec3 n = calcNormal(scene.p);
        col = calcLighting(ray, scene, n);
        
    } else {
     
        col = clearColor(ray.dir);
        
    }
    
    vec3 vl = calcVolumetric(ray, min(scene.dst, 3.));
    col -= vl * .5;
    col += vl;
    
    return col;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy / 2.) / iResolution.y;
    
    vec3 ori = vec3(0., 0., -4.);
    vec3 dir = vec3(uv, 1.);
    
    Ray  ray = Ray(ori,dir);
    vec4 col = vec4(clamp(shade(ray),0.,1.),1.0);
    
	fragColor = col;
}