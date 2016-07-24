// Shader downloaded from https://www.shadertoy.com/view/4ljXWR
// written by shadertoy user aiekick
//
// Name: Repeat by Cos and Sin
// Description: A simple sphere with the shane func &quot;voronesque&quot; as displaced.
//    The sphere is repeated with some deformation due to the use of cos and sin instead of mod.
//    click on cell to see it fullscreen
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
A simple sphere with the shane func "voronesque" as displaced.
The sphere is repeated with some deformation due to the use of cos and sin instead of mod.
click on cell to see it fullscreen
*/

const vec2 gridSize = vec2(5.,4.);//grid size (columns, rows)
const vec3 lightDir = vec3(0.,1., 0.5);
const float mPi = 3.14159;
const float m2Pi = 6.28318;

float cellID = 0.;//global var for pilot hex func
float t = 0.;

vec3 OrenNayarLightModel(vec3 rd, vec3 ld, vec3 n)
{
	vec3 col = vec3(0.);
	float RDdotN = dot(-rd, n);
	float NdotLD = dot(n, ld);
    float aRDN = acos(RDdotN);
	float aNLD = acos(NdotLD);
	float mu = .33;
	float A = 1.-.5*mu*mu/(mu*mu+0.57);
    float B = .45*mu*mu/(mu*mu+0.09);
	float alpha = max(aRDN, aNLD);
	float beta = min(aRDN, aNLD);
	float albedo = 1.1;
	float e0 = 3.1;
	col = vec3(albedo / mPi) * cos(aNLD) * (A + ( B * max(0.,cos(aRDN - aNLD)) * sin(alpha) * tan(beta)))*e0;
	return col;
}

// from shane sahder : https://www.shadertoy.com/view/4lSXzh
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); 
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*262144.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w); 
    return max(v.x, v.y); 
}

vec2 df(vec3 p)
{
	vec2 res = vec2(1000.);
	
	// mat 1
	float plane = p.y + 1.;
	if (plane < res.x)
		res = vec2(plane, 1.);
		
	// mat 2
	vec3 q = p; // repeat by cos, sin instead of mod
	if (cellID == 0.) q = vec3(cos(p.x), p.y, p.z + sin(p.x));
	if (cellID == 1.) q = vec3(cos(p.x), p.y * 3., cos(p.z));
	if (cellID == 2.) q = vec3(cos(p.x - sin(p.y - t)), p.y, cos(p.z));
	if (cellID == 3.) q = vec3(cos(p.x + p.z), p.y, cos(p.z));
	if (cellID == 4.) q = vec3(cos(p.x + sin(p.z + t)), p.y * 3., cos(p.z));
	if (cellID == 5.) q = vec3(cos(p.x + sin(p.z + t)), p.y, cos(p.z * 3.));
	if (cellID == 6.) q = vec3(cos(p.x + sin(p.z)), p.y, cos(p.z) + sin(p.y + t));
	if (cellID == 7.) q = vec3(cos(p.x + cos(p.z)), p.y, cos(p.z) + sin(p.y + t));
	if (cellID == 8.) q = vec3(cos(p.x + cos(p.z)), p.y, cos(p.z + sin(p.x)) + sin(p.y + t));
	if (cellID == 9.) q = vec3(cos(p.x + sin(p.z)), p.y, cos(p.z + sin(p.z)));
	if (cellID == 10.) q = vec3(cos(p.x / 2. + sin(p.z)), p.y + cos(p.x) + sin(p.y), cos(p.z / 2. + sin(p.z / 2.)));
	if (cellID == 11.) q = vec3(cos(p.x / 2. + sin(p.z)), p.y + cos(p.x) + sin(p.y), cos(p.z / 2. + sin(p.z + p.x + t)));
	if (cellID == 12.) q = vec3(cos(p.x / 2. + sin(p.z + t)), p.y + cos(p.x) * sin(p.y + t), cos(p.z / 2. + sin(p.z / 2.)));
	if (cellID == 13.) q = vec3(cos(p.x), p.y + sin(p.x + t) + cos(p.z + t), cos(p.z));
	if (cellID == 14.) q = vec3(cos(p.x - t), p.y + cos(p.x), cos(p.z));
	if (cellID == 15.) q = vec3(cos(p.x - t), p.y + cos(p.x), cos(p.z + sin(p.z + t)));
    if (cellID == 16.) q = vec3(cos(p.x), p.y, cos(log(abs(p.z))+t));
    if (cellID == 17.) q = vec3(cos(p.x), p.y, cos(log2(abs(p.z))+t + sin(p.x)));
  	if (cellID == 18.) q = vec3(cos(log(abs(p.x))), p.y, cos(log2(abs(p.z))+t + sin(p.x)));
   	if (cellID == 19.) q = vec3(log(cos(abs(p.x))), p.y, log(cos(abs(p.z))));
   
	float voro = Voronesque(q);
	float sphere = length(q) - 1. + voro * (sin(-t * .05)*1.2-.6);
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
    for( int i=0; i<16; i++ )
    {
		float h = df( ro + rd*t ).x;
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
	float dif = clamp( dot( n, lightDir ), 0.0, 1.0 );
	float bac = clamp( dot( n, normalize(vec3(-lightDir.x,0.0,-lightDir.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
	float dom = smoothstep( -0.1, 0.1, ref.y );
	float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
	float spe = pow(clamp( dot( ref, lightDir ), 0.0, 1.0 ),16.0);
        
	dif *= softshadow( p, lightDir, 0.02, 2.5 );
	dom *= softshadow( p, ref, 0.02, 2.5 );

	vec3 brdf = vec3(0.0);
	brdf += 1.20*dif*vec3(1.00,0.90,0.60);
	brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
	brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
	brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
	brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
	brdf += 0.02;
	col = col * brdf;

	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*t*t ) );
	
	return col;
}

// encode id from coord // s:screenSize / h:pixelCoord / sz=gridSize
float EncID(vec2 s, vec2 h, vec2 sz) 
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    return cy*sz.x+cx;
}

// return id / uv // s:screenSize / h:pixelCoord / sz=gridSize
vec3 getcell(vec2 s, vec2 h, vec2 sz) 
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    
    float id = cy*sz.x+cx;
    
    vec2 size = s/sz;
    float ratio = size.x/size.y;
    vec2 uv = (2.*(h)-size)/size.y - vec2(cx*ratio,cy)*2.;
    uv*=1.5;
    
    return vec3(id, uv);
}

void mainImage( out vec4 f, in vec2 g )
{	
	vec2 si = iResolution.xy;
	vec2 mo = iMouse.xy;
    
	vec2 uv = (2.*g-si)/min(si.x, si.y);
	
	vec3 cell = getcell(si,g,gridSize);
    if(iMouse.z>0.) 
    {
        cell.x = EncID(si,mo,gridSize);
        cell.yz = uv;
    }
    
	t = iGlobalTime - 10.;
    
    cellID = cell.x; // global var : current cell used by mouse
	
	vec3 rayOrg = vec3(t,5,0);
	vec3 camUp = vec3(0,1,0);
	vec3 camOrg = rayOrg + vec3(1,-1,0); // translate the cam along the x axis
	
	float fov = .5;// fov seen in code from shane
	vec3 axisZ = normalize(camOrg - rayOrg);
	vec3 axisX = normalize(cross(camUp, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rayDir = normalize(axisZ + fov * cell.y * axisX + fov * cell.z * axisY);
	
    float dMax = 20.;
	float sMin = 0.01;
	
	vec2 s = vec2(sMin);
	float d = 0.;
    
	vec3 p = rayOrg + rayDir * d;
	
	for (int i=0; i<150; i++)
	{
		if (s.x<sMin || d>dMax) break;
		s = df(p);
		d += s.x * .2;
		p = rayOrg + rayDir * d;	
	}
	
	if (d<dMax)
	{
		vec3 p = rayOrg + rayDir * d;
		vec3 n = nor(p, 0.001);
		
		if (s.y < 1.5) // mat 1 : plane
		{
			// 	iq primitive shader : https://www.shadertoy.com/view/Xds3zN
			float r = mod( floor(5.0*p.z) + floor(5.0*p.x), 2.0);
            f.rgb = 0.4 + 0.1*r*vec3(1.0);
		}	
		else if (s.y < 2.5) // mat 2 : sphere
		{	
			f.rgb = OrenNayarLightModel(n, lightDir, vec3(.33));			
		}	

		f.rgb = lighting(f.rgb, p, n, rayDir, rayDir, d); // lighting    
	}
}