// Shader downloaded from https://www.shadertoy.com/view/4djXDy
// written by shadertoy user iq
//
// Name: Box - occlusion
// Description: Analytical ambient occlusion of a box. Left side of screen, stochastically sampled occlusion. Right side of the screen, analytical solution (no rays casted). Move the mouse to compare.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Analytical ambient occlusion of a box. Left side of screen, stochastically 
// sampled occlusion. Right side of the screen, analytical solution (no rays casted).
//
// If the box was intersecting the ground plane, we'd need to perform clipping
// and use the resulting triangles for the analytic formula instead.
    

//=====================================================

// returns t and normal
vec4 boxIntersect( in vec3 ro, in vec3 rd, in mat4 txx, in mat4 txi, in vec3 rad ) 
{
    // convert from ray to box space
	vec3 rdd = (txx*vec4(rd,0.0)).xyz;
	vec3 roo = (txx*vec4(ro,1.0)).xyz;

	// ray-box intersection in box space
    vec3 m = 1.0/rdd;
    vec3 n = m*roo;
    vec3 k = abs(m)*rad;
	
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

	float tN = max( max( t1.x, t1.y ), t1.z );
	float tF = min( min( t2.x, t2.y ), t2.z );
	
	if( tN > tF || tF < 0.0) return vec4(-1.0);

	vec3 nor = -sign(rdd)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz);

    // convert to ray space
	
	nor = (txi * vec4(nor,0.0)).xyz;

	return vec4( tN, nor );
}


// Box occlusion (if fully visible)
float boxOcclusion( in vec3 pos, in vec3 nor, in mat4 txx, in mat4 txi, in vec3 rad ) 
{
	vec3 p = (txx*vec4(pos,1.0)).xyz;
	vec3 n = (txx*vec4(nor,0.0)).xyz;
    
    // 8 verts
    vec3 v0 = normalize( vec3(-1.0,-1.0,-1.0)*rad - p);
    vec3 v1 = normalize( vec3( 1.0,-1.0,-1.0)*rad - p);
    vec3 v2 = normalize( vec3(-1.0, 1.0,-1.0)*rad - p);
    vec3 v3 = normalize( vec3( 1.0, 1.0,-1.0)*rad - p);
    vec3 v4 = normalize( vec3(-1.0,-1.0, 1.0)*rad - p);
    vec3 v5 = normalize( vec3( 1.0,-1.0, 1.0)*rad - p);
    vec3 v6 = normalize( vec3(-1.0, 1.0, 1.0)*rad - p);
    vec3 v7 = normalize( vec3( 1.0, 1.0, 1.0)*rad - p);
    
    // 12 edges    
    float k02 = dot( n, normalize( cross(v2,v0)) ) * acos( dot(v0,v2) );
    float k23 = dot( n, normalize( cross(v3,v2)) ) * acos( dot(v2,v3) );
    float k31 = dot( n, normalize( cross(v1,v3)) ) * acos( dot(v3,v1) );
    float k10 = dot( n, normalize( cross(v0,v1)) ) * acos( dot(v1,v0) );
    float k45 = dot( n, normalize( cross(v5,v4)) ) * acos( dot(v4,v5) );
    float k57 = dot( n, normalize( cross(v7,v5)) ) * acos( dot(v5,v7) );
    float k76 = dot( n, normalize( cross(v6,v7)) ) * acos( dot(v7,v6) );
    float k37 = dot( n, normalize( cross(v7,v3)) ) * acos( dot(v3,v7) );
    float k64 = dot( n, normalize( cross(v4,v6)) ) * acos( dot(v6,v4) );
    float k51 = dot( n, normalize( cross(v1,v5)) ) * acos( dot(v5,v1) );
    float k04 = dot( n, normalize( cross(v4,v0)) ) * acos( dot(v0,v4) );
    float k62 = dot( n, normalize( cross(v2,v6)) ) * acos( dot(v6,v2) );
    
    // 6 faces    
    float occ = 0.0;
    occ += ( k02 + k23 + k31 + k10) * step( 0.0,  v0.z );
    occ += ( k45 + k57 + k76 + k64) * step( 0.0, -v4.z );
    occ += ( k51 - k31 + k37 - k57) * step( 0.0, -v5.x );
    occ += ( k04 - k64 + k62 - k02) * step( 0.0,  v0.x );
    occ += (-k76 - k37 - k23 - k62) * step( 0.0, -v6.y );
    occ += (-k10 - k51 - k45 - k04) * step( 0.0,  v0.y );
        
    return occ / 6.2831;
}

//-----------------------------------------------------------------------------------------

mat4 rotationAxisAngle( vec3 v, float angle )
{
    float s = sin( angle );
    float c = cos( angle );
    float ic = 1.0 - c;

    return mat4( v.x*v.x*ic + c,     v.y*v.x*ic - s*v.z, v.z*v.x*ic + s*v.y, 0.0,
                 v.x*v.y*ic + s*v.z, v.y*v.y*ic + c,     v.z*v.y*ic - s*v.x, 0.0,
                 v.x*v.z*ic - s*v.y, v.y*v.z*ic + s*v.x, v.z*v.z*ic + c,     0.0,
			     0.0,                0.0,                0.0,                1.0 );
}

mat4 translate( float x, float y, float z )
{
    return mat4( 1.0, 0.0, 0.0, 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 x,   y,   z,   1.0 );
}

mat4 inverse( in mat4 m )
{
	return mat4(
        m[0][0], m[1][0], m[2][0], 0.0,
        m[0][1], m[1][1], m[2][1], 0.0,
        m[0][2], m[1][2], m[2][2], 0.0,
        -dot(m[0].xyz,m[3].xyz),
        -dot(m[1].xyz,m[3].xyz),
        -dot(m[2].xyz,m[3].xyz),
        1.0 );
}


vec2 hash2( float n ) { return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123)); }

//-----------------------------------------------------------------------------------------

float iPlane( in vec3 ro, in vec3 rd )
{
    return (-1.0 - ro.y)/rd.y;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
    float s = (2.0*iMouse.x-iResolution.x) / iResolution.y;
    if( iMouse.z<0.001 ) s=0.0;

	vec3 ro = vec3(0.0, 0.0, 4.0 );
	vec3 rd = normalize( vec3(p.x, p.y-0.3,-3.5) );
	
    // box animation
	mat4 rot = rotationAxisAngle( normalize(vec3(1.0,1.0,0.0)), iGlobalTime );
	mat4 tra = translate( 0.0, 0.0, 0.0 );
	mat4 txi = tra * rot; 
	mat4 txx = inverse( txi );
	vec3 box = vec3(0.2,0.5,0.6) ;

    vec4 rrr = texture2D( iChannel0, (fragCoord.xy)/iChannelResolution[0].xy, -99.0  ).xzyw;

    vec3 col = vec3(0.0);

    float tmin = 1e10;
    
    float t1 = iPlane( ro, rd );
    if( t1>0.0 )
    {
        tmin = t1;
        vec3 pos = ro + tmin*rd;
        vec3 nor = vec3(0.0,1.0,0.0);
        float occ = 0.0;
        
        if( p.x > s )
        {
            occ = boxOcclusion( pos, nor, txx, txi, box );
        }
        else
        {
   		    vec3  ru  = normalize( cross( nor, vec3(0.0,1.0,1.0) ) );
		    vec3  rv  = normalize( cross( ru, nor ) );

            occ = 0.0;
            for( int i=0; i<512; i++ )
            {
                // cosine distribution
                vec2  aa = hash2( rrr.x + float(i)*203.111 );
                float ra = sqrt(aa.y);
                float rx = ra*cos(6.2831*aa.x); 
                float ry = ra*sin(6.2831*aa.x);
                float rz = sqrt( 1.0-aa.y );
                vec3  dir = vec3( rx*ru + ry*rv + rz*nor );
                vec4 res = boxIntersect( pos+nor*0.001, dir, txx, txi, box );
                occ += step(0.0,res.x);
            }
            occ /= 512.0;
        }

        col = vec3(1.1);
        col *= 1.0 - occ;
    }

    vec4 res = boxIntersect( ro, rd, txx, txi, box );
    float t2 = res.x;
    if( t2>0.0 && t2<tmin )
    {
        tmin = t2;
        float t = t2;
        vec3 pos = ro + t*rd;
        vec3 nor = res.yzw;
		col = vec3(0.8);

		vec3 opos = (txx*vec4(pos,1.0)).xyz;
		vec3 onor = (txx*vec4(nor,0.0)).xyz;
//		col *= abs(onor.x)*texture2D( iChannel1, 0.5+0.5*opos.yz ).xyz + 
  //             abs(onor.y)*texture2D( iChannel1, 0.5+0.5*opos.zx ).xyz + 
    //           abs(onor.z)*texture2D( iChannel1, 0.5+0.5*opos.xy ).xyz;
        col *= 1.7;
        col *= 0.6 + 0.4*nor.y;
	}

	col *= exp( -0.05*tmin );

    float e = 2.0/iResolution.y;
    col *= smoothstep( 0.0, 2.0*e, abs(p.x-s) );
    
    fragColor = vec4( col, 1.0 );
}