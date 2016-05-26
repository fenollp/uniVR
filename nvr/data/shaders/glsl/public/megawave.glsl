// Shader downloaded from https://www.shadertoy.com/view/4tjXDz
// written by shadertoy user aiekick
//
// Name: MegaWave
// Description: A MegaWave
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const vec3 ld = vec3(0.,1., .5);
const float mPi = 3.14159;
const float m2Pi = 6.28318;

float t = 0.;

float dtepf = 0.;

vec2 df(vec3 p)
{
	vec2 res = vec2(1000.);
	
    dtepf += 0.002;
    
	// mat 1
	float plane = p.y + 1.;
	if (plane < res.x)
		res = vec2(plane, 1.);
		
	// mat 2
	
	// repat by sin and cos
	vec3 q;
    q.x = cos(p.x);
    q.y = p.y * 5. - 10. + 10. * cos(p.x / 7. + t) + 10. * sin(p.z / 7. + t);
    q.z = cos(p.z);
	
	float sphere = length(q) - 1.;
	if (sphere < res.x)
		res = vec2(sphere, 2.);
	
	return res;
}

vec3 nor( vec3 p, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
		df(p+e.xyy).x - df(p-e.xyy).x,
		df(p+e.yxy).x - df(p-e.yxy).x,
		df(p+e.yyx).x - df(p-e.yyx).x );
    return normalize(n);
}

// from iq code
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<100; i++ )
    {
		float h = df( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += h*.25;
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0., 1. );
}

// from iq code
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<10; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = df( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

// from iq code
vec3 lighting(vec3 col, vec3 p, vec3 n, vec3 rd, vec3 ref, float t)    
{
	float occ = calcAO( p, n );
	float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
	float dif = clamp( dot( n, ld ), 0.0, 1.0 );
	float bac = clamp( dot( n, normalize(vec3(-ld.x,0.0,-ld.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
	float dom = smoothstep( -0.1, 0.1, ref.y );
	float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
	float spe = pow(clamp( dot( ref, ld ), 0.0, 1.0 ),16.0);
        
	dif *= softshadow( p, ld, 0.1, 20. );
	dom *= softshadow( p, ref, 0.1, 20. );

	vec3 brdf = vec3(0.0);
	brdf += 1.20*dif*vec3(1.00,0.90,0.60);
	brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
	brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
	brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
	brdf += 0.02;
	col = col * brdf + dtepf;

	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*t*t ) );
	
	return col;
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

void mainImage( out vec4 f, in vec2 g )
{
	vec2 si = iResolution.xy;
	
	vec2 mo = iMouse.xy;
    
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	t = iGlobalTime;
	
	vec3 rayOrg = vec3(cos(t*.2),0.,sin(t*.2));
	vec3 camUp = vec3(0,1,0);
	vec3 camOrg = vec3(0,0,0);
	
	float fov = .5;// by shane
	vec3 axisZ = normalize(camOrg - rayOrg);
	vec3 axisX = normalize(cross(camUp, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rayDir = normalize(axisZ + fov * uv.x * axisX + fov * uv.y * axisY);
	
	vec2 s = vec2(0.01);
	float d = 0.;
	vec3 p = rayOrg + rayDir * d;
	float dMax = 80.;
	float sMin = 0.0001;
	
	for (float i=0.; i<250.; i++)
	{
		if (s.x<sMin || d>dMax) break;
		s = df(p);
		d += s.x * (s.x>0.5?0.35:0.75);
		p = rayOrg + rayDir * d;	
	}
	
    vec3 sky = GetSky(rayDir, ld, vec3(1.5));
    
	if (d<dMax)
	{
		vec3 n = nor(p, 0.0001);
		
		// 	iq primitive shader : https://www.shadertoy.com/view/Xds3zN
		float r = mod( floor(5.0*p.z) + floor(5.0*p.x), 2.0);
        f.rgb = 0.4 + 0.1*r*vec3(1.0);

        // iq lighting
		float occ = calcAO( p, n );
        float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, ld ), 0.0, 1.0 );
        float spe = pow(clamp( dot( rayDir, ld ), 0.0, 1.0 ),16.0);

        dif *= softshadow( p, ld, 0.1, 50. );

        vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
        brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.02;
        f.rgb *= brdf + dtepf;

        f.rgb = mix( f.rgb, sky, 1.0-exp( -0.0005*d*d ) ); 
	}
	else
	{
		f.rgb = sky;
	}
		
	
	gl_FragColor = f;
}