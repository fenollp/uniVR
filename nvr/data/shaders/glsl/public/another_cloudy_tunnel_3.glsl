// Shader downloaded from https://www.shadertoy.com/view/ltBSzV
// written by shadertoy user aiekick
//
// Name: Another Cloudy Tunnel 3
// Description: Vairation of [url=https://www.shadertoy.com/view/XlSSzV]Another Cloudy 2[/url] 
//    More cloudy, smoothy, less artefact, and better optimised for fullscreen..
//    but close to cam there is some artefact some time. how can i do antialiased on this ?
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/* 
	variation more cloudy of Another Cloudy Tunnel 2 : 
		https://www.shadertoy.com/view/XlSSzV

	the cloudy famous tech come from the shader of duke : https://www.shadertoy.com/view/MljXDw
        Himself a Port of a demo by Las => http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9
*/

float t;
float cosPath(vec3 p, vec3 dec){return dec.x * cos(p.z * dec.y + dec.z);}
float sinPath(vec3 p, vec3 dec){return dec.x * sin(p.z * dec.y + dec.z);}
#define Tunnel(p,pos,c,s) p.xy-pos-vec2(cosPath(p, c),sinPath(p, s))

float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}

float df(vec3 p)
{
	float pnNoise = pn(p*.26)*1.98 + pn(p*.26)*.62 + pn(p*1.17)*.39;
	float path = sinPath(p ,vec3(5.704,0.3828,0.16));
    float bt = min(p.y, -p.y) + 12.;
	float df;
    vec4 vec, var;
	for (float i=0.;i<4.;i++)
	{
		var = vec4(0.35,2.5,5.8,0) + vec4(0.5,0.06,0,5) * i;
		vec.xy = Tunnel(p, vec2(path, 0.), var.xyz, var.zxy);
		df = var.w - min(length(vec.xy), length(vec.zw));
		vec.zw = vec.xy;	
	}
	return min(df, bt) + pnNoise;
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv, float fov)
{
	vec3 rov = normalize(cv-ro);
    vec3 u = normalize(cross(cu, rov));
    vec3 v = normalize(cross(rov, u));
    vec3 rd = normalize(rov + fov * u * uv.x + fov * v * uv.y);
    return rd;
}

vec4 march(vec4 f, vec3 ro, vec3 rd, float st)
{
	float s = 1., h = .2, td = 0., d=1.,dl=0., w;
	vec3 p = ro;
	for(float i=0.;i<100.;i++)
	{      
		if(s<0.1||d>40.||td>.95) break;
        s = df(p) * .09 * i/ 50.;
		if (s < h)
		{
			w = (1.-td) * (h-s) * i/40.;
			f += w;
			td += w;
		}
		dl += 1. - exp(-0.001 * log(d));
		td += 0.01;
		s = max(s, st);
		d+=s; 
		p = ro+rd*d;	
   	}
	dl += 3.;
	f.rgb /= dl/3.;
	f.rgb = mix( f.rgb, vec3(0), 1.0 - exp( -0.002*d*d) ); // fog
	return f;
}

void mainImage( out vec4 f, in vec2 g )
{
	t = iGlobalTime;
	f = vec4(0,0.15,0.32,1);
    vec2 q = g/iResolution.xy;
    vec3 ro = vec3(cos(t*.2), sin(t*.6),t )*vec3(8.5, 10.5, 6.5);
	vec3 rd = cam((2.*g-iResolution.xy)/iResolution.y, ro, vec3(0,1,0), ro + vec3(0,0,1), 3.5);
	f = march(f, ro, rd, 0.26);
    f.rgb *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 ); // vignette
}
