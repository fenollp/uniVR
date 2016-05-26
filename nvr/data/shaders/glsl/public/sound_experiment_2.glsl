// Shader downloaded from https://www.shadertoy.com/view/XtSSzm
// written by shadertoy user aiekick
//
// Name: Sound Experiment 2
// Description: based on my [url=https://www.shadertoy.com/view/MtsSDs]Ray Marching Experiment n&deg;32[/url] with the line 4 uncommented
//    not so beautifull as expected :)
//    mouse axis for controling the cam
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define INV_MODE

vec4 freqs;

float dstepf = 0.0;
    
const vec2 RMPrec = vec2(.5, 0.001); 
const vec3 DPrec = vec3(0.005, 12., 1e-6); 

///////////////////////////////////
#define pattern sin(1.5)
vec3 magicSplat(vec2 uv, float t)
{
	float a = 0.;
	if (uv.x >= 0.) a = atan(uv.x, uv.y) * .275;
    if (uv.x < 0.) a =  3.14159 - atan(-uv.x, -uv.y) * 1.66;
    
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
   
    col = mix(splash, tex, (splash.r==0.?0.:1.));

    return col;
}

///////////////////////////////////
float coque(vec3 p, float r, float disp, float ratio, float thick)
{ 
	float sp = length(p) - r;
    return max(max(-sp - thick, sp), 
    		sp + dot(magicSplat(p.xz, ratio),vec3(disp)));
}

vec2 map(vec3 p)
{
    vec2 res =vec2(0.);
    vec2 uv = p.xz;
    
    dstepf += 0.005;

    vec4 rad = vec4(3.,2.8,2.6,2.4);
    vec4 sp;
   	sp.x = coque(p, rad.x, 0.05, freqs.x * 20., 0.02);
    sp.y = coque(p, rad.y, 0.05, freqs.y * 15., 0.02);
    sp.z = coque(p, rad.z, 0.05, freqs.z * 11., 0.02);
    sp.w = coque(p, rad.w, 0.05, freqs.w * 7., 0.02);
                   
    res = vec2(sp.x, 1.);
    if (sp.y < res.x)
        res = vec2(sp.y, 2.);
    if (sp.z < res.x)
        res = vec2(sp.z, 3.);
    if (sp.w < res.x)
        res = vec2(sp.w, 4.);

    return res;
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
    // from CubeScape : https://www.shadertoy.com/view/Msl3Rr
    freqs.x = texture2D( iChannel1, vec2( 0.01, 0.25 ) ).x;
	freqs.y = texture2D( iChannel1, vec2( 0.07, 0.25 ) ).x;
	freqs.z = texture2D( iChannel1, vec2( 0.15, 0.25 ) ).x;
	freqs.w = texture2D( iChannel1, vec2( 0.30, 0.25 ) ).x;
    freqs = normalize(freqs);
    
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
    vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 ro = vec3(sin(ca)*cd, ce+1., cos(ca)*cd); //
    vec3 rd = cam(uv, ro, cu, cv);
    
    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
    vec2 s = vec2(DPrec.y);
    for(int i=0;i<200;i++)
    {      
		if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
        s.x*=(s.x>DPrec.x?RMPrec.x:RMPrec.y);
        d.y = d.x;
        d.x += s.x;
        p = ro+rd*d.x;
   	}

    f += pow(0.6,15.);
    
    if (d.x<DPrec.y)
    {
    	float nPrec = 0.001;
        vec3 n = nor(p, nPrec);
        vec3 ray = reflect(rd, n);
        f += textureCube(iChannel0, ray) * 0.6; 
        
        if (s.y < 1.5) f.rgb = mix(f.rgb, vec3(1,0,0), .5);
        else if (s.y < 2.5) f.rgb = mix(f.rgb, vec3(0,1,0), .5);
        else if (s.y < 3.5) f.rgb = mix(f.rgb, vec3(0,0,1), .5);
        else if (s.y < 4.5) f.rgb = mix(f.rgb, vec3(1,0,1), .5);
            
        //f.rgb = mix( f.rgb, map(p).yzw,0.5);  
   	}
    else
    {
    	f = textureCube(iChannel0, rd);
    }
    
    f += dstepf;
}

