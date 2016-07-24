// Shader downloaded from https://www.shadertoy.com/view/MtsSDs
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&deg;32
// Description: A Paint Ball ^^
//    mouse control the cam
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//#define INV_MODE

#define shape(p) length(p)-2.8


float dstepf = 0.0;
    
const vec2 RMPrec = vec2(.5, 0.001); 
const vec3 DPrec = vec3(0.005, 12., 1e-6); 

///////////////////////////////////
#define pattern sin(1.5)
#define t iGlobalTime
vec3 magicSplat(vec2 uv)
{
	float a = 0.;
	if (uv.x >= 0.) a = atan(uv.x, uv.y) * .275;
    if (uv.x < 0.) a =  3.14159 - atan(-uv.x, -uv.y) * 1.66;
    
	float t = mod(t, 10.)*5.;
	
    vec3 p = vec3(uv,a);
    
    // from dgreensp => https://www.shadertoy.com/view/4ljGDd
    p = 1. - abs(1. - mod(p, 2.));
    float lL = length(p), nL = lL, tot = 0., c = pattern;
    for (int i=0; i < 12; i++) 
	{
		p = abs(p)/(lL*lL) - c;
		nL = length(p);
		tot += abs(nL-lL);
		lL = nL;
    }
    
	float fc = tot + 1.;
	fc = 1.-smoothstep(fc, fc+0.001, t/dot(uv,uv));

	vec3 col;
    vec3 tex = vec3(1.); 
	vec3 splash = vec3(1.-fc)*vec3(.42, .02, .03);
   
#ifdef INV_MODE
    col = mix(splash, tex, (splash.r==0.?0.:1.));
#else
    col = mix(splash, tex, (splash.r==0.?1.:0.));   
#endif
    
    return col;
}

///////////////////////////////////
float sphereThick = 0.02; // thick of sphere plates
vec4 map(vec3 p)
{
    vec2 uv = p.xz;
    
    vec3 col = magicSplat(uv);
    
    dstepf += 0.005;

    float disp = dot(col,vec3(.05));     
    
    float sphereOut = shape(p);
    float sphereIn = sphereOut + sphereThick;
    float sphere = max(-sphereIn, sphereOut);
    
   	float dist = max(sphere, sphereOut + disp);
                                    
    return vec4(dist, col.rgb);
}

vec3 nor( vec3 pos, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
    map(pos+e.xyy).x - map(pos-e.xyy).x,
    map(pos+e.yxy).x - map(pos-e.yxy).x,
    map(pos+e.yyx).x - map(pos-e.yyx).x );
    return normalize(n);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

void mainImage( out vec4 f, in vec2 g )
{
    vec2 si = iResolution.xy;
   	float t = iGlobalTime;
    f = vec4(0.);
    float ca = t*.2; // angle z
    float ce = 2.; // elevation
    float cd = 3.; // distance to origin axis
   	if ( iMouse.z>0.) cd = iMouse.x/iResolution.x * 10. - 5.; // mouse x axis 
    if ( iMouse.z>0.) ce = iMouse.y/iResolution.y * 10. - 5.; // mouse y axis 
    vec3 cu=vec3(0,1,0);//Change camere up vector here
    vec3 cv=vec3(0,0,0); //Change camere view here
    float refl_i = .6; // reflexion intensity
    float refr_a = 1.2; // refraction angle
    float refr_i = .8; // refraction intensity
    float bii = 0.6; // bright init intensity
    vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 ro = vec3(sin(ca)*cd, ce+1., cos(ca)*cd); //
    vec3 rd = cam(uv, ro, cu, cv);
    float b = bii;
    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
    float s = DPrec.y;
    for(int i=0;i<200;i++)
    {      
		if(s<DPrec.x||s>DPrec.y) break;
        s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
        d.y = d.x;
        d.x += s;
        p = ro+rd*d.x;
   	}

    f += pow(b,15.);
    
    if (d.x<DPrec.y)
    {
    	float nPrec = 0.001;
        vec3 n = nor(p, nPrec);
        vec3 ray = reflect(rd, n);
        f += textureCube(iChannel0, ray) * refl_i; 
        f.rgb = mix( f.rgb, map(p).yzw,0.5);  
   	}
    else
    {
    	f = textureCube(iChannel0, rd);
    }
    
    f += dstepf;
}

