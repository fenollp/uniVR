// Shader downloaded from https://www.shadertoy.com/view/ldVGDz
// written by shadertoy user elias
//
// Name: Simple Klein Bottle
// Description: No 4D calculations involved. (lame, I know)
#define S 512  // Steps
#define P 0.01 // Precision
#define R 10.  // Marching substeps
#define D 10.  // Max distance

#define T iGlobalTime
#define PI 3.1415926
#define TAU (PI*2.0)

#define PERSPECTIVE

struct Ray { vec3 o, d; };
struct Camera { vec3 p, t; };
struct Hit { vec3 p; float t, d; };

Ray _ray;
Camera _cam = Camera(vec3(0,0,4), vec3(0,0,0));

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float scene(vec3 p)
{
    p.y = p.y*-1.0-0.5;
    
    float y = sin((1.-p.y)/3.*PI/2.); y *= y;
    
    vec3 s = vec3(1,-1,0);
    vec3 q = p+(1.-cos((1.-p.y)/3.*PI))*s.xzz;
    
    // tube (hollow and solid)
    float d1 = max(max(abs(length(q.xz)-0.5+0.25*y),q.y-1.0),-q.y-2.0);
    float d2 = max(max(length(q.xz)-0.5+0.25*y,q.y-1.0),-q.y-2.0);
    
    q = p-s.zxz;
    
    // top
    float d3 = max(abs(length(vec2(length(q.xz)-1.0,q.y))-0.5),-q.y);
    
    q = p;
    
    // middle
    float d4 = max(max(max(abs(length(q.xz)-1.5+1.25*y),q.y-1.0),-q.y-2.0),-d2);
    
    q = p+s.xxz*vec3(1,2,0);
    
    // bottom
    float d5 = max(abs(length(vec2(length(q.xy)-1.0,q.z))-0.25),q.y);

    return min(d1,min(d3,min(d4,d5)));
}

vec3 getNormal(vec3 p)
{
	vec2 e = vec2(P,0);
    
	return normalize(vec3(
		scene(p+e.xyy)-scene(p-e.xyy),
		scene(p+e.yxy)-scene(p-e.yxy),
		scene(p+e.yyx)-scene(p-e.yyx)
	));
}

Hit march(Ray r)
{
    float t = 0.0, d;
    
    for(int i = 0; i < S; i++)
    {
        d = scene(r.o+r.d*t);
        t += d/R;
        
        if (d < P || t > D) { break; }
    }
    
    return Hit(r.o+r.d*t, t, d);
}

Ray lookAt(Camera cam, vec2 uv)
{
    vec3 dir = normalize(cam.t-cam.p);
    vec3 right = normalize(cross(dir, vec3(0,1,0)));
    vec3 up = cross(right, dir);
	
    #ifdef PERSPECTIVE
    return Ray(cam.p,normalize(right*uv.x + up*uv.y + dir));
    #else
    return Ray(cam.p+4.*(right*uv.x + up*uv.y), dir);
    #endif
}

vec3 getColor(Hit h)
{
    if (h.d > P) { return vec3(0.9); }
    
    vec3 colt, colr;
    vec3 light = _cam.p;

    Hit _h = h;

    for(int i = 0; i < 4; i++)
    {
        vec3 n = getNormal(h.p);
        
        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(reflect(normalize(h.p-light),n),normalize(_cam.p-h.p)),0.0),100.);
        
        vec3 col = vec3(1)*diff+spec;
        colt = i == 0 ? col : mix(colt,col,0.5);
        
        // fresnel
        float r = 1.12;
        float f = r + (1. - r)*(1. - dot(normalize(h.p-_cam.p),n))*5.;

        colt = mix(colt,vec3(0,0.1,0.5),f);

        _ray.d = normalize(refract(h.p-_cam.p,n,1.5));
        _ray.o = h.p+_ray.d*P*10.0;
        
        h = march(_ray);
        
        if (h.d > P) { break; }
    }
    
    h = _h;
    
    for(int i = 0; i < 2; i++)
    {
        vec3 n = getNormal(h.p);
        
        _ray.d = normalize(reflect(h.p-_cam.p,n));
        _ray.o = h.p+_ray.d*P*10.0;
        
        h = march(_ray);

        if (h.d > P) { break; }

        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(normalize(reflect(h.p-_cam.p,n)),-normalize(h.p-light)),0.0),100.)*0.2;
		
        vec3 col = vec3(1)*diff+spec;
        colr = i == 0 ? col : mix(colr,col,0.5);
    }
    
    return colt+colr;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (2.0*fragCoord.xy-iResolution.xy)/iResolution.yy;
    vec2 uvm = (2.0*iMouse.xy-iResolution.xy)/iResolution.yy;
    
    if (iMouse.y < 10.) { uvm.y = -0.1; }
    if (iMouse.x < 10.) { uvm.x = 0.0; }
    
    _cam.p.yz *= rot(-uvm.y*PI);
    _cam.p.xz *= rot(uvm.x*PI);
    
    _ray = lookAt(_cam,uv);
    
    float f = 1.-length((2.0*fragCoord.xy-iResolution.xy)/iResolution.xy)*0.5;
    fragColor = vec4(getColor(march(_ray)), 1.0)*f;
}