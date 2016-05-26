// Shader downloaded from https://www.shadertoy.com/view/MljSRy
// written by shadertoy user aiekick
//
// Name: Cloudy MegaWave
// Description: Cloudy MegaWave based of the [url=https://www.shadertoy.com/view/MljXDw]Cloudy Spikeball[/url] shader from duke
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/* 
	this shader is a mix of :

 	Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
	Shader MegaWave 2 from me : https://www.shadertoy.com/view/ltjXWR

	I use the shape from megawave with the cloudy technique.
*/

const vec3 lightDir = vec3(0.,1., 0.5);
const float mPi = 3.14159;
const float m2Pi = 6.28318;

float t = 0.;

/////////////////////////
// FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
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
    p *= 30.;
    p.xz += iGlobalTime*50.;
	return fpn(p) * .5;
}

vec2 df(vec3 p)
{
	vec2 res = vec2(1000.);
	
	vec3 q;
	
    float dp = disp(p);
    
	// mat 2
	q.x = cos(p.x);
	q.y = p.y * 5. - 21. + 10. * cos(p.x / 7. + t) + 10. * sin(p.z / 7. + t);
	q.z = cos(p.z);
	float sphere = length(q) - 1. + dp;
		res = vec2(sphere, 2.);
	
	// mat 3
	q.x = cos(p.x);
	q.y = p.y * 5. + 21. + 10. * cos(p.x / 7. + t + mPi) + 10. * sin(p.z / 7. + t + mPi);
	q.z = cos(p.z);
	sphere = length(q) - 1. + dp;
	if (sphere < res.x)
		res = vec2(sphere, 3.);
		
	return res;
}

//--------------------------------------------------------------------------
// Grab all sky information for a given ray from camera
// from Dave Hoskins // https://www.shadertoy.com/view/Xsf3zX
vec3 GetSky(in vec3 rd, in vec3 sunDir, in vec3 sunCol)
{
	float sunAmount = max( dot( rd, sunDir), 0.0 );
	float v = pow(1.0-max(rd.y,0.0),6.);
	vec3  sky = mix(vec3(.1, .2, .3), vec3(.32, .32, .32), v);
	sky = sky + sunCol * sunAmount * sunAmount * .25;
	sky = sky + sunCol * min(pow(sunAmount, 800.0)*1.5, .3);
	return clamp(sky, 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 f = vec4(0,0,0,1);
	
	vec2 g = fragCoord;
	vec2 si = iResolution.xy;
    
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	t = iGlobalTime*0.5;
	
	vec3 rayOrg = vec3(t,0.,t)  * 5.;
	vec3 camUp = vec3(0,1,0);
	vec3 camOrg = rayOrg + vec3(1,0,1);
	
	float fov = 0.5;
	vec3 axisZ = normalize(camOrg - rayOrg);
	vec3 axisX = normalize(cross(camUp, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rayDir = normalize(axisZ + fov * uv.x * axisX + fov * uv.y * axisY);
	
	vec2 s = vec2(0.01);
	float d = 0.;
	vec3 p = rayOrg + rayDir * d;
	
    vec3 sky = GetSky(rayDir, lightDir, vec3(5.));
	
	float dMax = 50.;
	float sMin = 0.0001;
	
    /////////////////////////
	// FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
	float ld, td= 0.; // ld, td: local, total density 
	float w; // w: weighting factor
	vec3 tc = sky*.8; // total color
	float h=.05;
    const float stepf = 1./250.;
	/////////////////////////
    
	for (float i=0.; (i<1.); i+=stepf) 
	{
        // FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
		if(!((i<1.) && (s.x>sMin) && (d < dMax)&& (td < .95))) break;
		
        s = df(p);
		s.x *= (s.x>0.001?0.1:.2) ;
        
        /////////////////////////
		// FROM Shader Cloudy spikeball from duke : https://www.shadertoy.com/view/MljXDw
		ld = (h - s.x) * step(s.x, h);
		w = (1. - td) * ld;   
		tc += w;// * hsv(w, 1., 1.) * hsv(w*3.-0.5, 1.-w*20., 1.); 
      	td += w + .005;
      	s.x = max(s.x, 0.03);
        /////////////////////////
      	
        d += s.x;
	  	p = rayOrg + rayDir * d;
    }
	
	f.rgb = mix( tc, sky, 1.0-exp( -0.001*d*d) );

	// vigneting from iq Shader Mike : https://www.shadertoy.com/view/MsXGWr
    vec2 q = g/si;
    f.rgb *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 );
    
	fragColor = f;
}
