// Shader downloaded from https://www.shadertoy.com/view/MdSSDz
// written by shadertoy user elias
//
// Name: Sponge Nightmare
// Description: .
#define PRECISION 0.0001
#define DEPTH 10.0
#define STEPS 128
#define SCALE 2.0
#define OFFSET 0.3
#define ITERATIONS 20
#define PI 3.14159265359

float t = iGlobalTime*0.1;
vec3 eye;
vec3 light;

vec2 uv;
float map(vec3);
vec3 march(vec3 ro,vec3 rd);
bool hit = false;

mat3 rot(vec3 a){vec3 s=sin(a);vec3 c=cos(a);return mat3(c.y*c.z,c.y*-s.z,-s.y,s.x*s.y*c.z+c.x*s.z,s.x*s.y*-s.z+c.x*c.z,s.x*c.y,c.x*s.y*c.z+-s.x*s.z,c.x*s.y*-s.z-s.x*c.z,c.x*c.y);}
vec3 getNormal(vec3 p){vec2 e=vec2(PRECISION,0);return(normalize(vec3(map(p+e.xyy)-map(p-e.xyy),map(p+e.yxy)-map(p-e.yxy),map(p+e.yyx)-map(p-e.yyx))));}
vec3 lookAt(vec3 o,vec3 t){vec3 d=normalize(t-o),u=vec3(1),r=cross(u,d);return(normalize(r*uv.x+cross(d,r)*uv.y+d));}

float sdBox(vec3 p,vec3 b){vec3 d=abs(p)-b;return min(max(d.x,max(d.y,d.z)),0.0)+length(max(d,0.0));}

float map(vec3 p)
{  
    p = p * rot(vec3(0,0,sin(10.0*(p.z+t))));
    float s = 0.2; vec3 z;
    float sponge = sdBox(mod(p,s)-s/2.0,vec3(s));

    for(float i = 0.0; i < 4.0; i++)
    {  
        z = mod(p-s*3.0,s*2.0)-s;
        s /= 3.0;

        sponge = max(sponge,-sdBox(z,vec3(s+1.0,s,s)));
        sponge = max(sponge,-sdBox(z,vec3(s,s+1.0,s)));
        sponge = max(sponge,-sdBox(z,vec3(s,s,s+1.0)));
    }

    return sponge;
}

vec3 getColor(vec3 p)
{	
	vec3 n = getNormal(p);
	vec3 l = normalize(p-eye);
    
    float diff = max(dot(n,l),0.2);
    float dist = 0.1/length(p-eye);
    
    vec3 col = vec3(0);
  
    col += vec3(dist-diff);
    
    return col;
}

vec3 march(vec3 ro,vec3 rd)
{
    float t=0.0,d;
    
    for(int i=0;i<STEPS;i++)
    {
        d=map(ro+rd*t);
        if(d<PRECISION){hit=true;}
        if(hit==true||t>DEPTH){break;}
        t+=d*0.5;
    }
    
    return ro+rd*t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    uv = (2.0*fragCoord.xy-iResolution.xy)/iResolution.xx;
    eye = vec3(0,0,t);
    
	vec3 p = march(eye,lookAt(eye,vec3(0,0,t+0.5)));
	fragColor = vec4(getColor(p),1.0);
}