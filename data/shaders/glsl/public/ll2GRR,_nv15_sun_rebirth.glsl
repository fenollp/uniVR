// Shader downloaded from https://www.shadertoy.com/view/ll2GRR
// written by shadertoy user EvilRyu
//
// Name: [NV15]Sun Rebirth
// Description: This is how we recharge the sun.
// Created by EvilRyu 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// NVScene 2015 Shadertoy Hackathon



#define SPACE_SHIP 0.0
#define SUN 1.0


float type;  // space ship or sun
float mindist;

float smin(float a, float b, float k)
{
    float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}

void rotate_x(inout vec3 p, float a) 
{ 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a);
    p.y = c * q.y - s * q.z; 
     p.z = s * q.y + c * q.z; 
} 

void rotate_z(inout vec3 p, float a) 
{ 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a); 
    p.x = c * q.x - s * q.y; 
    p.y = s * q.x + c * q.y;
} 
 void rotate_y(inout vec3 p, float a)
{ 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a); 
    p.x = c * q.x + s * q.z; 
    p.z = -s * q.x + c * q.z;
} 

float cylinder(vec3 p, vec2 h)
{
    vec2 d = abs(vec2(length(p.xz) ,p.y)) - vec2(h.x, h.y);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sphere(vec3 p, float r) 
{
    return length(p)-r;
}

float propeller(vec3 p)
{
    rotate_y(p,0.7853);
    float d1=cylinder(vec3(p.x-0.15,p.y+0.15,p.z),vec2(0.03,0.08));
    p.xy=p.yx;
    float d2=cylinder(vec3(p.x+0.15,p.y+0.1,p.z),vec2(0.01,0.25));
    float d3=cylinder(vec3(p.x+0.15,p.y+0.12,p.z),vec2(0.02,0.15));
    return min(d1,min(d3,d2));
}

float propellers(vec3 p)
{
    vec3 z=p;
    z.xz=abs(z.xz);
    z.x-=0.25;
    z.y+=0.08;
    z.z-=0.25;
    
    float d=1e10;
    d=propeller(z);
    return d;
}

float gun(vec3 p)
{
    p.y-=0.12;
    return cylinder(p, vec2(0.007,0.35));
}

float spaceship(vec3 p)
{
    rotate_z(p,1.5708);
    rotate_y(p,iGlobalTime*0.2);
    p.y+=1.0;
    float d=1e10;
    float d1=cylinder(vec3(p.x,p.y,p.z),vec2(0.04,0.29));
    float d2=cylinder(vec3(p.x,p.y,p.z)+vec3(0.0,-0.1,0.0),vec2(0.07,0.09));
   
    
    float d3=propellers(p);
    float d4=gun(p);
    if(d>d1){d=d1;}
    if(d>d2){d=smin(d,d2,0.1);}
    if(d>d3){d=min(d,d3);}
    if(d>d4){d=smin(d,d4,0.1);}
    return d;
}

float dist_to_beam=1e10;
float beam(vec3 p)
{
    p.xy=p.yx;
   	
    return cylinder(p, vec2(0.01, 0.45));
}

float f(vec3 p)
{
    type=SUN;
    float d1=sphere(p-vec3(1.0,0.0,0.0), 0.8);
    float d2=spaceship(p+vec3(0.5,0.0,0.0));
    float d=1e10;
    if(d>d1){d=d1;type=SUN;}
    if(d>d2){d=d2;type=SPACE_SHIP;}
    
    float db=beam(p+vec3(0.24,0.0,0.0)); 
    if(dist_to_beam>db){dist_to_beam=db;}  
    
    return d;
}


vec3 calcnormal(vec3 p)
{ 
    vec3 e=vec3(0.001,0.0,0.0); 
    return normalize(vec3(f(p+e.xyy)-f(p-e.xyy), 
                      f(p+e.yxy)-f(p-e.yxy), 
                      f(p+e.yyx)-f(p-e.yyx))); 
}


float intersect( in vec3 ro, in vec3 rd)
{
    float t = 0.0;
    float h = 1.0;
    
    mindist=1e10;
   
    for( int i=0; i<48; i++ )
    {
        if( h<0.001 || t>20.0 ) continue;
        h = f(ro + rd*t);
        mindist=min(h,mindist);
        t += h;
    }
    
    if(t>20.0) t=-1.0;
    return t;
}

vec3 lighting(vec3 p,vec3 rd)
{
    vec3 n=calcnormal(p);
    vec3 col=vec3(0.0);
    vec3 l1_dir=normalize(vec3(1.0,0.0,0.0));
    vec3 l2_dir=normalize(vec3(0.0,0.0,1.0));
     
    if(type<SUN)   // space ship
    {
        float diff=max(0.0,dot(n,l1_dir));
        float diff2=max(0.0,dot(n,l2_dir));
        float spec = max(0.0, pow(clamp(dot(l1_dir, reflect(rd, n)), 0.0, 1.0), 8.0));
            
        col=0.8*(0.2*(3.0*diff+diff2+5.0*spec)*vec3(0.3,0.5,0.9))+0.2*3.0*diff*
             vec3(1.7, 0.62,0.0)*max(0.0,sin(iGlobalTime));
    }
    else    // sun
    {
        float diff=max(0.0,dot(n,l2_dir));
        col=diff*texture2D(iChannel0, vec2(p.x,p.y)*0.9+iGlobalTime*0.05).xxx*vec3(1.3, 0.6,0.2);
    }
    return col;
}

vec3 getbackground(vec3 p)
{
    vec3 col=texture2D(iChannel0, p.xy*0.5).xxx;
    col=pow(col,vec3(2.0));
    return col;
}

vec3 scene(vec3 ro, vec3 rd)
{
    float hit=intersect(ro,rd);
    vec3 pos;
    vec3 col=vec3(0.0);
    
    pos=ro+hit*rd;
    
    
    //col+=pow(max(1.0-dist_to_beam,0.0),100.0)*vec3(1.7,0.247, 0.0)*max(0.0,cos(iGlobalTime));
   
    // the fake beam
    col = mix(col, vec3(1.7, 0.2, 0.0), 
              pow((smoothstep(0.0, 0.05, pos.y+0.05) - smoothstep(0.05, 0.1, pos.y+0.05)) *
                  (smoothstep(-1.0,0.0,pos.x) - smoothstep(0.0, 1.0, pos.x)), 40.0)) *
          max(0.0, sin(iGlobalTime+1.0));
                                                                                          
    
    if(type>SPACE_SHIP)  // sun
    {
      col += pow(max(1.0 - mindist,0.0), 10.0)*
             (vec3(1.7, 0.6470, 0.0))*sin(iGlobalTime-0.5); // nagative color to dim the sun
      
    }
    
    if(hit>0.0)
    {
        col+=lighting(pos,rd);
        float t=mod(pos.x-iGlobalTime, 6.283185307); // match the cycle of sin
 
      	col += vec3(1.7, 0.2, 0.0)*
              pow(smoothstep(0.0, .3, t) * smoothstep(0.5, .3, t), 20.0)
             ;
    }
    else
    {
        col+=(0.3+2.7*max(0.0,sin(iGlobalTime)))*vec3(0.01,0.025,0.05)*getbackground(pos);
    }
    
    return max(col,vec3(0.0));
}


vec3 tracer(vec2 fragCoord) {
    float fov=3.0;
    vec3 col = vec3(0.0);
    vec2 p = 2.0*(fragCoord.xy)/iResolution.xy-1.0;
    p.x*=iResolution.x/iResolution.y;
    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.x == 0.0 && iMouse.y == 0.0) {
        m = vec2(iGlobalTime * 0.06 + 0.14,0.5);    
    }
    m = -1.0 + 2.0 * m;
    m *= vec2(4.0,-1.5);
    
    vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 ro=vec3(0.0,0.0,4.5);

    vec3 cf = normalize(ta-ro); 
    vec3 cs = normalize(cross(cf,vec3(0.0,1.0,0.0))); 
    vec3 cu = normalize(cross(cs,cf)); 
    vec3 rd = normalize(p.x*cs + p.y*cu + fov*cf);
        
    col=scene(ro,rd);
    return  col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec3 col = tracer(fragCoord);
    // post
    col=pow(clamp(col,0.0,1.0),vec3(0.45)); 
    col=col*0.6+0.4*col*col*(3.0-2.0*col);
    col=mix(col, vec3(dot(col, vec3(0.33))), -0.7); 
    col*=pow(20.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7); 
    fragColor = vec4( col, 1.0 );
}
