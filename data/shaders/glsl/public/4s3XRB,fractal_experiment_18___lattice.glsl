// Shader downloaded from https://www.shadertoy.com/view/4s3XRB
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 18 : Lattice
// Description: Fractal Experiment 18 : Lattice
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
based on https://www.shadertoy.com/view/4stXR7
*/

const vec3 ld = vec3(0.,1., .5);
float dstepf = 1.0;
float t = 0.;

vec2 path(float z){return sin(z*.2 + vec2(1.6,0));}

mat3 getRotXMat(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 getRotZMat(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

float fractus(vec3 p)
{
	vec2 z = p.xy;
    vec2 c = vec2(-1.04,-0.36) * vec2(cos(p.z), sin(p.z));
	float k = 1., h = 1.0;    
    for (float i=0.;i<6.;i++)
    {
		h *= 4.*k;
		k = dot(z,z);
		if (k > 4.) break;
        z = vec2(z.x * z.x - z.y * z.y, 2.* z.x * z.y) + c;
    }
	return  sqrt(k/h)*log(k);   
}

float df(vec3 p)
{
	vec3 tutu;
	
	float torsion = sin(t*0.8) * 0.;
	
	vec3 pz = p;
    pz.z += 0.;
    pz.xy = mod(pz.xy, 8.) - 8.*0.5;
	pz *= getRotZMat(sin(pz.z*0.));
	tutu.x = min(1.,fractus(pz.xyz));

	vec3 py = p;
	py.y += 0.;
    py.xz = mod(py.xz, 8.) - 8.*0.5;
	py *= getRotYMat(sin(py.y*0.));
	tutu.y = min(1.,fractus(py.xzy));
	
	vec3 px = p;
    px.x += 0.;
	px.z += -0.5;
    px.yz = mod(px.yz, 8.) - 8.*0.5;
	px *= getRotXMat(sin(px.x*0.));
	tutu.z = min(1.,fractus(px.yzx));

	float k = tutu.x*tutu.y*tutu.z;
	return k;
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


float trace( in vec3 ro, in vec3 rd)
{
	float s = 1.;
	float d = 0.;
	vec3 p = ro;
	
	for (float i=0.; i<150.; i++)
	{
		if (s < 0.025*log(d*d/s/500.) || d>40.) break; // last change was d*d
		s = df(p);
		d += s * 0.2;
		p = ro + rd * d;	
		dstepf += 0.005;
	}
	
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 si = iResolution.xy;
	vec2 uv = (2.*fragCoord-si)/min(si.x, si.y);

	t = iGlobalTime * 0.1;

    vec3 cu = vec3(0,1,0);
    vec3 ro = vec3(cos(t),cos(t)*sin(t),sin(t));
	ro.xz *= 10.5;
    ro.y *= 9.;
	t+= .1;
    vec3 co = ro + vec3(sin(t), cos(t),cos(t));
	
	float fov = 0.8;
	vec3 axisZ = normalize(co - ro);
	vec3 axisX = normalize(cross(cu, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rd = normalize(axisZ + fov * uv.x * axisX + fov * uv.y * axisY);
	
	float d = trace(ro, rd);
	vec3 p = ro + rd * d;	
	
    float fogd = 0.01;
    if (iMouse.z>0.)
        fogd = 0.001;
    
	fragColor.rgb = vec3(0.47,0.6,0.76) * lighting(p, ro, rd, 0.0001); 
	fragColor.rgb = mix( fragColor.rgb, vec3(0.5,0.49,0.72), 1.0-exp( -fogd*d*d ) ); 
}
