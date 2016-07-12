// Shader downloaded from https://www.shadertoy.com/view/XsdSW7
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 17
// Description: Change pattern evolution by mouse axis X
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

const vec3 ld = vec3(0.,1., .5);

float t = 0., ts = 0.;
float dstepf = 0.0;

float ratio = 0.5;

vec2 path(float z)
{
	return vec2(cos(z), sin(z));
}

mat3 getRotXMat(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 getRotZMat(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

//julia fractal
float fractus(vec3 p)
{
	vec2 z = p.xy;
    vec2 c = vec2(0.28,-0.56) * 2. * ratio;
	float k = 1., h = 1.0;    
    for (float i=0.;i<7.;i++)
    {
        h *= 4.*k;
		k = dot(z,z);
        if(k > 4.) break;
		z = vec2(z.x * z.x - z.y * z.y, 2. * z.x * z.y) + c;
    }
	return sqrt(k/h)*log(k);
}

vec2 df(vec3 p)
{
    p.xy += path(p.z*0.2)*1.5;
	p *= getRotZMat(p.z*0.2);
	p = mod(p, 4.) - 2.;
	float obj = fractus(p);
	vec2 res = vec2(obj, 1.);

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
    for( int i=0; i<18; i++ )
    {
		float h = df( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += h*.25;
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0., 1. );
}

// from iq code
float cao( in vec3 pos, in vec3 nor )
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


vec3 lighting(vec3 p, vec3 lp, vec3 rd, float prec) 
{
    vec3 l = lp - p;
    float d = max(length(l), 0.01);
    float atten = exp( -0.0001*d )-0.5;
    l /= d;
    
    vec3 n = nor(p, prec);
   	vec3 r = reflect(-l, n);
    
    float dif = clamp(dot(l, n), 0.0, 1.0);
    float spe = pow(clamp(dot(r, -rd), 0.0, 1.0), 8.0);
    float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 2.0);
    float dom = smoothstep(-1.0, 1.0, r.y);
    
    dif *= softshadow(p, l, 0., 1.);
    
    vec3 lin = vec3(0.08,0.32,0.47);
    lin += 1.0*dif*vec3(1,1,0.84);
    lin += 2.5*spe*dif*vec3(1,1,0.84);
    lin += 2.5*fre*vec3(1);
    lin += 0.5*dom*vec3(1);
    
    return lin * atten * cao(p, n);
}

void mainImage( out vec4 f, vec2 g )
{
	vec2 si = iResolution.xy;
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	t = iGlobalTime * 5.;
	ts = sin(t)*.5+.5;
    
    ratio = 0.5;
    if (iMouse.z > 0.)
    	ratio = iMouse.x / si.x;
    
    dstepf = 0.5;
    
	vec3 ro = vec3(0,0,t);
   
	vec3 cu = vec3(0,1,0);
	vec3 co = ro + vec3(0,0,1);
	
	float fov = .5;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);
   
	vec2 s = vec2(0.01);
	float d = 0.;
	vec3 p = ro;
	float dMax = 30.;
	
	for (float i=0.; i<250.; i++)
	{
		if (s.x<0.0025*d || d>dMax) break;
		s = df(p);
		d += s.x * (s.x>0.1?0.2:0.2);
		p = ro + rd * d;	
        dstepf += 0.002;
	}
	
    f.rgb = vec3(0.47,0.6,0.76) * lighting(p, ro, rd, 0.1); 
	f.rgb = mix( f.rgb, vec3(0.5,0.49,0.72), 1.0-exp( -0.01*d*d ) ); 
}
