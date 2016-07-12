// Shader downloaded from https://www.shadertoy.com/view/ldfGDB
// written by shadertoy user iq
//
// Name: IntersectCoordSys
// Description: intersectRect(): intersects arbitrarily oriented 2D rectangles (or any other planar shape) in 3D. The rectangle/domain is defined by its center position and two orthogonal axes. The 2D intersection coordinates are computed by the function.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//================================================================================================
// (from http://www.iquilezles.org/blog/?p=2315)
//
// Say you want to intersect a ray with a planar coordinate system (a regular plane 
// with a center point and two perpendicular vectors defining a 2D coordinate system). 
// You are interesting in getting the distance to the intersection point along the ray (t), 
// and the 2D coordinates of the intersection point in the coordinates system of the 
// plane (s,t). So, given you ray with origin o and direction d, and your plane with 
// center c and generating vectors u and v, you can proceed in two ways:
//
// [1] The traditional way: computing the intersection with the plane (t), then project 
//     its relative position with respect to the center of the plane into the two 
//      coordinates axes (s,t).
//
// [2] The elegant way: solving the 3×3 linear system of equations for (r,s,t) all at once,
//     at a single step. You can do this by using Cramer’s law.
//
// The second solution, despite more expensive, turns out a lot more elegant (more symmetric 
// and regular, that is)
//================================================================================================

#if 1
//
// Elegant way to intersect a planar coordinate system (3x3 linear system)
//
vec3 intersectCoordSys( in vec3 o, in vec3 d, vec3 c, vec3 u, vec3 v )
{
	vec3 q = o - c;
	return vec3(
        dot( cross(u,v), q ),
		dot( cross(q,u), d ),
		dot( cross(v,q), d ) ) / 
        dot( cross(v,u), d );
}

#else
//
// Ugly (but faster) way to intersect a planar coordinate system: plane + projection
//
vec3 intersectCoordSys( in vec3 o, in vec3 d, vec3 c, vec3 u, vec3 v )
{
	vec3  q = o - c;
	vec3  n = cross(u,v);
    float t = -dot(n,q)/dot(d,n);
    float r =  dot(u,q + d*t);
    float s =  dot(v,q + d*t);
    return vec3(t,s,r);
}

#endif	

//================================================================================================

vec3 hash( in float x )
{
    return fract(sin(x+vec3(0.0,1.0,2.0))*vec3(43758.5453123,12578.1459123,19642.3490423));
}

float morph = smoothstep( 0.0, 0.4, sin(1.0*iGlobalTime) );

vec4 intersect( in vec3 ro, in vec3 rd )
{
	vec4 res = vec4(1e20, 0.0, 0.0, 0.0 );
	
	
	for( int i=0; i<64; i++ )
	{
		// position disk
		vec3 h = hash( float(i) );
	    vec3 r = 4.0*(-1.0 + 2.0*h);
		
        // orientate disk
		vec3 u = normalize( -1.0+2.0* hash( float(i)*13.1 ) );
        vec3 v = normalize( cross( u, vec3(0.0,1.0,0.0 ) ) );						   
		
        // intersect plane
        vec3 tmp = intersectCoordSys( ro, rd, r, u, v );
	
        // define shape		
		
		
	    float a = atan(tmp.y,tmp.z);
		float f1 = dot(tmp.yz*tmp.yz,tmp.yz*tmp.yz) - 1.0;
		float f2 = dot(tmp.yz,tmp.yz) - sqrt(0.5 + 0.5*sin(3.0*a));
		float f = mix( f1, f2, morph );
			
        // determine if closest intersection		
	    if( f<0.0 && tmp.x>0.0 && tmp.x<res.x ) 
	    {
			res = vec4( tmp.x, tmp.yz, float(i) );
	    }
	}

	return res;
}


vec3 shade( in vec3 pos, in vec4 res )
{
    vec3 col = 0.5 + 0.5*sin( 1.5*res.w/64.0 + vec3(0.0,1.0,3.0) );

    float a = atan(res.y,res.z);
	
	float ra1 = length(res.yz*res.yz);
	float ra2 = length(res.yz)/sqrt(0.5 + 0.5*sin(3.0*a));
	float ra  = mix( ra1, ra2, morph );
    col *= 1.0 - smoothstep( 0.8, 0.9, ra );
    col *= 1.3 - 0.3*ra;
	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	vec3 ro = 3.0*vec3(cos(0.25*iGlobalTime*1.1),0.0,sin(0.25*iGlobalTime*1.1));
    vec3 ta = vec3(0.0,0.0,0.0);
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    //-----------------------------------------------------
	// background
    //-----------------------------------------------------
	vec3 bgc = vec3(0.3) + 0.2*rd.y;
	
	vec3 col = bgc;

    //-----------------------------------------------------
	// raytrace
    //-----------------------------------------------------
    vec4 res = intersect( ro, rd );
	if( res.x<100.0 ) 
	{
		vec3 pos = ro + rd*res.x;
		col = shade( pos, res );
		col = mix( col, bgc, 1.0-exp(-0.01*res.x*res.x) );
	}

    fragColor = vec4( col, 1.0 );
}
