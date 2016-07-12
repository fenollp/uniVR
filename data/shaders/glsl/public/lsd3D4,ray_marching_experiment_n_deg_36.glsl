// Shader downloaded from https://www.shadertoy.com/view/lsd3D4
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&deg;36
// Description: Ray Marching Experiment n&deg;36
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

#define SMOOTH 0.
// thick 0.01 is like weird planet
#define THICK 0.1

///////////////////////////////////////////
vec4 displacement(vec3 p)
{
    p/=5.;
	vec2 uv = vec2(length(p.xz));
	uv.x -= mod(iGlobalTime, 10.)*.1;
	vec4 tex = texture2D(iChannel1, uv, SMOOTH);
	vec4 bump = texture2D(iChannel2, p.xz, SMOOTH);
	float dist = dot(mix(tex,bump,uv.y/p.y), vec4(THICK));
	return vec4(dist, tex.rgb); 
}

vec4 map(vec3 p)
{
    p.y = abs(p.y);
   	vec4 disp = displacement(p);
  	float dist = length(p) -4. - smoothstep(0., 1., disp.x) * 3.;
    return vec4(dist, disp.yzw);
}

///////////////////////////////////////////
//FROM IQ Shader https://www.shadertoy.com/view/Xds3zN
float sha( in vec3 ro, in vec3 rd, in float mint, in float tmax )
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

float aoc( in vec3 pos, in vec3 nor )
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


///////////////////////////////////////////
vec3 nor( in vec3 p, float prec )
{
	vec2 e = vec2( prec, 0.);
	vec3 n = vec3(
	    map(p+e.xyy).x - map(p-e.xyy).x,
	    map(p+e.yxy).x - map(p-e.yxy).x,
	    map(p+e.yyx).x - map(p-e.yyx).x );
	return normalize(n);
}

float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec)
{
    float s = rmPrec;
    float d = 0.;
    for(int i=0;i<200;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x;
		s *= (s>0.1?0.2:0.01);
        d += s;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime * 0.1;
    float cam_a = time; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 1.88; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 4.5; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.3; // ray marching tolerance precision
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = march(ro, rd, prec, maxd, marchPrecision);
    
    if (d<maxd)
    {
        vec3 p = ro+rd*d;
        vec3 n = nor(p, 0.1);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);
        
       	// lighting        
        float occ = aoc( p, n );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, reflRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( reflRay, lig ), 0.0, 1.0 ),16.0);
        
        dif *= sha( p, lig, 0.02, 2.5 );
       	dom *= sha( p, reflRay, 0.02, 2.5 );

		vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
		brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
        brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
		brdf += 0.02;
		col = col*brdf;

    	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}

