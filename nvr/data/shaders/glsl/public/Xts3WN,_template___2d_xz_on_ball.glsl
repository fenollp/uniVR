// Shader downloaded from https://www.shadertoy.com/view/Xts3WN
// written by shadertoy user aiekick
//
// Name:  Template : 2d XZ on ball
// Description: 2D Effect displaced on ball
//    for exemple the 2d XZ displace of shader :
//     [2TC 15] Funky Tunnel at https://www.shadertoy.com/view/4tsGDN
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define USE_SPHERE_OR_BOX

const int REFLEXIONS_STEP = 1;
    
//////2D FUNC TO MODIFY////////////////////
vec3 effect(vec2 uv) 
{
    vec2 z = 8.*uv;
    float t = iGlobalTime, d = 1./dot(z,z);
   
    vec4 col =
        // color
        vec4(d*3.,.5,0,0)*
        // stripes
        sin(atan(z.y,z.x)*30.+d*99.+4.*t)*
        // rings
        sin(length(z*d)*20.+2.*t)*
        // depth
        max(dot(z,z)*.4-.4,0.);

    
    return col.rgb;
}

///////FRAMEWORK////////////////////////////////////
vec4 displacement(vec3 p)
{
    vec3 col = effect(p.xz);
    
    col = clamp(col, vec3(0), vec3(1.));
    
    float dist = dot(col,vec3(0.1)); 
    
    return vec4(dist,col);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 3.; // displace scale
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

vec3 calcNormal( in vec3 pos, float prec )
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
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
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float refr_a = 1.2; // refraction angle
    float refr_i = .8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.5; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
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
        for(int i=0;i<250;i++)
        {      
            if (s<prec||s>maxd) break;
            s = map(p).x*marchPrecision;
            d += s;
            p = ro+rd*d;
        }

        if (d<maxd)
        {
            vec2 e = vec2(-1., 1.)*0.005; 
            vec3 n = calcNormal(p, 0.01);

            b=li;

            ray = reflect(rd, n);
            cubeRay = textureCube(iChannel0, ray).rgb  * refl_i ;

            ray = refract(ray, n, refr_a);
            cubeRay += textureCube(iChannel0, ray).rgb * refr_i;

            float ratio = float(k)/float(REFLEXIONS_STEP);
            
            if ( k == 0 ) 
                col = cubeRay+pow(b,15.); 
            else 
                col = mix(col, cubeRay+pow(b,25./ratio), ratio*0.8);  
            
            // lighting        
            float occ = calcAO( p, n );
            vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
            float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
            float dif = clamp( dot( n, lig ), 0.0, 1.0 );
            float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
            float dom = smoothstep( -0.1, 0.1, cubeRay.y );
            float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
            float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);

            vec3 brdf = vec3(0.0);
            brdf += 1.20*dif*vec3(1.00,0.90,0.60);
            brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
            brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
            brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
            brdf += 0.02;
            col = col*brdf;

            col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );

            col = mix(col, map(p).yzw, 0.5);
            
            ro = p;
            rd = ray;
            s = prec;
        }
        else if (k == 0)
        {
            col = textureCube(iChannel0, rd).rgb;
        }
    }
	fragColor.rgb = col;
}