// Shader downloaded from https://www.shadertoy.com/view/4lB3Wm
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 19
// Description: Ray Marching Experiment 19
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const int REFLEXIONS_STEP = 1;

const vec2 RMPrec = vec2(0.3, 0.05); // ray marching tolerance precision // vec2(low, high)
const vec2 DPrec = vec2(0.001, 50.); // ray marching distance precision
    
vec2 uvMap(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / (2.*3.14159);
    tex2DToSphere3D.y = 0.5 - asin(p.y) / 3.14159;
    return tex2DToSphere3D;
}

vec4 map(vec3 p, inout vec3 uvt, float time)
{
    vec2 s = vec2(.2, 4.);
    
    vec3 c,k,j=vec3(0.1);
    
    c.x = (uvt.x * uvt.x - uvt.y * uvt.y + uvt.z * uvt.z);
    c.y = (uvt.y * uvt.x + uvt.x * uvt.y - uvt.z * uvt.z);
    c.z = (uvt.y * uvt.z - uvt.x * uvt.y - uvt.z * uvt.x);
    
    uvt = c;
    
    k.x = length(uvt)/dot(c.x,c.y);
    k.y = length(uvt)/dot(c.y,c.z);
    k.z = length(uvt)/dot(c.z,c.x);
    
    if ( k.x >= s.x && k.x <= s.y ) j.x = k.x;
    if ( k.y >= s.x && k.y <= s.y ) j.y = k.y;
    if ( k.z >= s.x && k.z <= s.y ) j.z = k.z;
        
    float dist = length(p) -6. + dot(length(j), 0.035);
    
    return vec4(dist, j);
}

vec3 nor( in vec3 p, float prec, vec3 uvt, float time)
{
	vec2 e = vec2( prec, 0.);
	vec3 n = vec3(
	    map(p+e.xyy, uvt, time).x - map(p-e.xyy, uvt, time).x,
	    map(p+e.yxy, uvt, time).x - map(p-e.yxy, uvt, time).x,
	    map(p+e.yyx, uvt, time).x - map(p-e.yyx, uvt, time).x );
	return normalize(n);
}

float calcAO( in vec3 pos, in vec3 nor , vec3 uvt, float time)
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos , uvt, time).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime*0.5;
    float cam_a = t; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 5.88; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.55; // light intensity
    float refl_i = .6; // reflexion intensity
    float bii = 0.35; // bright init intensity
    
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
    float s = DPrec.x;
    
    vec3 ray, cubeRay;
    
    vec3 uvt = vec3(p);
    vec2 seuil = vec2(0.2,6.5);
    
    float time = t;
    
    float julia = 0.;
    
    for(int k=0;k<REFLEXIONS_STEP;k++)
    {
        for(int i=0;i<500;i++)
        {      
            if(s<DPrec.x||s>DPrec.y) break;
            uvt = p;
            s = map(p, uvt, time).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
            d += s;
            p = ro+rd*d;
        }

        if (d<DPrec.y)
        {
            vec3 n = nor(p, 0.0001, uvt, time);

            b+=li;

            ray = reflect(rd, n);
            cubeRay = textureCube(iChannel0, ray).rgb  * refl_i ;

            float ratio = float(k)/float(REFLEXIONS_STEP);
            
            if ( k == 0 ) 
                col = cubeRay+pow(b,15.); 
            else 
                col = mix(col, cubeRay+pow(b,25./ratio), ratio*0.8);  
            
            // lighting        
            float occ = calcAO( p, n, uvt, time);
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

            col = mix(col, map(p, uvt, time).yzw, 0.5);
            
            ro = p;
            rd = ray;
            s = DPrec.x;
        }
        else if (k == 0)
        {
            col = textureCube(iChannel0, rd).rgb;
        }
    }
	fragColor.rgb = col;
}