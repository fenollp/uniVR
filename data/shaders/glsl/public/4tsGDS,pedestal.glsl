// Shader downloaded from https://www.shadertoy.com/view/4tsGDS
// written by shadertoy user Impossible
//
// Name: Pedestal
// Description: Reference:
//    iquilezles.org/www/articles/distfunctions/distfunctions.htm
//    paulbourke.net/geometry/sphericalh/
//    www.filmicworlds.com/2014/04/21/optimizing-ggx-shaders-with-dotlh/
//    Updated for VR!
#define EPS 0.02
#define PI 3.14159265359

vec2 toPolar( vec3 p, float r )
{
    vec2 polar;
    
    polar.x = acos(p.z/r);
    polar.y = atan(p.y,p.x);
    
    return polar;
}

float myPow(float v, float n)
{
    float result = 1.0;
    for(int i=0;i<16;i++)
    {
        if(i<int(n))
	        result*=v;
    }
    
    return result;
}

float EvalSH(float theta,float phi)
{
	float m[8];

	m[0] = mod(texture2D(iChannel2,vec2(0.0,0.0)).x * 8.,8.);
	m[1] = 5.;
	m[2] = 3.;
	m[3] = 2.;
	m[4] = 0.;
	m[5] = 1.;
	m[6] = 0.;
	m[7] = 0.;

   float r = 0.;

   r += myPow(sin(m[0]*phi),m[1]);
   r += myPow(cos(m[2]*phi),m[3]);
   r += myPow(sin(m[4]*theta),m[5]);
   r += myPow(cos(m[6]*theta),m[7]);

   return r;
}

float sdSH( vec3 p, float s )
{
  float r = length(p);
  vec2 angles = toPolar(p,r);
  return r - EvalSH(angles.y,angles.x);
}


vec3 shColor( vec3 p )
{
   vec3 col;
   float r = length(p);
   vec2 angles = toPolar(p,r);
   r = EvalSH(angles.y,angles.x);
   col.x = r * sin(angles.x) * cos(angles.y);
   col.y = r * cos(angles.x);
   col.z = r * sin(angles.x) * sin(angles.y); 
    
    return col;
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

mat3 rotateY(float angle)
{
    float cs = cos(angle);
    float sn = sin(angle);
    
    mat3 m;
    
    m[0] = vec3(cs,0.,-sn);
    m[1] = vec3(0.,1.,0.);
    m[2] = vec3(sn,0.,cs);

    
    return m;
}

mat3 rotateZ(float angle)
{
    float cs = cos(angle);
    float sn = sin(angle);
    
    mat3 m;
    
    m[0] = vec3(cs,-sn,0.);
    m[1] = vec3(sn,cs,0.);
    m[2] = vec3(0.,0.,1);

    
    return m;
}

mat3 rotateX(float angle)
{
    float cs = cos(angle);
    float sn = sin(angle);
    
    mat3 m;
    
    m[0] = vec3(1.,0.,0.);
    m[1] = vec3(0.,cs,-sn);
    m[2] = vec3(0.,sn,cs);

    
    return m;
}


float G1V(float dotNV, float k)
{
    return 1.0/(dotNV*(1.0-k)+k);
}


float GGXSpec( vec3 n, vec3 v, vec3 l, float roughness, float F0 )
{
	float alpha = roughness*roughness;

    vec3 h = normalize( n + l );
    
    float dotNL = max(0.,dot(n,l));
    float dotNV = max(0.,dot(n,v));
    float dotNH = max(0.,dot(n,h));
    float dotLH = max(0.,dot(l,h));
    
    float F, D, vis;
    
    float alphaSqr = alpha * alpha;
    float denom = dotNH * dotNH * (alphaSqr-1.0) + 1.0;
    D = alphaSqr/(PI * denom*denom);
    
    float dotLH5 = pow(1.0-dotLH,5.);
    F = F0 + (1.0-F0)*(dotLH5);
    
    float k = alpha/2.;
    vis = G1V(dotNL,k)*G1V(dotNV,k);
    
    float specular = dotNL * D *F *vis;
    
    return specular;
    
}

float map(vec3 p)
{        
    float rad = .1*sin(p.y*1.75) + ((p.y>-3.6)?smoothstep(-3.,-3.6,p.y)*0.35+2.95:2.4);
    float res = min(sdCappedCylinder(p+vec3(0.,6.,0.),vec2(rad,3.)),sdSH(p,1.));
     
    
    if(p.y<-3.4)
    {
  	  	for(int i=0;i<25;i++)
   		{
	    	float cs = cos(float(i)/12.0*PI);
   	    	float sn = sin(float(i)/12.0*PI); 

    		res = max(res,-sdCylinder(p+vec3(cs*(rad),0.,sn*(rad)),vec3(0.,.0,.2)));    
    	}
    }    
    return res;
}

vec3 normal(vec3 p)
{
    vec3 n;
    
    n.x = map(p + vec3(EPS,0.,0.)) - map(p-vec3(EPS,0.,0.));
    n.y = map(p + vec3(0.,EPS,0.)) - map(p-vec3(0.,EPS,0.));
    n.z = map(p + vec3(0.,0.,EPS)) - map(p-vec3(0.,0.,EPS));   
    
    return normalize(n);
}

float shadow( vec3 ro, vec3 rd )
{
    bool hit = false;
    vec3 p = ro + rd;
    float t = 0.;
    float k = 16.;
    float res = 1.;
    
    for( int i=0;i<32;i++)
    {
       float d = map(p);
        
        t+=d;
        res = min( res, k*d/t );
        
        if(d<EPS)
        {
            hit = true;
            res = 0.;
            break;
        }
        else if(t>15.)
        {
            hit = false;
            break;
        }
      
        p = ro + rd * t * 0.45;
    }
    
    return res;
}


void rayMarch()
{
    
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{    
    
    float cs = cos(mod(0.3*iGlobalTime,2.*PI));
    float sn = sin(mod(0.3*iGlobalTime,2.*PI));
    
    ro += vec3(cs*7.,2.,7.*sn);
    
    mat3 m = rotateX(15./180.*PI);
    mat3 m2 = rotateY(-mod(0.3*iGlobalTime,2.*PI)+PI*0.5);
    rd = m2*m*rd; 
    
    bool hit = false;
    
    vec3 p = ro + rd;
    
    float t = 0.;
    
    for( int i=0;i<256;i++)
    {
       float d = map(p);
        
        t+=d;
        if(d<EPS)
        {
            hit = true;
            break;
        }
        else if(t>200.)
        {
            hit = false;
            break;
        }
        p = ro + rd * t * 0.1;
    }
    
    float vignette = pow(1.-dot( fragCoord.xy / iResolution.xy - vec2(0.5,0.5), fragCoord.xy / iResolution.xy - vec2(0.5,0.5) ),3.);
    
    if (hit )
    {
        vec3 n = normal(p);
        float ndv = dot(n,-rd);
        float f0 = 0.15;
        float fresnel = f0 + (1.-f0)*pow(1.-ndv,5.); 
        vec3 l = m2*m*normalize(vec3(iMouse.x - iResolution.x/2.,iMouse.y - iResolution.y/2.,200.));
        float ndl = max(0.,dot(n,l));
        
        vec3 col = vec3(181./255.);
        
        vec4 spec = vec4(GGXSpec(n,rd,l,0.01,0.75));
        
		fragColor = pow(((spec+vec4( ndl * col.r, ndl * col.g, ndl * col.b,1.0))*shadow(p,l) + fresnel*textureCube(iChannel0,n))*vignette,vec4(1./2.2));
    }
    else
        fragColor = textureCube(iChannel1,rd)*vignette;    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 rd = vec3( ( fragCoord.xy / iResolution.xy  * 2.0) - 1.0, -1.0);
    rd.x *= iResolution.x/iResolution.y;
    
    rd = normalize(rd); 
    
	mainVR( fragColor, fragCoord, vec3(0,0,0), rd);
}