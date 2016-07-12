// Shader downloaded from https://www.shadertoy.com/view/llsSzn
// written by shadertoy user iq
//
// Name: Ellipsoid - soft shadow
// Description: Ellipsoid - soft shadow (approximation)
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Compute fake soft shadows for ellipsode objects.


//-------------------------------------------------------------------------------------------
// sphere related functions
//-------------------------------------------------------------------------------------------

struct Ellipsoid
{
    vec3 cen;
    vec3 rad;
};

float eliShadow( in vec3 ro, in vec3 rd, in Ellipsoid sph, in float k )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );

    if( b>0.0 || (b*b-a*(c-1.0))<0.0 ) return 1.0;
    
    return 0.0;
}

float eliSoftShadow( in vec3 ro, in vec3 rd, in Ellipsoid sph, in float k )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );
	float h = b*b - a*(c-1.0);


    float t = (-b - sqrt( max(h,0.0) ))/a;

    return (h>0.0) ? step(t,0.0) : smoothstep(0.0, 1.0, -k*h/max(t,0.0) );
}    
            
vec3 eliNormal( in vec3 pos, in Ellipsoid sph )
{
    return normalize( (pos-sph.cen)/sph.rad );
}


float eliIntersect( in vec3 ro, in vec3 rd, in Ellipsoid sph )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );
	float h = b*b - a*(c-1.0);
	if( h<0.0 ) return -1.0;
	return (-b - sqrt( h ))/a;
}

//=====================================================

vec2 hash2( float n ) { return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123)); }

float iPlane( in vec3 ro, in vec3 rd )
{
    return (-1.0 - ro.y)/rd.y;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
    
	vec3 ro = vec3(0.0, 0.0, 4.0 );
	vec3 rd = normalize( vec3(p,-2.0) );
	
    // sphere animation
    Ellipsoid sph = Ellipsoid( cos( iGlobalTime + vec3(2.0,1.0,1.0) + 0.0 )*vec3(1.5,0.0,1.0), 
                               vec3(1.5,0.8,1.0) );

    vec3 lig = normalize( vec3(0.6,0.3,0.4) );
    vec3 col = vec3(0.0);

    float tmin = 1e10;
    vec3 nor;
    float occ = 1.0;
    
    float t1 = iPlane( ro, rd );
    if( t1>0.0 )
    {
        tmin = t1;
        vec3 pos = ro + t1*rd;
        nor = vec3(0.0,1.0,0.0);
        occ = 1.0;
    }

    float t2 = eliIntersect( ro, rd, sph );
    if( t2>0.0 && t2<tmin )
    {
        tmin = t2;
        vec3 pos = ro + t2*rd;
        nor = eliNormal( pos, sph );
        occ = 0.5 + 0.5*nor.y;
	}
    
    if( tmin<1000.0 )
    {
        vec3 pos = ro + tmin*rd;
        
		col = vec3(1.0);
        col *= clamp( dot(nor,lig), 0.0, 1.0 );
        col *= eliSoftShadow( pos + nor*0.01, lig, sph, 2.0 );
        col += 0.05*occ;
	    col *= exp( -0.05*tmin );
    }

    col = sqrt(col);
    fragColor = vec4( col, 1.0 );
}