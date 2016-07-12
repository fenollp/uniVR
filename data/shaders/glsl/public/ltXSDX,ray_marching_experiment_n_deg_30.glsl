// Shader downloaded from https://www.shadertoy.com/view/ltXSDX
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&deg;30
// Description: based on pattern from BeyondTheStatic shader [url=https://www.shadertoy.com/view/XlXSWf]Poincar&eacute; Disk[/url]  displaced on ball
//    Control Bump With mouse axis Y
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
based on pattern from BeyondTheStatic shader https://www.shadertoy.com/view/XlXSWf  displaced on ball
Control Bump With mouse axis Y
*/

float dstepf = 0.0;
    
const vec2 RMPrec = vec2(0.2, 0.05); 
const vec3 DPrec = vec3(1e-3, 12., 1e-8); 

vec2 Params; // y => Elevation

/////////////////////////////////////////////////////////////////////
// pattern based on BeyondTheStatic shader https://www.shadertoy.com/view/XlXSWf
const int N		= 7;	// number of polygon vertices
const int P		= 3;	// number of polygons meeting at a vertex
const int Iters	= 4;	// number of iterations
#define HALFPI	1.57079633
#define PI		3.14159265
#define TWOPI	6.28318531
float s, c;
#define rotate(p, a) mat2(c=cos(a), s=-sin(a), -s, c) * p
vec4 poincareGetStuff(int n_, int p_) {
    float n = PI / float(n_), p = PI / float(p_);
	vec2 r1 = vec2(cos(n), -sin(n));
    vec2 r2 = vec2(cos(p+n-HALFPI), -sin(p+n-HALFPI));
    float dist = (r1.x - (r2.x/r2.y) * r1.y);
    float rad = length(vec2(dist, 0.)-r1);
    float d2 = dist*dist - rad*rad;
    float s = (d2<0. ? 1. : sqrt(d2));
	return vec4(vec3(dist, rad, 1.)/s, float(d2<0.));
}
vec2 radialRepeat(vec2 p, vec2 o, int n) {return rotate(vec2(o.x, o.y), floor(atan(p.x, p.y)*(float(n)/TWOPI)+.5)/(float(n)/TWOPI));}
vec2 cInvert(vec2 p, vec2 o, float r) {return (p-o) * pow(r, 2.) / dot(p-o, p-o) + o;}
vec2 cInvertMirror(vec2 p, vec2 o, float r, float flip){return (length(p-o)<r ^^ flip==1. ? cInvert(p, o, r) : p);}
vec2 poincareCreateUVs(vec2 p, vec4 pI) {return cInvertMirror(p, radialRepeat(p, vec2(0., pI.x), N), pI.y, pI.w);}
////////////////////////////////////////////////////////////////////////////////
vec4 map(vec3 p)
{
    vec2 uv = p.xz/3.;
    
	////////////////////////////////////////////////////////////////////////////////
    // pattern based on BeyondTheStatic shader https://www.shadertoy.com/view/XlXSWf
    vec2 rot = vec2(sin(.3*iGlobalTime), cos(.3*iGlobalTime));
    uv = cInvert(uv, rot, 1.);
    uv = cInvert(uv+vec2(rot.y, -rot.x), rot, 1.);
    vec4 pI = poincareGetStuff(N, P);
    for(int i=0; i<Iters; i++)
        uv = poincareCreateUVs(uv, pI);
    float f = 1. - dot(uv, uv) / pow(pI.z, 2.);
    vec4 col = vec4(vec3(f)*vec3(1.7, 1.1, .8), 1.);
    ////////////////////////////////////////////////////////////////////////////////
    
    dstepf += 0.015;

    float disp = dot(col,vec4(Params.y));                            
    float dist = length(p) -2.5 - smoothstep(0., 1., disp);
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
    Params.y = (sin(t*.5)*.5+.5)*.1;
    if (iMouse.z>0.) Params = iMouse.xy / si * vec2(1., 0.15);
    f = vec4(0.);
    float ca = t*.2; // angle z
    float ce = 3.5; // elevation
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
    for(int i=0;i<200;i++)
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

