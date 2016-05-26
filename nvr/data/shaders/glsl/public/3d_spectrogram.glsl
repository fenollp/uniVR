// Shader downloaded from https://www.shadertoy.com/view/ldc3Wf
// written by shadertoy user elias
//
// Name: 3D Spectrogram
// Description: Because why not.
#define P 0.005
#define S 128
#define Z 1.0
#define D 100.
#define R 1.0

struct Ray
{
	vec3 o;
    vec3 d;
};

struct Hit
{
    vec3 p;
    float t;
    float d;
};
    
struct Camera
{
    vec3 p;
    vec3 t;
};
    
float dfloor;
float dsound;
float dbox;
    
Camera cam = Camera(vec3(0,0.4,-1), vec3(0,0,0));

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat3 rotX(float a){float c=cos(a);float s=sin(a);return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotY(float a){float c=cos(a);float s=sin(a);return mat3(c,0,-s,0,1,0,s,0,c);}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float scene(vec3 p)
{
    dsound = 1e10;
        
    dsound = max(
        p.y-texture2D(iChannel0,(p.xz*R+1.0)/2.).x*0.1,
        sdBox(p,vec3(1./R,1,1./R))
    );
    
    dbox = max(sdBox(p,vec3(1./R+0.01,0.1,1./R+0.01))-0.01,-sdBox(p,vec3(1./R,1,1./R)));
    dfloor = p.y;
    
    return min(min(dsound,dbox),dfloor);
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
    float d = 1e10, t = 0.0;
    
    for(int i = 0; i < S; i++)
    {
        d = scene(r.o+r.d*t);
        t += d*0.4;
        if (d <= P || t > D) { break; }
    }
    
    Hit h;
    
    h.p = r.o+r.d*t;
    h.t = t;
    h.d = d;
    
    return h;
}


Ray lookAt(Camera cam)
{
    vec2 uv = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.xx;
    vec3 dir = normalize(cam.t-cam.p);
    vec3 right = normalize(cross(dir, vec3(0,1,0)));
    vec3 up = cross(right, dir);
 
    return Ray(cam.p*Z, normalize(right*uv.x + up*uv.y + dir));
}

vec3 getColor(Hit h)
{
    if (h.d > P) { return vec3(0); }
    
    vec3 col = vec3(1);
    vec3 light = vec3(0,1,0);
    vec3 n = getNormal(h.p);
    
    float d = 1e10;
    
    float diff = max(dot(n, normalize(light-h.p)),0.0);
    float fade = min(2./exp(log2(length(light-h.p))),1.0);
    float spec = pow(max(dot(reflect(normalize(h.p-light),n),normalize(cam.p)),0.0),100.0)*0.4;

    if (dsound<d)
    {
        vec4 h = texture2D(iChannel0,(h.p.xz*R+1.0)/2.);
        
        col = h.y == 1.0 ? vec3(0.1) : hsv2rgb(vec3(0.5+h.x*0.5,1,1));
        if (h.y == 0.0) { col = col*diff*fade+spec; }
        
        d = dsound;
    }
    
    if (dbox<d)   { col = vec3(0); d = dbox;   }
    if (dfloor<d) { col = vec3(diff*fade)*(0.5+texture2D(iChannel0,vec2(0)).x*0.5)*vec3(0.5,0.5,1); d = dfloor; }

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uvMouse = (iMouse.xy/iResolution.xy-0.5)*2.0;
    if (uvMouse.x < -0.95 && uvMouse.y < -0.95) { uvMouse=vec2(0,0); }
    cam.p *= rotX(-uvMouse.y)*rotY(uvMouse.x*6.281);
    
    fragColor = vec4(getColor(march(lookAt(cam))), 1.0);
}