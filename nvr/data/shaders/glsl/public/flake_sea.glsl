// Shader downloaded from https://www.shadertoy.com/view/MtBGWh
// written by shadertoy user aiekick
//
// Name: Flake Sea
// Description: Flake Sea
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    
#define displaceOffset 0.085

const int REFLEXIONS_STEP = 2;

#define m2pi 6.2831
vec3 effect(vec2 uv) 
{
    vec2 v = uv;
    
   	vec2 c0 = vec2(30.,20.);
    vec2 c1 = vec2(10.,40.);
    
    vec2 n=floor(v);
    vec2 f=fract(v);
    
    vec3 col;col.x=10.;
    
    for( float j=-1.; j<=1.; j+=1. )
    {
        for( float i=-1.; i<=1.; i+=1. )
        {
            vec2 g = vec2( i, j);
            
            vec2 ng = n+g;
            float ng0 = dot(ng,c0);
            float ng1 = dot(ng,c1);
            vec2 ng01 = vec2(ng0,ng1);
            vec2 hash = fract(cos(ng01)*iGlobalTime*0.2);
            
            vec2 o=sin(m2pi*hash)*.5+.5;
            
            vec2 r=g+o-f;
            
            float d=dot(r,r);
            
            if( d < col.x ) 
                col = vec3(d,r);
        }
    }
     
    return col.xzz;
}

vec4 displacement(vec3 p)
{
    vec2 uv = vec2(atan(p.x,p.z),acos(p.y));
    
    vec3 col = effect(p.xz); // p.xz
    
    float dist = dot(col, vec3(displaceOffset));
    
    dist = clamp(dist, 0., 1.);
    
    return vec4(dist,col*1.5);
}

vec4 map(vec3 p)
{
   	float scale = 3.;
    float dist = 0.;
    
    float x = 10.;
    float z = 10.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    return vec4(p.y+y, disp.yzw);
}

vec3 calcNormal( in vec3 p )
{
	vec2 e = vec2( 0.02,0.);
	vec3 nor = vec3(
	    map(p+e.xyy).x - map(p-e.xyy).x,
	    map(p+e.yxy).x - map(p-e.yxy).x,
	    map(p+e.yyx).x - map(p-e.yyx).x );
	return normalize(nor);
}

vec3 envMap(vec3 ray)
{
    vec2 uv = ray.xz*100./ray.y;
    float t = iGlobalTime;
    float c0 = texture2D( iChannel0, 0.00015*uv +0.1+ 0.0043*t ).x;
    float c1 = 0.35*texture2D( iChannel0, 0.00015*2.0*uv + 0.0043*.5*t ).x;
    return vec3(c0,c1,0.);
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.3;
    float cam_a = 0.; // angle z
    
    float cam_e = 0.; // elevation
    float cam_d = 8.; // distance to origin axis
        
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 40.; // ray marching distance max
    float refl_i = 0.6; // reflexion intensity
    float refr_a = 0.5; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
     
    /////////////////////////////////////////////////////////
    //if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    //if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
    vec2 res = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy -res)/res.y;
        
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = 0.;
    vec3 p = ro+rd*d;
    float s = prec;
    
    vec3 ray, cubeRay;
    
    for(int k=0;k<REFLEXIONS_STEP;k++)
    {
        for(int i=0;i<20;i++)
        {      
            if (s<prec||s>maxd) break;
            s = map(p).x;
            d += s;
            p = ro+rd*d;   
        }

        if (d<maxd)
        {
            vec3 n = calcNormal(p);

            float ratio = float(k)/float(REFLEXIONS_STEP);
            
            b=li;

            ray = reflect(rd, n);
            cubeRay = envMap(ray) * refl_i;

            ray = refract(rd, n, refr_a);
            cubeRay += envMap(ray) * refr_i;

            // lighting        
            vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
            float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
            float dif = clamp( dot( n, lig ), 0.0, 1.0 );
            float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
            float dom = smoothstep( -0.1, 0.1, cubeRay.y );
            float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
            float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);

            vec3 brdf = vec3(0.0);
            brdf += 1.20*dif*vec3(1.00,0.90,0.60);
            brdf += 1.20*spe*vec3(1.00,0.90,0.60);
            brdf += 0.30*amb*vec3(0.50,0.70,1.00);
            brdf += 0.40*dom*vec3(0.50,0.70,1.00);
            brdf += 0.30*bac*vec3(0.25,0.25,0.25);
            brdf += 0.40*fre*vec3(1.00,1.00,1.00);
            
            k==0?col=map(p).yzw:col=mix(col,cubeRay+pow(b,25.),0.8*ratio);  

            col *= brdf;
            
            ro = p;
            rd = ray;
            s = prec;
        }
        else if (k == 0)
        {
            col = envMap(rd);
        }
    }
	fragColor.rgb = col;
}