// Shader downloaded from https://www.shadertoy.com/view/MdfSDH
// written by shadertoy user iq
//
// Name: SH - directional lights
// Description: Testing 3-band SH encoding of directional lights. It compares the SH reconstruction to the ground truth.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Testing 3-band SH encoding for directional lights. 

// A lighting environment made of several directional lights is encoded in an SH
// representation by incrementally accumulating incoming directional lighting with 
// SH_AddLightDirectional(). At render time, the normal's SH is doted with the SH
// representation of the lighting to get the final color, by calling SH_Evalulate().

// More info here at  dickyjim's blog: 
// https://dickyjim.wordpress.com/2013/09/04/spherical-harmonics-for-beginners/

#define OPTIMIZED


//--------------------------------------------------------------------------------
// SH
//--------------------------------------------------------------------------------

#ifndef OPTIMIZED
#define PI 3.1415927
//
// slow version, but true to the mathematical formulation
//
void SH_AddLightDirectional( inout vec3 sh[9], in vec3 col, in vec3 v )
{
    #define NO  1.0        // for perfect overal brigthness match
  //#define NO (16.0/17.0) // for normalizing to maximum = 1.0;
    sh[0] += col * (NO*PI*1.000) * (0.50*sqrt( 1.0/PI));
    sh[1] += col * (NO*PI*0.667) * (0.50*sqrt( 3.0/PI)) * v.x;
    sh[2] += col * (NO*PI*0.667) * (0.50*sqrt( 3.0/PI)) * v.y;
    sh[3] += col * (NO*PI*0.667) * (0.50*sqrt( 3.0/PI)) * v.z;
    sh[4] += col * (NO*PI*0.250) * (0.50*sqrt(15.0/PI)) * v.x*v.z;
    sh[5] += col * (NO*PI*0.250) * (0.50*sqrt(15.0/PI)) * v.z*v.y;
    sh[6] += col * (NO*PI*0.250) * (0.50*sqrt(15.0/PI)) * v.y*v.x;
    sh[7] += col * (NO*PI*0.250) * (0.25*sqrt( 5.0/PI)) * (3.0*v.z*v.z-1.0);
    sh[8] += col * (NO*PI*0.250) * (0.25*sqrt(15.0/PI)) * (v.x*v.x-v.y*v.y);
}

vec3 SH_Evalulate( in vec3 v, in vec3 sh[9] )
{
    return sh[0] * (0.50*sqrt( 1.0/PI)) +
           sh[1] * (0.50*sqrt( 3.0/PI)) * v.x +
           sh[2] * (0.50*sqrt( 3.0/PI)) * v.y +
           sh[3] * (0.50*sqrt( 3.0/PI)) * v.z +
           sh[4] * (0.50*sqrt(15.0/PI)) * v.x*v.z +
           sh[5] * (0.50*sqrt(15.0/PI)) * v.z*v.y +
           sh[6] * (0.50*sqrt(15.0/PI)) * v.y*v.x +
           sh[7] * (0.25*sqrt( 5.0/PI)) * (3.0*v.z*v.z-1.0) +
           sh[8] * (0.25*sqrt(15.0/PI)) * (v.x*v.x-v.y*v.y);
}

#else

//
// fast version, premultiplied components and simplified terms
//
void SH_AddLightDirectional( inout vec3 sh[9], in vec3 col, in vec3 v )
{
     #define DI 64.0  // for perfect overal brigthness match
   //#define DI 68.0  // for normalizing to maximum = 1.0;
	
	sh[0] += col * (21.0/DI);
	sh[0] -= col * (15.0/DI) * v.z*v.z;
	sh[1] += col * (32.0/DI) * v.x;
	sh[2] += col * (32.0/DI) * v.y;
	sh[3] += col * (32.0/DI) * v.z;
	sh[4] += col * (60.0/DI) * v.x*v.z;
	sh[5] += col * (60.0/DI) * v.z*v.y;
	sh[6] += col * (60.0/DI) * v.y*v.x;
	sh[7] += col * (15.0/DI) * (3.0*v.z*v.z-1.0);
	sh[8] += col * (15.0/DI) * (v.x*v.x-v.y*v.y);
}

void SH_AddDome( inout vec3 sh[9], in vec3 colA, in vec3 colB )
{
	sh[0] += 0.5*(colB + colA);
	sh[2] += 0.5*(colB - colA);
}


vec3 SH_Evalulate( in vec3 v, in vec3 sh[9] )
{
	return sh[0] +
           sh[1] * v.x +
           sh[2] * v.y +
           sh[3] * v.z +
           sh[4] * v.x*v.z +
           sh[5] * v.z*v.y +
           sh[6] * v.y*v.x +
           sh[7] * v.z*v.z +
           sh[8] *(v.x*v.x-v.y*v.y);
}
#endif

//--------------------------------------------------------------------------------
// test
//--------------------------------------------------------------------------------

vec3  lig1 = normalize( vec3(1.0, 1.0, 1.0) );
vec3  lig2 = normalize( vec3(1.0,-1.0, 0.1) );
vec3  lig3 = normalize( vec3(0.0, 0.2,-1.0) );
vec3  lig4 = normalize( vec3(0.5, 0.8,-0.5) );

vec3 lco1 = vec3(1.0,0.2,0.0);
vec3 lco2 = vec3(0.0,1.0,0.0);
vec3 lco3 = vec3(0.0,0.0,1.0);
vec3 lco4 = vec3(1.0,0.9,0.0);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

     // camera movement	
	float an = 0.2*iGlobalTime - 10.0*iMouse.x/iResolution.x;
	vec3 ro = vec3( 2.5*sin(an), 0.0, 2.5*cos(an) );
    vec3 ta = vec3( 0.0, 0.0, 0.0 );
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

	vec3 col = vec3(0.4);

    // Prec-encode the lighting as SH coefficients (you'd usually do this only once)
	vec3 sh[9];
	sh[0] = vec3(0.0);
	sh[1] = vec3(0.0);
	sh[2] = vec3(0.0);
	sh[3] = vec3(0.0);
	sh[4] = vec3(0.0);
	sh[5] = vec3(0.0);
	sh[6] = vec3(0.0);
	sh[7] = vec3(0.0);
	sh[8] = vec3(0.0);
	SH_AddLightDirectional( sh, lco1, lig1 );
	SH_AddLightDirectional( sh, lco2, lig2 );
	SH_AddLightDirectional( sh, lco3, lig3 );
	SH_AddLightDirectional( sh, lco4, lig4 );

	// raytrace-sphere
	vec3  ce = ro;
	float b = dot( rd, ce );
	float c = dot( ce, ce ) - 1.0;
	float h = b*b - c;
	if( h>0.0 )
	{
		h = -b - sqrt(h);
		vec3 pos = ro + h*rd;
		vec3 nor = normalize(pos); 
		
		// compare regular lighting...
		if( sin(6.2831*iGlobalTime)>0.0 )
        {
			col  = lco1*clamp( dot(nor,lig1), 0.0, 1.0 );
            col += lco2*clamp( dot(nor,lig2), 0.0, 1.0 );
            col += lco3*clamp( dot(nor,lig3), 0.0, 1.0 );
            col += lco4*clamp( dot(nor,lig4), 0.0, 1.0 );
        }
        // ... with SH lighting
        else			
        {
            col = SH_Evalulate( nor, sh );
        }
	}
	col *= 0.6;
	fragColor = vec4( col, 1.0 );
}