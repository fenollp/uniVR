// Shader downloaded from https://www.shadertoy.com/view/4lSXRK
// written by shadertoy user aiekick
//
// Name: Another Cloudy Tunnel
// Description: the cloudy tech come from the [url=https://www.shadertoy.com/view/MljXDw]Cloudy Spikeball[/url] shader from duke
//    jute for the fun =&gt; click on screen for a second visu mode
//    Comment line 14 to see antoher cloud version
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/* 
	based on my Tunnel experiment 1 : 
		https://www.shadertoy.com/view/llBXWR

	the cloudy famous tech come from the shader of duke : https://www.shadertoy.com/view/MljXDw
        Himself a Port of a demo by Las => http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9

	Just for the fun, if you click on screen you have a second mode of cam :)
*/

#define BASE_VERSION

float t;

float cosPath(vec3 p, vec3 dec){return dec.x * cos(p.z * dec.y + dec.z);}
float sinPath(vec3 p, vec3 dec){return dec.x * sin(p.z * dec.y + dec.z);}

vec2 getCylinder(vec3 p, vec2 pos, float r, vec3 c, vec3 s)
{
	return p.xy - pos - vec2(cosPath(p, c), sinPath(p, s));
}

/////////////////////////
// FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}

float fpn(vec3 p) 
{
	p.z += t*50.*(1.-step(iMouse.z,0.));
#ifdef BASE_VERSION 
	return pn(p*.06125)*.6 + pn(p*.125)*.3 + pn(p*.25)*.15; //original
#else
    return pn(p*0.02)*1.98 + pn(p*0.02)*0.62 + pn(p*0.09)*0.5;
#endif
}
/////////////////////////

float map(vec3 p)
{
	float pnNoise = fpn(p*13.);
	float path = sinPath(p ,vec3(6.2, .33, 0.));
	float bottom = p.y + pnNoise;
	float cyl = 0.;vec2 vecOld;
	for (float i=0.;i<6.;i++)
	{
		float x = 1. * i;
		float y	= .88 + 0.0102*i;
		float z	 = -0.02 -0.16*i;
		float r = 4.4 + 2.45 * i;
		vec2 vec = getCylinder(p, vec2(path, 3.7 * i), r , vec3(x,y,z), vec3(z,x,y));
		cyl = r - min(length(vec), length(vecOld));
		vecOld = vec;	
	}
	cyl += pnNoise;
	cyl = min(cyl, bottom);
	return cyl;
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
	float fov = 3.;
    vec3 rd = normalize(rov + fov*u*uv.x + fov*v*uv.y);
    return rd;
}

void mainImage( out vec4 f, in vec2 g )
{
    f = vec4(0.0);
    t = iGlobalTime;
	vec2 si = iResolution.xy;
	vec2 uv = (2.*g-si)/min(si.x, si.y);
    vec3 p = vec3(0);
	p.y = sin(t*.2)*16.+16.; // 0 => 32
	p.z = t*5.*step(iMouse.z,0.);
	vec3 rd = cam(uv, p, vec3(0,1,0), p + vec3(0,0,1));
	float s = 1., h = 0.1, td = 0., w, prec=0.001;
    for(int i=0;i<200;i++)
	{      
		if(s<prec||td>.95) break;
        s = map(p) * (s>0.001?.1:.2);
		if (s < h)
		{
			w = (1.-td) * (h-s);
			f += w;
			td += w;
		}
		td += .005;
		s = max(s, 0.03);
		p += rd*s;	
   	}
}
