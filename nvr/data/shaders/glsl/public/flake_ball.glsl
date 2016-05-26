// Shader downloaded from https://www.shadertoy.com/view/MlX3Wj
// written by shadertoy user aiekick
//
// Name: Flake Ball
// Description: Flake Ball
//    mouse control
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// voronoi based on iq shader https://www.shadertoy.com/view/ldl3W8
    
#define displaceOffset 0.095
#define USE_SPHERE_OR_BOX

//////2D FUNC TO MODIFY////////////////////
#define m2pi 6.2831
vec3 effect(vec2 v) 
{
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
                col = vec3 (d, r);
        }
    }
     
    return col.xzz;
}

///////FRAMEWORK////////////////////////////////////
vec4 displacement(vec3 p)
{
    vec3 col = effect(p.xz); // p.xz
    
    float dist = dot(col, vec3(displaceOffset));
    
    dist = clamp(dist, 0., 1.);
    
    return vec4(dist,col*1.5);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 3.;
    float dist = 0.;
    
    float x = 6.;
    float z = 6.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    #ifdef USE_SPHERE_OR_BOX
        dist = osphere(p, +5.-y);
    #else    
        if ( p.y > 0. ) dist = obox(p, vec3(x,1.-y,z));
        else dist = obox(p, vec3(x,1.,z));
	#endif
    
    return vec4(dist, disp.yzw);
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.05, 0., 0. );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

///////////////////////////////////////////
float march(vec3 ro, vec3 rd, float rmPrec, float maxd)
{
    float s = rmPrec, so;
    float d = 0.;
    vec3 p  = ro;
    const int iter = 250;
    for(int i=0;i<iter;i++)
    {      
        if (s<rmPrec*d||s>maxd) break;
        s = map(p).x;
        d += abs(s) * 0.2;
        p = ro+rd*d;   
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.3;
    float cam_a = time; // angle z
    
    #ifdef USE_SPHERE_OR_BOX
        float cam_e = 5.52; // elevation
        float cam_d = 1.88; // distance to origin axis
   	#else
        float cam_e = 1.; // elevation
        float cam_d = 1.8; // distance to origin axis
    #endif
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.025; // ray marching precision
    float maxd = 10.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
     
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
    vec2 s = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy -s)/s.y;
        
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = march(ro, rd, prec, maxd);
    
    if (d<maxd)
    {
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);
        
       	// lighting        
        vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, reflRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( reflRay, lig ), 0.0, 1.0 ),16.0);
        
        vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
		brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00);
        brdf += 0.40*dom*vec3(0.50,0.70,1.00);
        brdf += 0.30*bac*vec3(0.25,0.25,0.25);
        brdf += 0.40*fre*vec3(1.00,1.00,1.00);
		brdf += 0.02;
		col = col*brdf;

    	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}