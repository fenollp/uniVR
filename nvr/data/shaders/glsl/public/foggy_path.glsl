// Shader downloaded from https://www.shadertoy.com/view/ldG3Rd
// written by shadertoy user jackdavenport
//
// Name: Foggy Path
// Description: A creepy, foggy pathway!
#define MAX_ITERATIONS 128
#define MIN_DISTANCE  .001

#define MOON_COLOR vec3(.2,.2,.3)
#define MOON_DIR normalize(vec3(35.,30.,25.))

struct Ray { vec3 ori; vec3 dir; };
struct Dst { float dst; int id;  };
struct Hit { vec3 p; int id;     };
    
// Source: http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 co) {
    
    return fract(sin(dot(co.xy,vec2(12.9898,78.233)))*43758.5453);

}
    
Dst dstLightpole(vec3 p, vec3 pos) {
    
    float rep = 4.;
    p.z = mod(p.z, rep) - rep * .5;
    
    vec3 r = pos - p;
    vec2 d = abs(vec2(length(r.xz),r.y)) - vec2(.1,.75);
 	float dst = min(max(d.x,d.y),0.0) + length(max(d,0.0));
    
    vec2 q = vec2( length(r.xz), r.y + .6 );
    vec3 c = vec3(.4,.4,.3);
    vec2 v = vec2( c.z*c.y/c.x, -c.z );
    vec2 w = v - q;
    vec2 vv = vec2( dot(v,v), v.x*v.x );
    vec2 qv = vec2( dot(v,w), v.x*w.x );
    d = max(qv,0.0)*qv/vv;
   	dst = min(sqrt( dot(w,w) - max(d.x,d.y) )* sign(max(q.y*v.x-q.x*v.y,w.y)), dst);
    
    return Dst(dst, 0);
    
}

Dst dstGround(vec3 p, float y, bool shadow) {
 
    if(!shadow) y += texture2D(iChannel0, mod(p.xz,1.)).r * .005;
    return Dst(p.y - y, 1);
    
}

Dst minDst(Dst a, Dst b) {
 
    if(a.dst < b.dst) return a;
    return b;
    
}

Dst dstScene(vec3 p, bool shadow) {
 
    Dst dst = dstLightpole(p, vec3(1.3,-.25,.5));
    dst = minDst(dst, dstLightpole(p, vec3(-1.3,-.25,.5)));
    dst = minDst(dst, dstGround(p, -1., shadow));
    
    return dst;
    
}
    
Hit raymarch(Ray ray, bool shadow) {
 
    vec3 p = ray.ori;
    int id = -1;
    
    for(int i = 0; i < MAX_ITERATIONS; i++) {
     
        Dst scn = dstScene(p, shadow);
        p += ray.dir * scn.dst * .75;
        
        if(scn.dst < MIN_DISTANCE) {
         
            id = scn.id;
            break;
            
        }
        
    }
    
    return Hit(p,id);
    
}

vec3 calcNormal(vec3 p) {
 
    vec2 eps = vec2(.001,0.);
    vec3   n = vec3(dstScene(p + eps.xyy,false).dst - dstScene(p - eps.xyy,false).dst,
                    dstScene(p + eps.yxy,false).dst - dstScene(p - eps.yxy,false).dst,
                    dstScene(p + eps.yyx,false).dst - dstScene(p - eps.yyx,false).dst);
    return normalize(n);
    
}

bool inShadow(vec3 p) {
 
    Ray sr = Ray(p + MOON_DIR * .005, MOON_DIR);
    Hit sh = raymarch(sr, true);
    return sh.id != -1;
    
}

vec3 calcLighting(Hit scn, vec3 n, bool s) {
 
    float d = max(dot(MOON_DIR,n), 0.);
    if(s) d = 0.;
    
    return MOON_COLOR * d;
    
}

vec3 calcSpecular(vec3 r, float shininess, bool s) {
 
    float f = max(pow(dot(r,MOON_DIR),shininess),0.);
    if(s) f = 0.;
    
    return MOON_COLOR * f;
    
}

float getFog(Ray ray, vec3 p) {
 
    float dst = distance(ray.ori, p);
    return smoothstep(1., 15., dst);
    
}

vec3 shadeGround(Ray ray, Hit scn) {
 
    bool s = inShadow(scn.p);
        
    vec2 uv = mod(scn.p.xz, 1.);
    vec3  n = calcNormal(scn.p);
    vec3  l = calcLighting(scn, n, s);
        
    vec3 tx = texture2D(iChannel0, uv).xyz * vec3(0.,1.,0.);
    if(scn.p.x > -1. && scn.p.x < 1.) tx = texture2D(iChannel0, uv).xyz * vec3(.34,.23,.05);
        
    tx *= l;
    tx += calcSpecular(reflect(ray.dir,n), 5., s);
    
    return tx;
    
}

vec3 shade(Ray ray) {
    
    Hit scn  = raymarch(ray, false);
    vec3 col = vec3(0.);
    
    float fog = getFog(ray,scn.p);
    if(fog == 1.) return MOON_COLOR;
    
    if(scn.id == 0) {
    
        bool s = inShadow(scn.p);
        
        vec3 n = calcNormal(scn.p);
        vec3 l = calcLighting(scn, n, s);
        vec3 r = reflect(ray.dir, n);
        
        col = vec3(.5) * l;
        
        Ray rr  = Ray(scn.p + r * .01, r);
        Hit rh  = raymarch(rr, true);
        vec3 rc = rh.id == 1 ? shadeGround(rr,rh) : mix(col,MOON_COLOR,getFog(rr,rh.p));
        
        float fresnel = mix(.2,.9, max(dot(ray.dir,n), 0.));
        col = mix(col, rc, fresnel);
        
        col += calcSpecular(r, 90., s);
        
	} else if(scn.id == 1) {
     
        col = shadeGround(ray, scn);
        
    }
    
    col = mix(col, MOON_COLOR, fog);
    return col;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord - iResolution.xy * .5) / iResolution.y;
    
    vec2 m = (iMouse.xy / iResolution.xy) * 2. - 1.;
    if(iMouse.xy == vec2(0.)) m = vec2(0.);
    
    vec3 ori = vec3(m.x * .3,m.y * .4,-3. + (iGlobalTime * .2));
    vec3 dir = vec3(uv, 1.);
    
    vec3 col = shade(Ray(ori,dir));
	fragColor = vec4(col,1.);
}