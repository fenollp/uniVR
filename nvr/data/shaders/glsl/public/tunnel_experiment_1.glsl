// Shader downloaded from https://www.shadertoy.com/view/llBXWR
// written by shadertoy user aiekick
//
// Name: Tunnel Experiment 1
// Description: Tunnel Experiment 1
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define mPi 3.14159
#define m2Pi 6.28318

float dstepf = 0.0;

const vec2 NoiseVar = vec2(950.,200.);
    
const vec2 RMPrec = vec2(.1, 0.001); 
const vec2 DPrec = vec2(0.0001, 500.); 

float random(float p) {return fract(sin(p)*NoiseVar.x);}
float mynoise(vec2 p) {return random(p.x + p.y*NoiseVar.y);}
vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}
float snoise(vec2 p) {
  	vec2 inter = smoothstep(0., 1., fract(p));
  	float s = mix(mynoise(sw(p)), mynoise(se(p)), inter.x);
  	float n = mix(mynoise(nw(p)), mynoise(ne(p)), inter.x);
  	return mix(s, n, inter.y);
}

//https://www.shadertoy.com/view/llsXzB
//https://en.wikipedia.org/wiki/Oren%E2%80%93Nayar_reflectance_model
float OrenNayarLightModel(vec3 rd, vec3 ld, vec3 n, float albedo)
{
	vec3 col = vec3(0.);
	float RDdotN = dot(-rd, n);
	float NdotLD = dot(n, ld);
    float aRDN = acos(RDdotN);
	float aNLD = acos(NdotLD);
	float mu = 5.; // roughness
	float A = 1.-.5*mu*mu/(mu*mu+0.57);
    float B = .45*mu*mu/(mu*mu+0.09);
	float alpha = max(aRDN, aNLD);
	float beta = min(aRDN, aNLD);
	float e0 = 4.8;
	return albedo / mPi * cos(aNLD) * (A + ( B * max(0.,cos(aRDN - aNLD)) * sin(alpha) * tan(beta)))*e0;
}

//https://www.shadertoy.com/view/Xl23Rc
vec3 strate(vec2 uv)
{
    vec3 col1 = vec3(.94,.7,.25);
    vec3 col2 = vec3(.91,.67,.11);
    float y = uv.y+.85*sin(-uv.x);
    y/=.85;
    float r = sin(25.*y)+cos(16.*y)+cos(19.*y);
    vec3 col = mix(col1, col2, r);
    return col;
}

// used to compute campath and plane deformation along z
float cosPath(vec3 p, vec3 dec){return dec.x * cos(p.z * dec.y + dec.z);}
float sinPath(vec3 p, vec3 dec){return dec.x * sin(p.z * dec.y + dec.z);}

vec2 getCylinder(vec3 p, vec2 pos, float r, vec3 c, vec3 s)
{return p.xy - pos - vec2(cosPath(p, c), sinPath(p, s));}

float smin( float a, float b, float smoothing ){

    float h = clamp( 0.5+0.5*(b-a)/smoothing, 0.0, 1.0 );
    return mix( b, a, h ) - smoothing*h*(1.0-h);
}

vec2 map(vec3 p)
{
	vec2 res = vec2(0.);
	
	float strateDisp = dot(strate(p.xy/2.7), vec3(.17));
	float strateNoise = snoise(p.zy/.67) *.17;
	
	float path = sinPath(p ,vec3(6.2, .33, 0.));

	float bottom = p.y + .7 - snoise(p.xz) * .38- snoise(p.xz/.039) * .05;
	res = vec2(bottom, 1.);

	float cyl = 0.;vec2 vecOld;
	for (float i=0.;i<6.;i++)
	{
		float x = 1. * i;
		float y	= .88 + 0.0102*i;
		float z	 = -0.02 -0.16*i;
		float r = 4.4 + 2.45 * i;
		vec2 vec = getCylinder(p, vec2(path, 3.7 * i), r , vec3(x,y,z), vec3(z,x,y)) +  strateDisp + strateNoise;
		cyl = r - smin(length(vec), length(vecOld), .28);
		vecOld = vec;	
	}

	if (cyl < res.x)
		res = vec2(cyl, 2.);
		
	return res;
}

vec3 nor( vec3 pos, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
		map(pos+e.xyy).x - map(pos-e.xyy).x,
		map(pos+e.yxy).x - map(pos-e.yxy).x,
		map(pos+e.yyx).x - map(pos-e.yyx).x );
    return normalize(n);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

// from iq code
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

// from iq code
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

const vec3 lig = vec3(-0.2, 1., -0.2);
vec3 lighting(vec3 col, vec3 p, vec3 n, vec3 rd, vec3 ref, float t) // lighting    
{
	// from iq code
	float occ = calcAO( p, n );
	float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
	float dif = clamp( dot( n, lig ), 0.0, 1.0 );
	float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
	float dom = smoothstep( -0.1, 0.1, ref.y );
	float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
	float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
        
	dif *= softshadow( p, lig, 0.02, 2.5 );
	dom *= softshadow( p, ref, 0.02, 2.5 );

	vec3 brdf = vec3(0.0);
	brdf += 1.20*dif*vec3(1.00,0.90,0.60);
	brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
	brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
	brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
	brdf += 0.02;
	col = col*brdf;

	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*t*t ) );
	
	return col;
}

void mainImage( out vec4 f, in vec2 g )
{
    vec2 si = iResolution.xy;
	vec2 uv = (g+g-si)/min(si.x, si.y);

    float t = iGlobalTime*5.;
	
	vec4 gp = vec4(0.,5.,0.,0.);//uGamePad360;
	
    vec3 cu = vec3(0,1,0);
    vec3 ro = vec3(gp.xy, t);
	vec3 cv = vec3(gp.zw*.01,.08); 
	vec3 rd = cam(uv, ro, cu, ro + cv);
    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
    vec2 s = vec2(DPrec.y,0.);
	
    for(int i=0;i<200;i++)
	{      
		if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
		d.x += s.x * (s.x>DPrec.x?RMPrec.x:RMPrec.y);
        p = ro+rd*d.x;
   	}
	
	if (d.x<DPrec.y)
	{
		vec3 n = nor(p, .05);
        
        float rug = 0.;
        if ( s.y < 1.5) rug = .75;	// sand
		else rug = .3; // wall
	
		f.rgb = vec3(.98,.76,.24) + OrenNayarLightModel(reflect(rd, n), rd, n, rug); // roughness
        f.rgb = lighting(f.rgb, p, n, rd, rd, d.x); // lighting    
   	}
}
