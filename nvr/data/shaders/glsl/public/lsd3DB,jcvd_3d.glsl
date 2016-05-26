// Shader downloaded from https://www.shadertoy.com/view/lsd3DB
// written by shadertoy user jackdavenport
//
// Name: JCVD 3D
// Description: Use a chroma key to create an alpha mask, and then uses that alpha mask to texture a 3D object and create shadows. There's some oddities sometimes, but I'm pretty happy with the results.
#define MAX_ITERATIONS 256
#define MIN_DISTANCE  .001
#define LIGHT_DIR normalize(vec3(45.,60.,-45.))

struct Ray { vec3 ori; vec3 dir; };
struct Dist { float dst; int id; };
struct Hit { vec3 p; int id; };
  
// Source: http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 co) {
    
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);

}

vec2 rot2D(vec2 p, float angle) {

	float s = sin(radians(angle));
	float c = cos(radians(angle));
	return p * mat2(c,-s,s,c);

}

Dist distBox(vec3 p, vec3 pos, vec3 box) {

	return Dist(length(max(abs(pos - p) - box,0.)), 0);

}

Dist distFloor(vec3 p, float y) {

	return Dist(p.y - y, 1);

}

Dist minDist(Dist a, Dist b) {

	if(a.dst < b.dst) {
	
		return a;
	
	}
	
	return b;

}

Dist distScene(vec3 p) {

	Dist d = distFloor(p, -0.1);
	d = minDist(d, distBox(p, vec3(1.,1.,3.), vec3(1.,1.,0.05)));

	return d;

}

Hit raymarch(Ray ray) {

	vec3 p = ray.ori;
	int id = -1;
	
	for(int i = 0; i < MAX_ITERATIONS; i++) {
	
		Dist dst = distScene(p);
		p += ray.dir * dst.dst;
		
		if(dst.dst < MIN_DISTANCE) {
		
			id = dst.id;
			break;
		
		}
	
	}
	
	return Hit(p,id);

}

vec3 calcNormal(vec3 p) {

	vec2 eps = vec2(.001,0.);
	vec3 n = vec3(distScene(p + eps.xyy).dst - distScene(p - eps.xyy).dst,
				  distScene(p + eps.yxy).dst - distScene(p - eps.yxy).dst,
				  distScene(p + eps.yyx).dst - distScene(p - eps.yyx).dst);
	return normalize(n);
	
}

vec4 shadeJCVD(Hit scn, Ray ray, vec3 n) {
 
    vec2 uv = mod(scn.p.xy / 2., 1.) - vec2(.0,.0);
    vec4 c  = texture2D(iChannel0, uv);
    
    if(dot(n,ray.dir) == 0.) {
     
        c.a = 0.;
        
    }
    
    return c;
    
}

vec3 calcLighting(Hit scn, Ray ray, vec3 n, bool shadowOnly) {

	float diff = max(dot(LIGHT_DIR,n), 0.);
	if(shadowOnly) diff = 1.;
    
	if(scn.id == 1) {
	
		Ray sr = Ray(scn.p + LIGHT_DIR * .003, LIGHT_DIR);
		Hit sh = raymarch(sr);
	
		if(sh.id == 0) {
		
            vec4 t = shadeJCVD(sh,sr,calcNormal(scn.p));    
			diff = mix(diff,0.,t.a);
		
		}
	
	}

    return vec3(diff);
	return (shadowOnly ? vec3(1.) : vec3(1.,.98,.9)) * diff;

}

vec3 shadeFloor(Hit scn, Ray ray) {
 
    vec3 n = calcNormal(scn.p);
    vec2 uv = mod(scn.p.xz / 2., 1.);
    
	return textureCube(iChannel1, ray.dir).xyz * calcLighting(scn,ray,n,true);
    
}

vec3 shade(Ray ray) {

	Hit scn = raymarch(ray);
	vec3 col = textureCube(iChannel1,ray.dir).xyz;

	if(scn.id == 0) {
	
        vec3 n   = calcNormal(scn.p);
        vec4 tex = shadeJCVD(scn,ray,n);
	
        tex.xyz *= calcLighting(scn,ray,n,false);
        
        if(tex.a < 1.) {
         
            Ray ar = Ray(scn.p + ray.dir * .11, ray.dir);
            Hit ah = raymarch(ar);
            vec3 bg = ah.id == 1 ? shadeFloor(ah,ar) : col;
            
            tex.xyz = mix(bg,tex.xyz,tex.a);
            
        }
        
        col = tex.xyz;
        
	} else if(scn.id == 1) {
	
		col = shadeFloor(scn,ray);
	
	}
    
	return col;

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

	vec2 uv = (fragCoord.xy - iResolution.xy / 2.) / iResolution.y;
	vec3 dir = vec3(uv, 1.);
	
    //vec2 m = iMouse.xy / iResolution.xy;
	//dir.yz = rot2D(dir.yz, 15. * m.y);
	//dir.xz = rot2D(dir.xz, m.x * 15.);
	
	vec3 scn = shade(Ray(vec3(1.,1.,1.),dir));
	fragColor = vec4(scn, 1.);

}