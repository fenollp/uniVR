// Shader downloaded from https://www.shadertoy.com/view/llsXzB
// written by shadertoy user aiekick
//
// Name: Oren Nayar Light Model
// Description: I tried to do the Oren Nayar Light Model explained here :
//     [url=//https://en.wikipedia.org/wiki/Oren%E2%80%93Nayar_reflectance_model]Oren Nayar Light Model[/url]
//    I dont know if i have well writed the model, because the light change while the cam move..
const vec2 RMPrec = vec2(0.5, 0.01); // ray marching tolerance precision // low, high
const vec2 DPrec = vec2(0.0001, 100.); // ray marching distance precision // low, high

#define mPi 3.14159
#define m2Pi 6.28318

vec2 s,g,m;

// metric
float lenABC(vec3 p, vec3 ABC){return pow(pow(p.x*p.x, ABC.x) + pow(p.y*p.y, ABC.y) + pow(p.z*p.z, ABC.z), .5);}

vec4 map(vec3 p)
{
	vec4 col = vec4(0.);
	
    float r = sin(iGlobalTime*.5)*.25+.75;
    
    vec3 objParams = vec3(r);
	col.x = lenABC(p,objParams)-2.;
	
	return col;
}

vec3 cam(vec2 uv, in vec3 ro, in vec3 up, in vec3 org)
{
	vec3 rov = normalize(org-ro.xyz);
    vec3 u =  normalize(cross(up, rov));
    vec3 v =  normalize(cross(rov, u));
    return normalize(rov + u*uv.x + v*uv.y);
}

//https://en.wikipedia.org/wiki/Oren%E2%80%93Nayar_reflectance_model
vec3 OrenNayarLightModel(vec3 rd, vec3 ld, vec3 n)
{
	vec3 col = vec3(0.);

	float RDdotN = dot(-rd, n);
	float NdotLD = dot(n, ld);
    
    float aRDN = acos(RDdotN);
	float aNLD = acos(NdotLD);
    
	float mu = 0.3; // roughness
	if (iMouse.z>0.) mu = iMouse.y/iResolution.y;
    
	float A = 1.-.5*mu*mu/(mu*mu+0.57);
	float B = .45*mu*mu/(mu*mu+0.09);
	
	float alpha = max(aRDN, aNLD);
	float beta = min(aRDN, aNLD);
	
	float albedo = 1.1;
	
	float e0 = 3.1;
	col = vec3(albedo / mPi) * cos(aNLD) * (A + ( B * max(0.,cos(aRDN - aNLD)) * sin(alpha) * tan(beta)))*e0;
	
	return col;
}

// thanks to kuvkar
vec3 OrenNayarLightModel2(vec3 rd, vec3 ld, vec3 n)
{
    vec3 col = vec3(0.);

    float NdotL = dot(n, ld);
    float NdotV = dot(-rd, n);

    float angleVN = acos(NdotV);
    float angleLN = acos(NdotL);

    float mu = .3; // roughness
	if (iMouse.z>0.) mu = iMouse.y/iResolution.y;
    
    float A = 1.-.5*mu*mu/(mu*mu+0.57);
    float B = .45*mu*mu/(mu*mu+0.09);

    float alpha = max(angleVN, angleLN);
    float beta = min(angleVN, angleLN);
    float gamma = dot(-rd -(n * NdotV), ld - (n * NdotL));
    float albedo = 1.1;
    float e0 = 3.1;
    float L1 = max(0.0, NdotL) * (A + B * max(0.0, gamma) * sin(alpha) * tan(beta));
    col = vec3(1.0) * L1;

    return col;
}
vec4 scn(vec2 uv, float t)
{	
	vec3 ro = vec3(sin(t), -sin(3.55), cos(t))*5.5;
	vec3 up = vec3(0,1,0);
	vec3 org = vec3(0);
	
	vec3 rd = cam(uv, ro, up, org);
	
	vec4 col = vec4(0.);

	float s = DPrec.x;
	float d = 0.;
	vec3 p = ro+rd*d;
    
	for(int i=0;i<200;i++)
	{
		if(s<DPrec.x||s>DPrec.y) break;
		s = map(p).x;
		d += s*(s>DPrec.x?RMPrec.x:RMPrec.y);
		p = ro+rd*d;
	}	
    
	float lightIntensity = sin(iGlobalTime*0.5)*.5;

	if (s<DPrec.x)
	{
		vec2 e = vec2(0.01, 0.);
		vec3 n;
		n.x = map(p+e.xyy).x - map(p-e.xyy).x; 
		n.y = map(p+e.yxy).x - map(p-e.yxy).x; 
		n.z = map(p+e.yyx).x - map(p-e.yyx).x;  
		n = normalize(n); 
		
		col.rgb = g.x<m.x?
            OrenNayarLightModel(rd, reflect(rd,n), n):
        	OrenNayarLightModel2(rd, reflect(rd,n), n);
   	
	}
	else
	{
		col = textureCube(iChannel0, rd);	
	}
	
	return col;
}

void mainImage(out vec4 f, in vec2 gg)
{
	s = iResolution.xy;
    g = gg;
    m = s/2.;
    if ( iMouse.z >0.) m=iMouse.xy;
	vec2 uv = (g+g-s)/s.y;
	
	float t = iGlobalTime;
	
	f = scn(uv, t*.5);
    
    f = mix( f, vec4(0.), 1.-smoothstep( 1., 2., abs(m.x-g.x) ) );    
}
