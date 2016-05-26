// Shader downloaded from https://www.shadertoy.com/view/Xls3WN
// written by shadertoy user aiekick
//
// Name: RM Spiral Displacement
// Description: sphere displacement of shader https://www.shadertoy.com/view/ldjSWD from toothmang
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define USE_SPHERE_OR_BOX
#define POSITIVE_DISPLACE

//////2D FUNC TO MODIFY////////////////////

// https://www.shadertoy.com/view/ldjSWD
#define alpha 0.0
#define beta 10.0

vec3 getCornerColors(vec2 coord)
{
    vec4 cornerColors[4];
	
    cornerColors[0] = vec4(1.0, 0, 0, 1.0);
    cornerColors[1] = vec4(0, 0, 1.0, 1.0);
    cornerColors[2] = vec4(0, 1.0, 0.0, 1.0);
    cornerColors[3] = vec4(1.0, 1.0, 0.0, 1.0);
        
    vec2 cornerCoords[4];
    cornerCoords[0] = vec2(0);
    cornerCoords[1] = vec2(1, 0);
    cornerCoords[2] = vec2(1);
    cornerCoords[3] = vec2(0, 1);

    
	vec4 result = vec4(0.0);

	float totalArea = dot(iResolution.xy, iResolution.xy);

	for(int i = 0; i < 4; i++)
	{
		vec2 cCoord = cornerCoords[i] * iResolution.xy;

		vec2 diff = coord - cCoord;

		float area = dot(diff, diff);

		result += ((totalArea - area) / totalArea) * cornerColors[i];
	}

	return result.rgb;
}

vec3 spiral4(vec2 coord)
{	
	float alpha_t = alpha - iGlobalTime * 50.0;

	float x = coord.x;
	float y = coord.y;

	float r = sqrt(dot(coord, coord));

	float phi = atan(y, x);

	float phi_r = (r - alpha_t) / beta;

	float r_phi = alpha_t + (beta * phi);

	float remainder = abs(cos(phi) - cos(phi_r));

	if (remainder < 0.5)
	{
		return vec3(0);
	}
	else
	{
		return vec3(remainder);
	}
}
vec3 effect(vec2 v) 
{
    v*=40.;
	return spiral4(v) * (getCornerColors(v) * 0.5);
}

///////FRAMEWORK////////////////////////////////////
vec4 displacement(vec3 p)
{
    vec3 col = effect(p.xz);
    
    col = clamp(col, vec3(0), vec3(1.));
    
    float dist = dot(col,vec3(0.1));
    
    return vec4(dist,col);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 3.;
    float dist = 0.;
    
    float x = 6.;
    float z = 6.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    #ifdef USE_SPHERE_OR_BOX
    	#ifdef POSITIVE_DISPLACE
        	dist = osphere(p, +5.-y);
    	#else
        	dist = osphere(p, +3.+y);
    	#endif
    #else    
        #ifdef POSITIVE_DISPLACE
        	if ( p.y > 0. ) dist = obox(p, vec3(x,1.-y,z));
        	else dist = obox(p, vec3(x,1.,z));
    	#else
        	if ( p.y > 0. ) dist = obox(p, vec3(x,y,z));
        	else dist = obox(p, vec3(x,1.,z));
    	#endif
	#endif
    
    return vec4(dist, disp.yzw);
}

///////////////////////////////////////////
//FROM IQ Shader https://www.shadertoy.com/view/Xds3zN
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

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.1, 0., 0. );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

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

///////////////////////////////////////////
float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec)
{
    float s = rmPrec;
    float d = 0.;
    for(int i=0;i<100;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x*mapPrec;
        d += s;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    #ifdef USE_SPHERE_OR_BOX
        float cam_e = 5.52; // elevation
        float cam_d = 1.88; // distance to origin axis
   	#else
        float cam_e = 1.; // elevation
        float cam_d = 1.8; // distance to origin axis
    #endif
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.3; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
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
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);
        
       	// lighting        
        float occ = calcAO( p, n );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, reflRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( reflRay, lig ), 0.0, 1.0 ),16.0);
        
        dif *= softshadow( p, lig, 0.02, 2.5 );
       	dom *= softshadow( p, reflRay, 0.02, 2.5 );

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