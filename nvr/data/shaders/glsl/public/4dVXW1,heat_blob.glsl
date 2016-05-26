// Shader downloaded from https://www.shadertoy.com/view/4dVXW1
// written by shadertoy user aiekick
//
// Name: Heat Blob
// Description: You can use mouse x,y to control the shape
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

vec2 m = vec2(1.6, 1.92);

float dstepf = 0.0;

// famous function from shane
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p+dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(5.46,62.8,164.98); 
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*1000.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w); 
    return max(v.x, v.y);
}

vec2 df(vec3 p)
{
	float y = length(p)-1.-Voronesque(p) * -m.x;
	vec2 res = vec2(max(-y, y)-m.y, 1);
    dstepf += 0.02;
    return res;
}

vec3 nor( in vec3 pos, float prec )
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
	    df(pos+eps.xyy).x - df(pos-eps.xyy).x,
	    df(pos+eps.yxy).x - df(pos-eps.yxy).x,
	    df(pos+eps.yyx).x - df(pos-eps.yyx).x );
	return normalize(nor);
}

// return color from temperature 
//http://www.physics.sfasu.edu/astro/color/blackbody.html
//http://www.vendian.org/mncharity/dir3/blackbody/
//http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
vec3 blackbody(float Temp)
{
	vec3 col = vec3(255.);
    col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

// get density of the df at surfPoint
// ratio between constant step and df value
float SubDensity(vec3 surfPoint) 
{
	float ms = 0.2; // min step len
	vec3 n = nor(surfPoint,0.01); 
	vec3 p = surfPoint - n * ms; 
	float s = df(p).x;
	return s/ms; // s < 0. => inside df
}

vec4 light(vec3 ro, vec3 rd, float d, vec3 lightpos, vec3 lc)
{
	vec3 p = ro + rd * d;
	vec3 n = nor(p, 0.01);
	vec3 refl = reflect(rd,n);
		
	vec3 lightdir = normalize(lightpos - p);
	float lightlen = length(lightpos - p);
	
	float amb = 0.6;
	float diff = clamp( dot( n, lightdir ), 0.0, 1.0 );
	float fre = pow( clamp( 1. + dot(n,rd),0.0,1.0), 4. );
	float spe = pow(clamp( dot( refl, lightdir ), 0.0, 1.0 ),16.);
        
	vec3 brdf = vec3(0);
	brdf += amb * vec3(1,0,0); // color mat
	brdf += diff * 0.6;
	brdf += spe * lc * 0.8;
	
	return vec4(brdf, lightlen);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cv, float t)
{
	vec3 cu = normalize(vec3(0,1,0));
  	vec3 z = normalize(cv-ro);
    vec3 x = normalize(cross(cu,z));
  	vec3 y= cross(z,x);
  	return normalize(z + uv.x*x + uv.y*y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
     
    vec2 si = iResolution.xy;
    vec2 uv = (2.*fragCoord-si)/si.y;
    
    if (iMouse.z > 0.)
    	m *= iMouse.xy/si;
    
    vec3 col = vec3(0.);
    
	float elev = 0.;
	float ang = t * 0.24;
	float dist = 4.;
	vec3 ro = vec3(cos(ang), elev, sin(ang));
	ro.xz *= dist;
	
	// first point close to the cam, light for the first plane
    vec3 lpNear = ro;
        
  	vec3 cv = vec3(0);
	
	vec3 rd = cam(uv, ro, cv, t);
       
	float md = 10.;
    float s = 1., so = s;
    float d = 1.;
	
	const float iter = 250.;
    for(float i=0.;i<iter;i++)
    {      
        if (s<0.025*log(d)||d>md) break;
        s = df(ro+rd*d).x;
		d += s * (s>0.1?0.15:0.1);
    }
    
	if (d<md)
	{
        // light close to cam
		vec4 lightNear = light(ro, rd, d, lpNear, vec3(1));
		float attenNear = 0.35 / lightNear.w; // basic attenuation
		col += lightNear.rgb * attenNear;
		
        // heat
        vec3 p = ro + rd * d;
		float sb = dstepf-SubDensity(p);
		col += blackbody(900.*sb-1000.);
	}

	fragColor = vec4(col,1);
}