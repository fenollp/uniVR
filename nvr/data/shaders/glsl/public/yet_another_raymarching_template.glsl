// Shader downloaded from https://www.shadertoy.com/view/llf3zs
// written by shadertoy user elias
//
// Name: Yet Another Raymarching Template
// Description: .
// [x] Pointlights
// [x] Spotlights
// [x] Reflection
// [x] Materials
// [x] Soft shadows
// [ ] Antialiasing
// [ ] Transparency
// [ ] Ambient Occlusion

// Precision
#define P 0.001
// Steps
#define S 64
// Distance
#define D 15.
// Time in ms
#define T iGlobalTime
// Shadows softness
#define K 4.0
// Number of reflections
#define R 1
// Camera zoom
#define Z 1.0

#define PI 3.14159265359
#define TAU (PI*2.0)
#define PERSPECTIVE

/* ========================== */
/* ====== STRUCT SETUP ====== */
/* ========================== */

struct Ray
{
	vec3 o; // origin
	vec3 d; // direction
};
    
struct Camera
{
    vec3 p; // position
    vec3 t; // target
};
	
struct PointLight
{
	vec3 p; // position
	vec3 c; // color
};
    
struct SpotLight
{
	vec3  p; // position
	vec3  d; // direction
    vec3  c; // color
    float a; // angle
};

struct Hit
{
	vec3  p; // position
	float t; // distance traveled
	float d; // distance to object
};

struct Material
{
    vec3  c; // color
    float d; // diffuse
    float s; // specular
    float r; // reflection
};
    
// Some mobile devices can't handle constructors
// so we need to assign each value manually
Ray createRay(vec3 o, vec3 d)
{
    Ray r;
    r.o = o;
    r.d = d;
	return r;
}

Hit createHit(vec3 p, float t, float d)
{
    Hit h;
    h.p = p;
    h.t = t;
    h.d = d;
	return h;
}
    
PointLight createPointLight(vec3 p, vec3 c)
{
    PointLight pl;
    pl.p = p;
    pl.c = c;
    return pl;
}

Material createMaterial(vec3 c, float d, float s, float r)
{
    Material m;
    m.c = c;
    m.d = d;
    m.s = s;
	m.r = r;
    return m;
}

/* ========================= */
/* ====== SCENE SETUP ====== */
/* ========================= */

// Camera
Camera _cam;

// Distance to objects in scene
float _d, _d1, _d2;

// Lights and materials
const int  _numPointLights = 3;
const int  _numSpotLights  = 0;
const int  _numMaterials   = 2;

// Setup arrays
PointLight _pointLights [_numPointLights + 1];
SpotLight  _spotLights  [_numSpotLights  + 1];
Material   _materials   [_numMaterials   + 1];

// Forward declarations
Hit castRay(Camera,vec2);
vec3 getNormal(vec3);

/* ============================= */
/* ====== SCENE UTILITIES ====== */
/* ============================= */

// Rotation
mat3 rotZ(float a){float s=sin(a),c=cos(a);return mat3(c,-s,0,s,c,0,0,0,1);}
mat3 rotX(float a){float s=sin(a),c=cos(a);return mat3(1,0,0,0,c,s,0,-s,c);}
mat3 rotY(float a){float s=sin(a),c=cos(a);return mat3(c,0,-s,0,1,0,s,0,c);} 

// Distance functions
float udBox(vec3 p,vec3 s,float r){return length(max(abs(p)-s,0.))-r;}
float sdSphere(vec3 p,float r){return length(p)-r;}
float sdFloor(vec3 p,float h){return p.y-h;}
float sdCylinder(vec3 p,float r){return length(p.xz)-r;}

// Miscellaneous
vec3 repeat(vec3 p,vec3 s)
{
	return mod(p-s/2.,s)-s/2.;
}

// circular repeat
// r = radius (distance from center p)
// n = number of repetitions
// s = rotational shift
vec3 repeat(vec3 p, float r, float n, float s)
{
    float a = mod(s+atan(p.x,p.z),TAU/n)-PI/n;
    float l = length(p.xz);
    return vec3(l*cos(a)-r,p.y,l*sin(a));
}

/* ========================= */
/* ====== SCENE SETUP ====== */
/* ========================= */

void initialize()
{
    _cam.p = vec3(0,1.5,2)*rotY(-T*0.5);
    _cam.t = vec3(0,0,0);
    
    //Hit h = castRay(_cam,(2.*iMouse.xy-iResolution.xy)/iResolution.xx);
	//_spotLights[0] = SpotLight(_cam.p,normalize(h.p-_cam.p),vec3(1,0,0),PI/16.);
    
    float y = 1.0;

    _pointLights[0] = createPointLight(1.5*vec3(cos(TAU*1./3.-PI/6.),y,sin(TAU*1./3.-PI/6.)),vec3(0.8,1,0)*2.);    
    _pointLights[1] = createPointLight(1.5*vec3(cos(TAU*2./3.-PI/6.),y,sin(TAU*2./3.-PI/6.)),vec3(0,0.8,1)*2.);    
    _pointLights[2] = createPointLight(1.5*vec3(cos(TAU*3./3.-PI/6.),y,sin(TAU*3./3.-PI/6.)),vec3(1,0,0.8)*2.);    
    
    _materials[0] = createMaterial(vec3(1),1.0,1.0,0.0);
    _materials[1] = createMaterial(vec3(1),1.0,1.0,1.0);
}

float scene(vec3 p)
{
	_d = _d2 = 1e10;

	_d1 = sdFloor(p,-0.15);
    
    _d2 = min(_d2,udBox(repeat(p,1.,3.,0.),vec3(0.15),0.01));
    _d2 = min(_d2,sdSphere(repeat(p,1.,3.,PI/3.),0.15));
    _d2 = min(_d2,sdCylinder(repeat(p,1.,3.,0.),0.1));
       
	_d = min(_d,_d1);
	_d = min(_d,_d2);

	return _d;
}

Material getMaterial(Hit h)
{
    // floor
    if (_d == _d1) return _materials[0];
    // balls & pillars
    if (_d == _d2) return _materials[1];
    
    return _materials[0];
}

/* ====================== */
/* ====== MARCHING ====== */
/* ====================== */

Hit march(Ray r)
{
	float t = 0.0, d;

	for(int i = 0; i < S; i++)
	{
		d = scene(r.o + r.d*t);

		// Close enough or too far out
        if (d < P || t > D) { break; }

		t += d;
	}

	return createHit(r.o+r.d*t,t,d);
}

float getShadow(vec3 ro, vec3 rt)
{    
    vec3 rd = normalize(rt-ro);
    float tmax = length(rt-ro);
	float t = P*10.;
    float s = 1.0;
	
	for(int i = 0; i < S; i++)
	{
		float d = scene(ro+rd*t);

		// Direct occlusion -> no light
        if (d < P) { return 0.0; }
        
        // No occlusion or unreachable -> shadow
        if (t > tmax || t > D) { break; }

		s = min(s,K*d/t);
		t += d;
	}
	
	return s/tmax;
}

vec3 getColor(Hit h)
{
    vec3 col = vec3(0);
    float ref = 1.0;
    
    // Reflection loop
    for(int i = 0; i < 1+R; i++)
    {
        vec3 n = getNormal(h.p);
        vec3 c = vec3(0);
        Material m = getMaterial(h);

        // Calculate point light
        for(int j = 0; j < _numPointLights; j++)
        {
            PointLight l = _pointLights[j];
            vec3 ln = normalize(l.p-h.p);
            
            c += getShadow(h.p,l.p) * mix(l.c, m.c, 0.5) * (
                mix(1.,max(dot(ln,n),0.0),m.d) +
                m.s * pow(max(dot(reflect(-ln,n),normalize(_cam.p-h.p)),0.0),100.)
            )/length(h.p-l.p);
        }
        
        // Calculate spot light
        for(int j = 0; j < _numSpotLights; j++)
        {
            SpotLight l = _spotLights[j];
            vec3 ln = normalize(l.p-h.p);
            
            float mask = pow(l.a/max(acos(dot(l.d,normalize(h.p-l.p))),l.a),20.);

            c += getShadow(h.p,l.p) * mix(l.c, m.c, 0.5) * (
                m.d * max(dot(ln,n),0.0) +
                m.s * pow(max(dot(reflect(-ln,n),normalize(_cam.p-h.p)),0.0),100.)
            )/length(h.p-l.p) * mask;
        }
        
        // Mix reflection
        col = mix(col,c,ref);
        ref *= m.r;

        // Only continue if the current object is reflective
        if (m.r == 0.0) { break; }
        
        vec3 r = normalize(reflect(h.p-_cam.p,n));
        h = march(createRay(h.p+r*P*10.,r));
    }
    
	return clamp(col,0.,1.);
}

/* ================================ */
/* ====== MARCHING UTILITIES ====== */
/* ================================ */

vec3 getNormal(vec3 p)
{
	vec2 e = vec2(P,0);

	return normalize(vec3(
		scene(p+e.xyy)-scene(p-e.xyy),
		scene(p+e.yxy)-scene(p-e.yxy),
		scene(p+e.yyx)-scene(p-e.yyx)
	));
}

Ray lookAt(Camera cam, vec2 c)
{
	vec3 dir = normalize(cam.t-cam.p);
	vec3 right = normalize(cross(dir,vec3(0,1,0)));
	vec3 up = cross(right,dir);

    #ifdef PERSPECTIVE    
    return createRay(cam.p*Z,normalize(right*c.x+up*c.y+dir));
    #else
   	return createRay(cam.p+(right*c.x+up*c.y)*Z*2.0,dir);
    #endif
}

Hit castRay(Camera _cam, vec2 p)
{
	Ray ray = lookAt(_cam,p);
    Hit hit = march(ray);
    
    return hit;
}

/* ================== */
/* ====== MAIN ====== */
/* ================== */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    initialize();
    
    vec2 uv = (2.*fragCoord.xy-iResolution.xy)/iResolution.xx;
	fragColor = vec4(getColor(march(lookAt(_cam,uv))),1);
}