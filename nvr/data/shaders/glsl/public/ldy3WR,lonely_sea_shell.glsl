// Shader downloaded from https://www.shadertoy.com/view/ldy3WR
// written by shadertoy user elias
//
// Name: Lonely Sea Shell
// Description: Perhaps it wouldn't be as lonely if the developer were less lazy about adding more creatures. (also missing: light rays and water particles)
//    This was going to be something completely different but somehow I got carried away with those spirals.
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

//bool _ignoreParticles = false;
bool _shadowMarch = false;
bool _normalMarch = false;

const vec3 _fog = vec3(0,0,0.2);
Camera _cam = Camera(vec3(0,1,-2), vec3(0,0.5,0));
float _d, _dfloor, _dshell, _dparticles;

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
                                        
float sdLine(vec3 p, vec3 a, vec3 b, float r)
{
    vec3 ab = b-a, ap = p-a;
    return length(ap-ab*clamp(dot(ap,ab)/dot(ab,ab),0.,1.),4.0)-r;
}

float scene(vec3 p)
{
    _d = _dfloor = 1e10;
    
    if (_shadowMarch == false)
    {
    	_dfloor = p.y+texture2D(iChannel1,p.xz*0.1).x*0.3;    
    }
   
    if(_normalMarch == true)
    {
        p.y -= texture2D(iChannel0,p.xz).x*0.01;
    }
    
    p *= rotX(0.5);
    
    float dshell = sdLine(p*rotY(p.y*TAU),vec3(0,0,0),vec3(0,1,0),0.5*(1.-p.y));
    
    _dfloor = smin(_dfloor,dshell,0.12);
    _dshell = dshell;
    //_dparticles = 1e10;

    _d = min(_d,_dfloor);
    _d = min(_d,_dshell);
    //_d = min(_d,_dparticles);
    
    
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

float getShadow(vec3 source, vec3 target)
{
    _shadowMarch = true;
  
	float t = 0.05;
    float s = 1.0;
    float r = length(target-source);
    
	vec3 dir = normalize(target-source);
	
	for(int i = 0; i < S; i++)
	{
		float d = scene(source+dir*t);
        
        if (d < P) { return 0.0; }
        if (t > r) { break; }
        
        s = min(s,K*d/t);
        t += d/R;
	}
	
	return s/exp(r*0.1);
}

Ray lookAt(Camera cam, vec2 uv)
{
    vec3 dir = normalize(cam.t-cam.p);
    vec3 right = normalize(cross(dir, vec3(0,1,0)));
    vec3 up = cross(right, dir);

    return Ray(cam.p, normalize(right*uv.x + up*uv.y + dir));
}

vec3 getColor(Hit h)
{
    if (h.d > P) { return _fog; }
    
    vec3 n = getNormal(h.p);
    vec3 col = vec3(0);
    vec3 light = vec3(0,3,0);
    
    
    if(_d == _dfloor)
    {
        float diff = max(dot(normalize(light-h.p),n),0.0);
        col = vec3(diff);
    }
    
    if(_d == _dshell)
    {
        float diff = max(dot(normalize(light-h.p),n),0.0);
        float spec = pow(max(dot(normalize(reflect(h.p-_cam.p,n)),n),0.0),50.);
        col = texture2D(iChannel0,h.p.xz).rgb*diff+spec;
    }
    
    //if(_d == _dparticles)
    //{
    //    col = vec3(0);
    //}
    
    col *= getShadow(h.p,light);
    col += texture2D(iChannel0,h.p.xz*0.01+vec2(-T*0.003)).x*0.5;
    
    return mix(col,_fog,h.t/D);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.yy;
    vec2 uvm = (2.0*iMouse.xy-iResolution.xy)/iResolution.yy;
    
    if (iMouse.y < 10.) { uvm.y = -0.3; }
    if (iMouse.x < 10.) { uvm.x = -0.5; }
    
    _cam.p *= rotX(-uvm.y)*rotY(uvm.x*PI);
    
    fragColor = vec4(getColor(march(lookAt(_cam,uv))), 1.0);
}