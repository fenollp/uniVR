// Shader downloaded from https://www.shadertoy.com/view/MdKGWz
// written by shadertoy user elias
//
// Name: Ice Cream
// Description: Yummy. Inspired by: https://www.shadertoy.com/view/ldy3WR
#define S 256   // Steps
#define P 0.001 // Precision
#define R 2.    // Marching substeps
#define D 20.   // Max distance
#define K 8.    // Shadow softness

#define T iGlobalTime
#define PI 3.1415926
#define TAU (PI*2.0)

struct Ray { vec3 o, d; };
struct Camera { vec3 p, t; };
struct Hit { vec3 p; float t, d; };

vec2 _uv;
bool _normalMarch = false;
Camera _cam = Camera(vec3(0,1,-2.5), vec3(0,0.2,0));
float _d, _chocolateBar, _dcone, _dcream;

mat3 rotX(float a){float c=cos(a),s=sin(a);return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotY(float a){float c=cos(a),s=sin(a);return mat3(c,0,-s,0,1,0,s,0,c);}
mat3 rotZ(float a){float c=cos(a),s=sin(a);return mat3(c,-s,0,s,c,0,0,0,1);}

// http://www.iquilezles.org/www/articles/smin/smin.htm
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float length(vec3 v,float e)
{
    v = pow(abs(v),vec3(e));
    return pow(v.x+v.y+v.z,1./e);
}
                                        
float sdLine(vec3 p, vec3 a, vec3 b, float r, float e)
{
    vec3 ab = b-a, ap = p-a;
    return length(ap-ab*clamp(dot(ap,ab)/dot(ab,ab),0.,1.),e)-r;
}

float scene(vec3 p)
{
    p *= rotY(-T);
    
    vec3 q = p;
    
    _d = 1e10;

	_dcone = max(
        sdLine(p,vec3(0),vec3(0,-2,0),0.3*(2.-abs(p.y))+0.05,2.0),
       -sdLine(p,vec3(0),vec3(0,-2,0),0.33*(2.-abs(p.y-0.3))+0.05,2.0)
    );

    if (_normalMarch == true) { q -= texture2D(iChannel0,p.xz).x*0.001; }
    _chocolateBar = sdLine(q,vec3(0,0,0),vec3(0,1.5,0.5),0.1,8.0);
    
    q = p; q.y -= 0.9;
    q *= rotX(max(q.y*0.5,0.0));
    
    if (_normalMarch == true) { q.y -= texture2D(iChannel0,p.xz).x*0.01; }
    
    _dcream = sdLine(q*rotY(q.y*TAU),vec3(0,0,0),vec3(0,1,0),0.45*(1.-q.y)+(1.-q.y*10.)*0.01,3.0);
	_dcream = smin(_dcream,_chocolateBar,0.05);
    
    _d = min(_d,_dcream);
    _d = min(_d,_dcone);
    _d = min(_d,_chocolateBar);
    
    return _d;
}

vec3 getNormal(vec3 p)
{
    _normalMarch = true;

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

    return Ray(cam.p, normalize(right*uv.x + up*uv.y + dir));
}

float getSSAO(Hit h) 
{    
	vec2 e = vec2(1./iResolution.x,0);	
	
	float d = pow(abs(
		(h.t-march(lookAt(_cam,_uv+e.xy)).t)+
		(h.t-march(lookAt(_cam,_uv-e.xy)).t)+
		(h.t-march(lookAt(_cam,_uv+e.yx)).t)+
		(h.t-march(lookAt(_cam,_uv-e.yx)).t)
	),2.);

	return clamp(1.-d*100.,0.,1.);
}

vec3 getColor(Hit h)
{
    if (h.d > P) { return vec3(0.5); }
    
    vec3 n = getNormal(h.p);
    vec3 col = vec3(0);
    vec3 light = _cam.p;

    if(_d == _dcream)
    {
        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(normalize(reflect(h.p-_cam.p,n)),n),0.0),50.);
        col = vec3(0.5+getSSAO(h)*0.5);
    }
    
    if (_d == _dcone)
    {
        h.p *= rotY(-T);
        
        float a = atan(h.p.x,h.p.z);
        float f = pow(abs(sin((a+h.p.y*2.)*9.)*sin((a-h.p.y*2.)*9.)),0.5)*max(ceil(dot(n,vec3(0,-1,0))),0.0);
        
        h.p -= n*f;
        
        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(normalize(reflect(h.p-_cam.p,n)),n),0.0),10.)*0.2;
        
        col = mix(vec3(190,128,57),vec3(252,199,106),f)/256.*diff+spec;
    }
    
    if (_d == _chocolateBar)
    {      
        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(normalize(reflect(h.p-_cam.p,n)),n),0.0),100.);
        
        col = vec3(0.4,0.2,0)*diff+spec;
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    _uv = (2.0*fragCoord.xy-iResolution.xy)/iResolution.yy;
    vec2 uvm = (2.0*iMouse.xy-iResolution.xy)/iResolution.yy;
    
    if (iMouse.y < 10.) { uvm.y =  0.1; }
    if (iMouse.x < 10.) { uvm.x = -0.45; }
    
    _cam.p *= rotX(-uvm.y)*rotY(uvm.x*PI);
    
    float f = 1.-length((2.0*fragCoord.xy-iResolution.xy)/iResolution.xy)*0.5;
    fragColor = vec4(getColor(march(lookAt(_cam,_uv))), 1.0)*f;
}