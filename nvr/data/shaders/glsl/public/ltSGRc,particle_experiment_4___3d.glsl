// Shader downloaded from https://www.shadertoy.com/view/ltSGRc
// written by shadertoy user aiekick
//
// Name: Particle Experiment 4 : 3D
// Description: Particle Experiment 1 in 3d
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// use mouse y to change pattern
// use mouse x to change camera distance

const vec2 RMPrec = vec2(0.5, 0.001); // ray marching tolerance precision // low, high
const vec2 DPrec = vec2(1e-5, 10.); // ray marching distance precision // low, high
    
float pattern = 3.; // pattern value 1. to 5. use mouse y to change

float kernelRadius = 4.5; // radius of kernel

float norPrec = 0.01; // normal precision 
  
#define mPi 3.14159
#define m2Pi 6.28318

float power = 0.8;
float duration = 2.8;
float startRadius = 0.1;
float endRadius = 0.5;
const int nBall = 30;

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

vec2 map(vec3 p)
{
    vec2 res = vec2(0.);
    
    float t = iGlobalTime;
        
    for (int i=0; i<nBall; i++)
    {
        float d = fract(t*power+48934.4238*sin(float(i)*692.7398))*duration;
    	
        vec3 a = m2Pi*float(i)/(float(nBall)/vec3(1.,2.,3.));
        
        vec3 o = vec3(cos(a.x),sin(a.y),sin(a.z))*d;
        
        float distRatio = d/duration;
        
        float mbRadius = mix(startRadius, endRadius, distRatio);
        
        float sp = length(p-o) - mbRadius;
        
        if (i==0) 
            res.x = sp;
        else 
            res.x = smin(res.x, sp, 1.);
    }
    
    return res;
}

vec3 nor(vec3 p, float prec)
{
    vec2 e = vec2(prec, 0.);
    
    vec3 n;
    
    n.x = map(p+e.xyy).x - map(p-e.xyy).x; 
    n.y = map(p+e.yxy).x - map(p-e.yxy).x; 
    n.z = map(p+e.yyx).x - map(p-e.yyx).x;  
    
    return normalize(n); 
}

vec4 scn(vec4 col, vec3 ro, vec3 rd)
{
    vec2 s = vec2(DPrec.x);
    float d = 0.;
    vec3 p = ro+rd*d;
    vec4 c = col;
    
    float b = 0.35;
    
    float t = 1.1*(sin(iGlobalTime*.3)*.5+.6);
    
    for(int i=0;i<200;i++)
    {
    	if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
        d += s.x*(s.x>DPrec.x?RMPrec.x:RMPrec.y);
        p = ro+rd*d;
    }
    
    if (s.x<DPrec.x)
    {
        vec3 n = nor(p, norPrec); 
      	vec3 cuberay = textureCube(iChannel0, n).rgb * 0.5;
        c.rgb = cuberay + pow(b, 25.);
    }
    else
    {
       	c = textureCube(iChannel0, rd);
    }
    
    return c;
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 org, float persp)
{
	vec3 rorg = normalize(org-ro);
    vec3 u =  normalize(cross(cu, rorg));
    vec3 v =  normalize(cross(rorg, u));
    vec3 rd = normalize(rorg + u*uv.x + v*uv.y);
    return rd;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 s = iResolution.xy;
    vec2 g = fragCoord.xy;
    vec2 uv = (2.*g-s)/s.y;
    vec2 m = iMouse.xy;
    
    float t = iGlobalTime*0.2;
    float ts = sin(t)*.5+.5;
    
    float axz = -t; // angle XZ
    float axy = .8; // angle XY
    float cd = 5.5;//*ts; // cam dist to scene origine
    
    if ( iMouse.z>0.) cd = 10. * m.x/s.x; // mouse x axis 
    if ( iMouse.z>0.) pattern = floor(6. * m.y/s.y); // mouse y axis 
    
    float ap = 1.; // angle de perspective
    vec3 cu = vec3(0.,1.,0.); // cam up 
    vec3 org = vec3(0., 0., 0.); // scn org
    vec3 ro = vec3(cos(axz),sin(axy),sin(axz))*cd; // cam org
    
    vec3 rd = cam(uv, ro, cu, org, ap);
    
    vec4 c = vec4(0.,0.,0.,1.); // col
    
    c = scn(c, ro, rd);//scene
    
    fragColor = c;
}
