// Shader downloaded from https://www.shadertoy.com/view/MlBGWm
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 21
// Description: the flower shader form iq used with the tech from my last sahder ( Ray Marching Experiement 20)
//    you can use mouse to control the cam
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const int REFLEXIONS_STEP = 1; // count iteration for reflexion ( my refraction system seems to be wrong )

const vec2 RMPrec = vec2(0.5, 0.1); // ray marching tolerance precision // low, high
const vec2 DPrec = vec2(0.00001, 50.); // ray marching distance precision // low, high
    
float sphereThick = 0.02; // thick of sphere plates
float texDisplace = 0.10; // displace factor for texture
float texZoom = 0.5; // zoom of texture
float boxThick = 0.3; // thick of each boxs
float boxCornerRadius = 0.02; // corner radius of each boxs
float baseRep = 0.63; // base thick for mod repeat pattern // must be > to boxThick*2.
float evoRep = 0.08; // evo thick factor mult to time and added to baseRep for animation
float sphereRadius = 6.; // radius of sphere before tex displace

float norPrec = 0.01; // normal precision 

const int RMStep = 150; // Ray Marching Iterations

#define mPi 3.14159
#define m2Pi 6.28318

// from my shader https://www.shadertoy.com/view/4ts3WN
// use the flower pattern form iq shader https://www.shadertoy.com/view/4dX3Rn
vec3 effect(vec2 v) 
{
   	vec2 p = v/3.;

    float a = atan(p.x,p.y);
    float r = length(p)*(0.8+0.2*sin(0.3*iGlobalTime));

    float w = cos(2.0*iGlobalTime+-r*2.0);
    float h = 0.5+0.5*cos(12.0*a-w*7.0+r*8.0+ 0.7*iGlobalTime);
    float d = 0.25+0.75*pow(h,1.0*r)*(0.7+0.3*w);

    float f = sqrt(1.0-r/d)*r*2.5;
    f *= 1.25+0.25*cos((12.0*a-w*7.0+r*8.0)/2.0);
    f *= 1.0 - 0.35*(0.5+0.5*sin(r*30.0))*(0.5+0.5*cos(12.0*a-w*7.0+r*8.0));
	
	vec3 col = vec3( f,
					 f-h*0.5+r*.2 + 0.35*h*(1.0-r),
                     f-h*r + 0.1*h*(1.0-r) );
    
	col = clamp( col, 0.0, 1.0 );
	
	vec3 bcol = mix( 0.5*vec3(0.8,0.9,1.0), vec3(1.0), 0.5+0.5*p.y );
	col = mix( col, bcol, smoothstep(-0.3,0.6,r-d) );
    
    return col;
}

vec2 uvMap(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / m2Pi;
    tex2DToSphere3D.y = 0.5 - asin(p.y) / mPi;
    return tex2DToSphere3D;
}

vec4 map(vec3 p)
{
    // time
    float t = sin(iGlobalTime*.2)*.5+.5;
    
    // tex displace
    //vec3 tex = texture2D(iChannel1, uvMap(p*texZoom)).rgb;
    vec3 tex = effect(p.xz*texZoom);
    float disp = dot(tex, vec3(texDisplace));
    
    //sphere
    float sphereOut = length(p) -sphereRadius - disp;
    float sphereIn = sphereOut + sphereThick;
    float sphere = max(-sphereIn, sphereOut);
    
    // rep with mod
    vec3 rep = vec3(baseRep + evoRep*t);
    p = mod(p, rep) - rep/2.;
    
    // cube set
    vec3 box = vec3(boxThick);
	float cubeSet = length(max(abs(p)-box,0.0))-boxCornerRadius;
        
    // intersection
    float inter = max(sphere, cubeSet);
    
    // col
    vec4 c = vec4(inter, tex);
       
    return c;
}

vec3 nor( in vec3 p, float prec)
{
	vec2 e = vec2( prec, 0.);
	vec3 n = vec3(
	    map(p+e.xyy).x - map(p-e.xyy).x,
	    map(p+e.yxy).x - map(p-e.yxy).x,
	    map(p+e.yyx).x - map(p-e.yyx).x );
	return normalize(n);
}

// from iq
float calcAO( in vec3 pos, in vec3 nor)
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime*0.2;
    float cam_a = t; // angle z
    
    float cam_e = 8.52*(sin(t)*.5+.5); // elevation
    float cam_d = 0.1; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.55; // light intensity
    float refl_i = .6; // reflexion intensity
    float refr_i = .6; // reflexion intensity
    float refr_a = .8; // reflexion intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
    vec2 scr = iResolution.xy;
	vec2 uv = (2.* fragCoord.xy - scr)/scr.y;
    
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
    
    for(int k=0;k<REFLEXIONS_STEP;k++)
    {
        for(int i=0;i<RMStep;i++)
        {      
            if(s<DPrec.x||s>DPrec.y) break;
            s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
            d += s;
            p = ro+rd*d;
        }

        if (d<DPrec.y)
        {
            vec3 n = nor(p, norPrec);

            b=li;

            ray = reflect(rd, n);
            cubeRay = textureCube(iChannel0, ray).rgb  * refl_i ;

            ray = refract(ray, n, refr_a);
            cubeRay += textureCube(iChannel0, ray).rgb  * refr_i ;

            float ratio = float(k)/float(REFLEXIONS_STEP);
            
            if ( k == 0 ) 
                col = cubeRay+pow(b,15.); 
            else 
                col = mix(col, cubeRay+pow(b,25./ratio), ratio*0.8);  
            
            // lighting        
            float occ = calcAO( p, n);
            vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
            float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
            float dif = clamp( dot( n, lig ), 0.0, 1.0 );
            float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
            float dom = smoothstep( -0.1, 0.1, cubeRay.y );
            float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
            float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);

            vec3 brdf = vec3(0.0);
            brdf += 1.0*dif*vec3(1.00,0.90,0.60);
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
            s = DPrec.x;
        }
        else if (k == 0)
        {
            col = textureCube(iChannel0, rd).rgb;
        }
    }
	fragColor.rgb = col;
}