// Shader downloaded from https://www.shadertoy.com/view/XtlSzS
// written by shadertoy user aiekick
//
// Name: Curiosity Ball
// Description: raytracing
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
float gl = 0.;
float t = 0.;
vec2 k;

vec4 pattern(vec3 p)
{
    gl += 1.5e-2;
            
    vec4 c = vec4(p,1);
    
    // pattern based on 104 shader https://www.shadertoy.com/view/ltlSW4 
    vec2 i = c.xz*k.y/c.y;
    i-=c.xy=ceil(i+=i.x*=.577);
    c.xy+=step(1.,c.z=mod(c.x+c.y,3.))-step(2.,c.z)*step(i,i.yx);
    c.z=0.;
    c=.5+.5*sin(c);     
    
    c.w = smoothstep(0., 1., dot(c,vec4(k.x))); // sphere + displace
    return c.wxyz;// dist, col
}

vec3 sphNormal( in vec3 pos, in vec4 sph )
{
	return normalize(pos-sph.xyz);
}

float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	return -b - sqrt( h );
}

float dist = 1.5;
vec3 cam(vec2 uv, out vec3 ro, float t)
{
	ro = vec3(sin(t*.2)*dist, 0.5, cos(t*.2)*dist);// pixel ray origine
	vec3 rov = normalize(-ro.xyz);
    vec3 u =  normalize(cross(vec3(0,1,0), rov));
    vec3 v =  normalize(cross(rov, u));
    return normalize(rov + u*uv.x + v*uv.y);
}


void mainImage( out vec4 f, in vec2 g )
{
	vec2 si = iResolution.xy;
	vec2 uv = (g+g-si)/si.y;
    vec4 col = vec4(0);
	
	t = iGlobalTime;
	k = vec2(sin(t*.5)*.3+.4,10);
	
	vec3 ro, rd = cam(uv, ro, t);
	
	vec4 sph0 = vec4(0,0,0,1.);
	float d = 0.0;
	vec3 p =ro+rd*d;
	vec3 n;
	
	d = sphIntersect(ro, rd, sph0);
	p = ro+rd*d;
	d /= pattern(p).x;
	p = ro+rd*d;
	
	if( d>0. && d<dist ) 
	{	
	
		vec3 n = sphNormal(p, sph0);
		vec4 cubeRay = textureCube(iChannel0, reflect(rd, n)) ;

		col = cubeRay; 
	}
	else
	{
		col = textureCube(iChannel0, rd);
	}
    
    f = col;
}