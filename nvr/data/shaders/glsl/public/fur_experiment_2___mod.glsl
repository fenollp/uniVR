// Shader downloaded from https://www.shadertoy.com/view/MlSGDW
// written by shadertoy user aiekick
//
// Name: Fur Experiment 2 : mod
// Description: Fur Experiment 2
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const int REFLEXIONS_STEP = 1;
const vec2 RMPrec = vec2(0.1, 0.03); // ray marching tolerance precision // vec2(low, high)
const vec2 DPrec = vec2(0.01, 0.0001); // ray marching distance precision
    
vec3 effect(vec2 uv, float d) 
{
    float t = sin(iGlobalTime)*.5+.5;
    
    float z = 0.1;
    
    vec2 bricks = vec2(200.);
    
    d = clamp(0., 1., d)*0.01;
    
    uv*=10.;
    
    vec2 mp = vec2(z);
    float r = .02*d;
    
    vec2 wx = mod(uv, mp) -mp/2.;
    
    vec2 tt = (floor(uv/mp)+mp)*2.;
    
    if (abs(tt.x) < bricks.x ) uv.x = wx.x;
    if (abs(tt.y) < bricks.y ) uv.y = wx.y;
    
	return vec3(r/dot(uv,uv));
}

vec4 displacement(vec3 p, float d)
{
    // uv mapping
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / (2.*3.14159);
    tex2DToSphere3D.y = 0.5 - asin(p.y) / 3.14159;
            
    vec3 col = effect(tex2DToSphere3D, d);
    col = clamp(col, vec3(0), vec3(1.));
    float dist = dot(col,vec3(0.3));
    return vec4(dist,col);
}

vec4 map(vec3 p, float d)
{
    vec4 disp = displacement(p, d);
    float dist = length(p) - 3.5 - disp.x;
    return vec4(dist, disp.yzw);
}

vec3 nor( in vec3 p, float prec , float d)
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
	    map(p+e.xyy,d).x - map(p-e.xyy,d).x,
	    map(p+e.yxy,d).x - map(p-e.yxy,d).x,
	    map(p+e.yyx,d).x - map(p-e.yyx,d).x );
	return normalize(n);
}

float calcAO( in vec3 pos, in vec3 nor , float d)
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aop =  nor * hr + pos;
        float dd = map( aop ,d).x;
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
    
    float cam_e = 0.; // elevation
    float cam_d = 6.88; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float maxd = 50.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float refr_a = 0.2; // refraction angle
    float refr_i = .4; // refraction intensity
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
    
    float yOffset = length(p);
    
    vec3 ray, cubeRay;
    
    for(int k=0;k<REFLEXIONS_STEP;k++)
    {
        for(int i=0;i<500;i++)
        {      
            if(s<DPrec.y||s>maxd) break;
            s = map(p, yOffset).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
            d+=s;
            yOffset = length(p);
            p=ro+rd*d;
        }

        if (d<maxd)
        {
            vec2 e = vec2(-1., 1.)*0.005; 
            vec3 n = nor(p, 0.1, yOffset);

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
            float occ = calcAO( p, n , yOffset);
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

            col = mix(col, map(p, yOffset).yzw, 0.5);
            
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