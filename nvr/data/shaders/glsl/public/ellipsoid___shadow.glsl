// Shader downloaded from https://www.shadertoy.com/view/ltsSzn
// written by shadertoy user iq
//
// Name: Ellipsoid - shadow
// Description: Ellipsoid - ray intersection, shadow and normal. 
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Compute fake soft shadows for sphere objects. Can see this in action here: 
// https://www.shadertoy.com/view/XdjXWK



//-------------------------------------------------------------------------------------------
// ellipsoid related functions
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
    Ellipsoid sph = Ellipsoid( vec3(0.0,0.25,0.0) + vec3(1.0,0.5,1.0)*cos( iGlobalTime*0.1 + vec3(2.0,1.0,1.0) + 0.0 )*vec3(1.5,0.5,1.0), 
                               vec3(1.0,0.6,1.0) + vec3(0.5,0.5,0.5)*cos( iGlobalTime*0.31 + vec3(0.0,0.71,2.71) ) );

    vec3 lig = normalize( vec3(0.6,0.3,0.4) );
    vec3 col = vec3(0.0);

    float tmin = 1e10;
    vec3 nor;
    
    float t1 = iPlane( ro, rd );
    if( t1>0.0 )
    {
        tmin = t1;
        vec3 pos = ro + t1*rd;
        nor = vec3(0.0,1.0,0.0);
    }

    float t2 = eliIntersect( ro, rd, sph );
    if( t2>0.0 && t2<tmin )
    {
        tmin = t2;
        vec3 pos = ro + t2*rd;
        nor = eliNormal( pos, sph );
	}
    
    if( tmin<1000.0 )
    {
        vec3 pos = ro + tmin*rd;
        
		col = vec3(1.0);
        col *= clamp( dot(nor,lig), 0.0, 1.0 );
        col *= eliShadow( pos + nor*0.001, lig, sph, 8.0 );
        col += 0.05*(0.5+0.5*nor.y);
	    col *= exp( -0.05*tmin );
    }

    col = sqrt(col);
    fragColor = vec4( col, 1.0 );
}