// Shader downloaded from https://www.shadertoy.com/view/MtsSWM
// written by shadertoy user aiekick
//
// Name: RM Exp 29 Reduced (1308c)
// Description: based on [url=https://www.shadertoy.com/view/XlfXDM]Ray Marching Experiment 29[/url]
//    Im trying to reduce the code to &lt; 1000 chars
//    i can rename var and func name but the code may be un clear after that. so i search significant decrease
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define N normalize
#define TC(a) textureCube(iChannel0, a)

#define t iGlobalTime


float gl=0.; // glow

vec2 RMP = vec2(0.2, 0.05),// RM Precision L/H
    k,// k.x => ratio, k.y => Density
    si; 

vec3 DP = vec3(1e-3, 12., 1e-8); // Map Precision Test L/H/VL

vec4 map(vec3 p)
{
    gl += 1.5e-2;
            
    vec4 c = vec4(p,1);
    
    // pattern based on 104 shader https://www.shadertoy.com/view/ltlSW4 
    vec2 i = c.xz*k.y/c.y+t;
    i-=c.xy=ceil(i+=i.x*=.577);
    c.xy+=step(1.,c.z=mod(c.x+c.y,3.))-step(2.,c.z)*step(i,i.yx);
    c.z=0.;
    c=.5+.5*sin(c);     
    
    c.w = length(p) -4. + smoothstep(0., 1., dot(c,vec4(k.x))); // sphere + displace
    return c.wxyz;
}

// c = precision
vec3 nor( vec3 p, float c )
{
    vec2 e = vec2( c, 0. );
    return N(vec3(
    map(p+e.xyy).x - map(p-e.xyy).x,
    map(p+e.yxy).x - map(p-e.yxy).x,
    map(p+e.yyx).x - map(p-e.yyx).x ));
}

vec3 cam(vec2 uv, out vec3 ro)
{
    ro = vec3(sin(t*.2)*.5, 5.7, cos(t*.2)*.5);// pixel ray origine
	vec3 rov = N(-ro.xyz);
    vec3 u =  N(cross(vec3(0,1,0), rov));
    vec3 v =  N(cross(rov, u));
    return N(rov + u*uv.x + v*uv.y);
}

void mainImage( out vec4 f, in vec2 g )
{
    k = vec2(sin(t*.5)*.5+.5,10);
    
    vec3 ro, rd = cam((g+g-(si = iResolution.xy))/si.y, ro);// pixel ray direction
    
    vec3 d = ro*0.,n;// current // old // middle
    vec3 p = ro+rd*d;// surface point to pixel ray  
    vec3 s = vec3(DP.y, sign(map(p).x), 0.);// map result // ray march dir // count iter
    
    for(float i=0.;i<1.;i+=1e-3)
    {      
		if(s.x<DP.x||s.x>DP.y) break;
        d.y = d.x;
        p = ro+rd*(d.x += s.x = map(p).x*(s.x>DP.x?RMP.x:RMP.y));
        if (sign(s.x) != s.y) break;
   	}
    
    // remove artifacts
    if (sign(s.x) == s.y)
    {
    	s.y = sign(map(p).x);
        for (float i = 0.; i < 1.; i+=.05)
        {
        	s.z++;
            p = ro+rd*(d.z = (d.x + d.y)*.5);
           	d.x += s.x = abs(map(p).x*RMP.y);
            if (s.x < DP.z) break;
            (d.x * s.y < 0. )? (d.x = d.z ): (d.y = d.z);
       	}
        d.x = (d.x + d.y) * .5;
   	}
    
    f = gl * 
        (
        	d.x<DP.y
        	?(TC(reflect(rd, nor(p, 1./s.z))) * .6 + map(p).yzww) * .5
        	:TC(rd.xyz)
    	);
}

