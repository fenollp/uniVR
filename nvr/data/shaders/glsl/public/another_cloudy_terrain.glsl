// Shader downloaded from https://www.shadertoy.com/view/XtSSRK
// written by shadertoy user aiekick
//
// Name: Another Cloudy Terrain
// Description: Based on the [url=https://www.shadertoy.com/view/MljXDw]Cloudy Spikeball[/url] shader from duke
//    and use the voronesque from shane
//    use mouse axis X to translate the cam horizontally
//    this shader use the code of my shader Subo Glacius
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    
/* 
Based on the Cloudy Spikeball shader from duke https://www.shadertoy.com/view/MljXDw 
and use the voronesque from shane
use mouse axis X to translate the cam horizontally
this shader use the code of my shader Subo Glacius
*/

const vec2 RMPrec = vec2(.2, 0.01); 
const vec2 DPrec = vec2(0.01, 50.); 

const vec3 IceColor = vec3(0,.38,.47);
const vec3 DeepColor = vec3(0,.02,.15);

/////////////////////////
// FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(iChannel1, (uv+ 0.5)/256.0, -100.0 ).yx;
	rg = vec2(rg.x + rg.y)/2.;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}

float fpn(vec3 p) 
{
	return pn(p*.06125)*.5 + pn(p*.125)*.25 + pn(p*.25)*.125;
}
/////////////////////////

float disp(vec3 p)
{
    p *= 50.;
    p.x+=iGlobalTime*50.;
    return fpn(p) * .5;
}

// by shane from https://www.shadertoy.com/view/4lSXzh
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); 
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*262144.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w); 
    return max(v.x, v.y);
}

vec2 map(vec3 p)
{
	float voro = Voronesque(p);
	float tex = texture2D(iChannel0, p.xz/200.).r*12.;
	return vec2(p.y - tex + voro + disp(p), 0.);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 si = iResolution.xy.xy;
	vec2 g = fragCoord.xy;
   	vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 cu = vec3(0,1,0);
    vec3 ro = vec3(-11., 10., iGlobalTime);
	vec3 cv = vec3(0,0,1); 
    
    vec4 f = vec4(0);
	
    ro.x = -20.*iMouse.x/si.x;
    
   	float vy = map(ro + cv).x;// cam h
    
    // smooth cam path
	const int smoothIter = 8;
	for (int i=0;i<smoothIter;i++)
	vy += map(ro + cv * float (i)).x;
    vy /= float(smoothIter);
    
	ro.y -= vy * .78;
    
    vec3 rd = cam(uv, ro, cu, ro + cv);
	
    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
	float sgn = sign(map(p).x);
    vec2 s = vec2(DPrec.y,0.);
	
	float h = 0.05;
	float td = 0.;
	float w = 0.;
	vec3 tc = IceColor;
	
    for(int i=0;i<100;i++)
	{      
		if(s.x<DPrec.x||s.x>DPrec.y||td>.95) break;
		
        s = map(p);
		s.x *= (s.x>0.001?0.1:.2);
	
		if (s.x<h)
		{
			w = (1.-td) * (h-s.x);
			tc+=w;
			td+=w;
		}	
		
		td+=0.005;
        s.x = max(s.x, .03);
        
		d.x += s.x;
        p = ro+rd*d.x;
   	}

	f.rgb = tc;
	
	f = mix( f, vec4(DeepColor, 1.), 1.2 - exp(-0.01*d.x*d.x) ); // fog
    
	fragColor = f;
}
