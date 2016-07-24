// Shader downloaded from https://www.shadertoy.com/view/lscSRS
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 20
// Description: Fractal Experiment 20
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

const vec3 ld = vec3(0.,1., .5);

float t = 0., ts = 0.;

mat3 getRotZMat(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

float fractus(vec3 p)
{
	vec2 z = p.xy;
    vec2 c = vec2(0.28,-0.56) * sin(p.z+cos(p.z));
	float k = 1., h = 1.0;    
    for (float i=0.;i<6.;i++)
    {
       // if (i/6. > (sin(uTime*.5)*.5+.5)) break;
		h *= 4.*k;
		k = dot(z,z);
        z = vec2(z.x * z.x - z.y * z.y, 1.5 * z.x * z.y) + c; // attention au 1.5, normalement il faut 2
    }
	return sqrt(k/h)*log(h);   
}

float df(vec3 p)
{
    if (length(p.xy) < 1.8)
		p *= getRotZMat(p.z*0.5);
	return fractus(p);
}

vec3 nor( vec3 p, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
		df(p+e.xyy) - df(p-e.xyy),
		df(p+e.yxy) - df(p-e.yxy),
		df(p+e.yyx) - df(p-e.yyx) );
    return normalize(n);
}


// from iq code
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<18; i++ )
    {
		float h = df( ro + rd*t );
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
        float dd = df( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 lighting(vec3 p, vec3 lp, vec3 rd, float prec) 
{
    vec3 l = lp - p;
    float d = max(length(l), 0.01);
    float atten = 1.0-exp( -0.01*d*d );
    if (iMouse.z> 0.) atten = exp( -0.001*d*d )-0.5;
    l /= d;
    
    vec3 n = nor(p, prec);
   	vec3 r = reflect(-l, n);
    
    float dif = clamp(dot(l, n), 0.0, 1.0);
    float spe = pow(clamp(dot(r, -rd), 0.0, 1.0), 8.0);
    float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 2.0);
    float dom = smoothstep(-1.0, 1.0, r.y);
    
    dif *= softshadow(p, rd, 0.1, 1.);
    
    vec3 lin = vec3(0.08,0.32,0.47);
    lin += 1.0*dif*vec3(1,1,0.84);
    lin += 2.5*spe*dif*vec3(1,1,0.84);
    lin += 2.5*fre*vec3(1);
    lin += 0.5*dom*vec3(1);
    
    return lin * atten * calcAO(p, n);
}

//--------------------------------------------------------------------------
// Grab all sky information for a given ray from camera
// from Dave Hoskins // https://www.shadertoy.com/view/Xsf3zX
vec3 GetSky(in vec3 rd, in vec3 sunDir, in vec3 sunCol)
{
	float sunAmount = max( dot( rd, sunDir), 0.0 );
	float v = pow(1.0-max(rd.y,0.0),6.);
	vec3  sky = vec3(0.5,0.49,0.72);
	sky = sky + sunCol * sunAmount * sunAmount * .25;
	sky = sky + sunCol * min(pow(sunAmount, 800.0)*1.5, .3);
	return clamp(sky, 0.0, 1.0);
}

void mainImage( out vec4 f, in vec2 g )
{
	vec2 si = iResolution.xy;
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	t = iGlobalTime;
	ts = sin(t)*.5+.5;
    
    vec3 ro = vec3(2.1*vec2(cos(t*.1),sin(t*.1)),t);

    vec3 cu = vec3(0,1,0);
    vec3 co = ro + vec3(0.,0,1);
	
	float fov = .5;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);
	
	float s = 0.01;
	float d = 0.;
	vec3 p = ro + rd * d;
	float dMax = 20.;
	for (float i=0.; i<250.; i++)
	{
		if (s<0.025*log((d*d)/s/500.) || d>dMax) break;
		s = df(p);
        d += s * 0.2;
        p = ro + rd * d;	
	}
	
    vec3 sky = GetSky(rd, ld, vec3(1.5));
    
	if (d<dMax)
	{
        vec3 p =ro+rd*d;
		f.rgb = vec3(0.47,0.6,0.76) * lighting(p, ro, rd, .000001);
		f.rgb = mix( f.rgb, sky, 1.0-exp( -0.03*d*d ) ); 
	}
	else
	{
		f.rgb = sky;
	}
}
