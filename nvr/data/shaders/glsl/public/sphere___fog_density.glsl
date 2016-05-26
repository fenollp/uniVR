// Shader downloaded from https://www.shadertoy.com/view/XljGDy
// written by shadertoy user iq
//
// Name: Sphere - fog density
// Description: Analytically integrating quadratically decaying participating media within a sphere. No raymarching involved.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Analytically integrating quadratically decaying participating media within a sphere. 
// No raymarching involved.
//
// Related info: http://iquilezles.org/www/articles/spherefunctions/spherefunctions.htm


//-------------------------------------------------------------------------------------------
// sphere related functions
//-------------------------------------------------------------------------------------------

float sphDensity( vec3  ro, vec3  rd,   // ray origin, ray direction
                  vec3  sc, float sr,   // sphere center, sphere radius
                  float dbuffer )       // depth buffer
{
    // normalize the problem to the canonical sphere
    float ndbuffer = dbuffer / sr;
    vec3  rc = (ro - sc)/sr;
	
    // find intersection with sphere
    float b = dot(rd,rc);
    float c = dot(rc,rc) - 1.0;
    float h = b*b - c;

    // not intersecting
    if( h<0.0 ) return 0.0;
	
    h = sqrt( h );
    
    //return h*h*h;

    float t1 = -b - h;
    float t2 = -b + h;

    // not visible (behind camera or behind ndbuffer)
    if( t2<0.0 || t1>ndbuffer ) return 0.0;

    // clip integration segment from camera to ndbuffer
    t1 = max( t1, 0.0 );
    t2 = min( t2, ndbuffer );

    // analytical integration of an inverse squared density
    float i1 = -(c*t1 + b*t1*t1 + t1*t1*t1/3.0);
    float i2 = -(c*t2 + b*t2*t2 + t2*t2*t2/3.0);
    return (i2-i1)*(3.0/4.0);
}

vec3 sphNormal( in vec3 pos, in vec4 sph )
{
    return normalize(pos-sph.xyz);
}

float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
    h = sqrt( h );
	return -b - h;
}

float sphOcclusion( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3  di = sph.xyz - pos;
    float l  = length(di);
    float nl = dot(nor,di/l);
    float h  = l/sph.w;
    float h2 = h*h;
    float k2 = 1.0 - h2*nl*nl;

    // above/below horizon: Quilez - http://iquilezles.org/www/articles/sphereao/sphereao.htm
    float res = max(0.0,nl)/h2;
    // intersecting horizon: Lagarde/de Rousiers - http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr.pdf
    if( k2 > 0.0 ) 
    {
        #if 1
            res = nl*acos(-nl*sqrt( (h2-1.0)/(1.0-nl*nl) )) - sqrt(k2*(h2-1.0));
            res = res/h2 + atan( sqrt(k2/(h2-1.0)));
            res /= 3.141593;
        #else
            // cheap approximation: Quilez
            res = pow( clamp(0.5*(nl*h+1.0)/h2,0.0,1.0), 1.5 );
        #endif
    }

    return res;
}

float plnIntersect( in vec3 ro, in vec3 rd, vec4 pln )
{
    return (pln.w - dot(ro,pln.xyz))/dot(rd,pln.xyz);
}

//=====================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
    
	vec3 ro = vec3(0.0, 0.2, 3.0 );
	vec3 rd = normalize( vec3(p,-3.0) );
	
    // sphere
    vec4 sph = vec4( cos( iGlobalTime*vec3(1.0,1.1,1.3) + vec3(2.0,1.5,1.5) + 0.0 )*vec3(1.5,0.3,0.7) + vec3(0.0,0.2,0.5), 1.4 );
    // planes
    vec4 pl1 = vec4(  0.0, 1.0, 0.0, 0.0 );
    vec4 pl2 = vec4(  1.0, 0.0, 0.0, 1.0 );
    vec4 pl3 = vec4( -1.0, 0.0, 0.0, 1.0 );
    vec4 pl4 = vec4(  0.0, 0.0,-1.0, 1.0 );
    
    float th = (-1.0+2.0*smoothstep( 0.8, 0.9, sin( iGlobalTime*1.0 )));
    th *= iResolution.x/iResolution.y;
    
    vec3 lig = normalize( vec3(0.6,0.3,0.4) );


    
    float t1 = sphIntersect( ro, rd, sph );
    float t2 = plnIntersect( ro, rd, pl1 );
    float t3 = plnIntersect( ro, rd, pl2 );
    float t4 = plnIntersect( ro, rd, pl3 );
    float t5 = plnIntersect( ro, rd, pl4 );
    
    float tmin = 1000.0;
    vec4  omin = vec4(0.0);
    if( t2>0.0 && t2<tmin ) { tmin=t2; omin=pl1; }
    if( t3>0.0 && t3<tmin ) { tmin=t3; omin=pl2; }
    if( t4>0.0 && t4<tmin ) { tmin=t4; omin=pl3; }
    if( t5>0.0 && t5<tmin ) { tmin=t5; omin=pl4; }

    vec3 col = vec3(0.0);
    
    if( tmin<999.0 )
    {    
        vec3 pos = ro + tmin*rd;

        col = vec3(0.1,0.15,0.2);
        col *= 0.8 + 0.4*dot(omin.xyz,lig);
        
        vec3 w = abs(omin.xyz);
        col = (texture2D( iChannel0, 0.5*pos.zx ).xyz*w.y+
               texture2D( iChannel0, 0.5*pos.xy ).xyz*w.z+
               texture2D( iChannel0, 0.5*pos.yz ).xyz*w.x)/(w.x+w.y+w.z);
        col *= 0.3;
        float occ = 1.0;
        occ *= smoothstep( 0.0, 0.5, length( pos.xy-vec2( 1.0, 0.0)));
        occ *= smoothstep( 0.0, 0.5, length( pos.xy-vec2(-1.0, 0.0)));
        occ *= smoothstep( 0.0, 0.5, length( pos.yz-vec2( 0.0,-1.0)));
        occ *= smoothstep( 0.0, 0.5, length( pos.xz-vec2( 1.0,-1.0)));
        occ *= smoothstep( 0.0, 0.5, length( pos.xz-vec2(-1.0,-1.0)));
        col *= vec3(0.4,0.3,0.2) + vec3(0.6,0.7,0.8)*occ;
        
        
        if( p.x<th )
        col *= 1.0 - 0.6*sphOcclusion( pos, omin.xyz, sph );
    }

    if( p.x<th && t1>0.0 && t1<tmin )
    {
        vec3 pos = ro + t1*rd;
        vec3 nor = sphNormal( pos, sph );
        
        col = vec3(0.3);
        
        float occ = 1.0;
        occ *= clamp( ( pos.x+1.0)*3.0, 0.0, 1.0 );
        occ *= clamp( (-pos.x+1.0)*3.0, 0.0, 1.0 );
        occ *= clamp( ( pos.y-0.0)*3.0, 0.0, 1.0 );
        occ *= clamp( ( pos.z+1.0)*3.0, 0.0, 1.0 );
        col *= 0.5 + 0.5*occ;
    }

    if( p.x>th )
    {
        float h = sphDensity(ro, rd, sph.xyz, sph.w, tmin );
        if( h>0.0 )
        {
            col = mix( col, vec3(0.2,0.5,1.0), h );
            col = mix( col, 1.15*vec3(1.0,0.9,0.6), h*h*h );
        }
    }
    
    col = sqrt( col );
    
    col *= smoothstep( 0.010,0.011,abs(p.x-th));
    
    fragColor = vec4( col, 1.0 );
}