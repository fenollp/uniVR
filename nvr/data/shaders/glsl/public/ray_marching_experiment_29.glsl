// Shader downloaded from https://www.shadertoy.com/view/XlfXDM
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 29
// Description: based on pattern from 104 shader https://www.shadertoy.com/view/ltlSW4  displaced on ball
//    you can comment line 4 il you want unlimited dispalce from 0 to 1.
//    Mouse Axis X =&gt; Grow Up/Down // Mouse Axis Y =&gt; Density from 0 to 100.
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define limited_displace

float dstepf = 0.0;
    
const vec2 RMPrec = vec2(0.2, 0.05); 
const vec3 DPrec = vec3(1e-3, 12., 1e-8); 

vec2 Params; // x => ratio, y => Density

vec4 map(vec3 p)
{
	// pattern based on 104 shader https://www.shadertoy.com/view/ltlSW4 
    vec4 col = vec4(p,1);
    vec2 i = col.xz*Params.y;
    i=i/col.y+iGlobalTime;
    i-=col.xy=ceil(i+=i.x*=.577);
    col.xy+=step(1.,col.z=mod(col.x+col.y,3.))-step(2.,col.z)*step(i,i.yx);
    col.z=0.;
    col=.5+.5*sin(col);
    
    dstepf += 0.015;

    float disp;
    
    #ifdef limited_displace
    	disp = dot(col.rgb,vec3(Params.x));
    #else
    	disp = dot(col,vec4(Params.x));
    #endif               
                         
    float dist = length(p) -4. + smoothstep(0., 1., disp);
    
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
    Params.x = sin(t*.5)*.5+.5;
    Params.y = 10.;
    if (iMouse.z>0.) Params = iMouse.xy / si * vec2(1., 100.);
    f = vec4(0.);
    float ca = t*.2; // angle z
    float ce = 4.7; // elevation
    float cd = 0.5; // distance to origin axis
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
    float rmd = sign(map(p).x);
    for(int i=0;i<1000;i++)
    {      
		if(s<DPrec.x||s>DPrec.y) break;
        s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
        if (sign(s) != rmd) break;
        d.y = d.x;
        d.x += s;
        p = ro+rd*d.x;
   	}

    float countIter = 0.;
    if (sign(s) == rmd)
    {
    	p = ro+rd*d.x;
        rmd = map(p).x;
        for (int i = 0; i < 20; i++)
        {
        	countIter += 10.;
            d.z = (d.x + d.y)*.5;
            p = ro+rd*d.z;
            s = map(p).x*RMPrec.y;
            d.x += abs(s);
            if (abs(s) < DPrec.z)break;
            (d.x*rmd < 0. )? (d.x = d.z ): (d.y = d.z);
       	}
        d.x = (d.x+d.y) * .5;
   	}

    f += pow(b,15.);
    
    if (d.x<DPrec.y)
    {
    	float nPrec = 10./countIter;
        vec3 n = nor(p, nPrec);
        vec3 ray = reflect(rd, n);
        f += textureCube(iChannel0, ray) * refl_i; 
        ray = refract(rd, n, refr_a);
        f += textureCube(iChannel0, rd) * refr_i; 
        f.rgb = mix( f.rgb, map(p).yzw,0.5);                
   	}
    else
    {
    	f = textureCube(iChannel0, rd);
    }

    f *= dstepf;
}

