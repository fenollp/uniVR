// Shader downloaded from https://www.shadertoy.com/view/4t2Xzt
// written by shadertoy user aiekick
//
// Name: Subluminic 3
// Description: Subluminic 3
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/* 
	the cloudy famous tech come from the shader of duke : https://www.shadertoy.com/view/MljXDw
        Himself a Port of a demo by Las => http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9
*/

vec4 freqs;
float t;

#define uTex2D iChannel0
float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(uTex2D, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}

vec2 path(float t, float k, float c)
{
	return vec2(cos(t/k), sin(t/k))*c;
}

float df(vec3 p)
{
	float pnNoise = pn(p*0.7)*1.7 + pn(p*0.8)*2.2 + pn(p*3.1)*0.6;
	p.z += pnNoise;
	p.xy += path(p.z, 5., 10.);
	float serpentA = length(p.xy) - 2.;
	p.xy += path(p.z, 1., 10.);
	float serpentB = length(p.xy/(freqs.xy+.1)) - 2.;
	return min(serpentA, serpentB);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv, float fov)
{
	vec3 rov = normalize(cv-ro);
    vec3 u = normalize(cross(cu, rov));
    vec3 v = normalize(cross(rov, u));
    vec3 rd = normalize(rov + fov * u * uv.x + fov * v * uv.y);
    return rd;
}

vec3 nor( vec3 p, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
		df(p+e.xyy) - df(p-e.xyy),
		df(p+e.yxy) - df(p-e.yxy),
		df(p+e.yyx) - df(p-e.yyx)
		);
    return normalize(n);
}

vec3 march(vec3 f, vec3 ro, vec3 rd, float st)
{
	vec3 s = vec3(1), h = vec3(.16,.008,.032), w = vec3(0);
	float d=1.,dl=0., td=0.;
	vec3 p = ro;
	for(float i=0.;i<100.;i++)
	{      
		if(s.x<0.01||d>400.||td>.95) break;
        s = df(p) * .1 * i/vec3(107,160,72);
		w = (1.-td) * (h-s) * i/vec3(61,27,54)* freqs.yzw * 4. * step(s,h);
		f += w;
		td += w.x + .01;
		dl += 0.05;	
		s = max(s, st);
		d +=s.x; 
		p =  ro+rd*d;	
   	}
	dl += 0.5;
	f /= dl/15.;
	f = mix( f, vec3(0), 1. - exp( -.0002*d*d) ); // iq fog
	return f;
}

#define uTime iGlobalTime
#define uScreenSize iResolution.xy
void mainImage( out vec4 f, in vec2 g )
{
    // from CubeScape : https://www.shadertoy.com/view/Msl3Rr
    freqs.x = texture2D( iChannel1, vec2( 0.01, 0.25 ) ).x;
	freqs.y = texture2D( iChannel1, vec2( 0.07, 0.25 ) ).x;
	freqs.z = texture2D( iChannel1, vec2( 0.15, 0.25 ) ).x;
	freqs.w = texture2D( iChannel1, vec2( 0.30, 0.25 ) ).x;
    
	t = uTime*2.5;
	f = vec4(0,0.15,0.32,1);
    vec2 si = uScreenSize;
	vec2 q = g/si;
	float z = t * 5.;
    vec3 ro = vec3(path(z,5.,5.+(sin(t*.5)*.5+.5)*5.), z );
	vec2 uv = (2.*g-uScreenSize)/uScreenSize.y;
	vec3 rd = cam(uv, ro, vec3(path(z,10.,10.),0), ro+vec3(0,0,1), 3.5);
	f.rgb = march(f.rgb, ro, rd, 0.2);
	uv*= uScreenSize * 10.;
	float k = fract( cos(uv.y * 0.0001 + uv.x) * 500000.);
	f.rgb = mix(f.rgb, vec3(1), pow(k, 50.));
	f.rgb *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 ); // vignette
}
