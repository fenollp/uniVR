// Shader downloaded from https://www.shadertoy.com/view/XscSW7
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 16
// Description: Fractal Experiment 16
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
based on https://www.shadertoy.com/view/4stXR7
*/

const vec3 ld = vec3(0.,1., .5);
float dstepf = 0.0;
float t = 0.;

vec2 path(float z){return sin(z*.3 + vec2(1.6,0));}

float fractus(vec3 p)
{
	vec2 z = p.xy;
    vec2 c = vec2(0.28,-0.56) * sin(p.z-cos(p.z));
	float k = 1., h = 1.0;    
    for (float i=0.;i<5.;i++)
    {
		//if (i/5. > (sin(iGlobalTime*.5)*.5+.5)) break;
		h *= 4.*k;
		k = dot(z,z);
        z = vec2(z.x * z.x - z.y * z.y, 1.5 * z.x * z.y) + c;
    }
	return 1. - sqrt(k/h)*log(h);   
}

vec2 df(vec3 p)
{
    p.xy += path(p.z);
	float obj = min(1., fractus(p));
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

// from velocibox by zackpudil : https://www.shadertoy.com/view/lsdXD8
vec3 lighting(vec3 p, vec3 lp, vec3 rd, float prec) 
{
    vec3 l = lp - p;
    float dist = max(length(l), 0.01);
    float atten = min(1./(1. + dist*0.5), 0.2);
    l /= dist;
    
    vec3 n = nor(p, prec);
   	vec3 r = reflect(-l, n);
    
    float dif = clamp(dot(l, n), 0.0, 1.0);
    float spe = pow(clamp(dot(r, -rd), 0.0, 1.0), 8.0);
    float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 2.0);
    float dom = smoothstep(-1.0, 1.0, r.y);
    
    vec3 lin = vec3(0.08,0.32,0.47);//vec3(0.2);
    lin += 1.0*dif*vec3(1,1,0.84);//vec3(1, .97, .85);
    lin += 2.5*spe*dif*vec3(1,1,0.84);//vec3(1, .97, .85);
    lin += 2.5*fre*vec3(1);
    lin += 0.5*dom*vec3(1);
    
    return lin*atten*calcAO(p, n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 si = iResolution.xy;
	vec2 g = fragCoord;
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	vec4 f = vec4(0);
	
	t = iGlobalTime*2.;
    
	dstepf = 1.5;
	
    vec3 rayOrg = vec3(vec2(0,0),t);
    rayOrg.xy -= path(t);

    vec3 camUp = vec3(0,1,0);
    // thanks to shane
    vec3 camOrg = vec3(vec2(0,0), t+.1);
	camOrg.xy -= path(t+.1);
	
	float fov = 0.8;
	vec3 axisZ = normalize(camOrg - rayOrg);
	vec3 axisX = normalize(cross(camUp, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rayDir = normalize(axisZ + fov * uv.x * axisX + fov * uv.y * axisY);
	
	vec2 s = vec2(0.01);
	float d = 0.;
	vec3 p = rayOrg + rayDir * d;
	float dMax = 40.;
	float sMin = 0.00001;
	
	for (float i=0.; i<250.; i++)
	{
		if (s.x<sMin || d>dMax) break;
		s = df(p);
		d += s.x * 0.3;
		p = rayOrg + rayDir * d;	
        dstepf += 0.005;
	}
	
	fragColor.rgb = vec3(0.89,0.91,1) * lighting(p, rayOrg, rayDir, 0.001) * dstepf; 
	fragColor.rgb = mix( fragColor.rgb, vec3(0.89,0.91,1), 1.0-exp( -0.007*d*d ) ); 
}