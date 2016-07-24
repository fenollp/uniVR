// Shader downloaded from https://www.shadertoy.com/view/4sXXRN
// written by shadertoy user iq
//
// Name: Triangle - distance 3D
// Description: Distance field to a triangle. Of course, some thickness has to be given to the polygon (or mesh if you had one) in order to make it renderable.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// It computes the distance to a triangle.

// In case a whole mesh was rendered, only one square root would be needed for the
// whole mesh.

// In this example the triangle is given a thckness of 0.01 units (line 42). Like the
// square root, this thickness should be added only once for the whole mesh too.

float dot2( in vec3 v ) { return dot(v,v); }

float udTriangle( in vec3 v1, in vec3 v2, in vec3 v3, in vec3 p )
{
    vec3 v21 = v2 - v1; vec3 p1 = p - v1;
    vec3 v32 = v3 - v2; vec3 p2 = p - v2;
    vec3 v13 = v1 - v3; vec3 p3 = p - v3;
    vec3 nor = cross( v21, v13 );

    return sqrt( (sign(dot(cross(v21,nor),p1)) + 
                  sign(dot(cross(v32,nor),p2)) + 
                  sign(dot(cross(v13,nor),p3))<2.0) 
                  ?
                  min( min( 
                  dot2(v21*clamp(dot(v21,p1)/dot2(v21),0.0,1.0)-p1), 
                  dot2(v32*clamp(dot(v32,p2)/dot2(v32),0.0,1.0)-p2) ), 
                  dot2(v13*clamp(dot(v13,p3)/dot2(v13),0.0,1.0)-p3) )
                  :
                  dot(nor,p1)*dot(nor,p1)/dot2(nor) );
}

//=====================================================

float map( in vec3 p )
{
    // triangle	
	vec3 v1 = 1.5*cos( iGlobalTime + vec3(0.0,1.0,1.0) + 0.0 );
	vec3 v2 = 1.0*cos( iGlobalTime + vec3(0.0,2.0,3.0) + 2.0 );
	vec3 v3 = 1.0*cos( iGlobalTime + vec3(0.0,3.0,5.0) + 4.0 );
	float d1 = udTriangle( v1, v2, v3, p ) - 0.01;

    // ground plane
	float d2 = p.y + 1.0;

    return min( d1, d2 );	
}

float intersect( in vec3 ro, in vec3 rd )
{
	const float maxd = 10.0;
	float h = 1.0;
    float t = 0.0;
    for( int i=0; i<50; i++ )
    {
        if( h<0.001 || t>maxd ) break;
	    h = map( ro+rd*t );
        t += h;
    }

    if( t>maxd ) t=-1.0;
	
    return t;
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.002,0.0,0.0);

	return normalize( vec3(
           map(pos+eps.xyy) - map(pos-eps.xyy),
           map(pos+eps.yxy) - map(pos-eps.yxy),
           map(pos+eps.yyx) - map(pos-eps.yyx) ) );
}

float calcSoftshadow( in vec3 ro, in vec3 rd, float k )
{
    float res = 1.0;
    float t = 0.0;
	float h = 1.0;
    for( int i=0; i<20; i++ )
    {
        h = map(ro + rd*t);
        res = min( res, k*h/t );
		t += clamp( h, 0.01, 1.0 );
		if( h<0.0001 ) break;
    }
    return clamp(res,0.0,1.0);
}

float calcOcclusion( in vec3 pos, in vec3 nor )
{
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.02 + 0.025*float(i*i);
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return 1.0 - clamp( occ, 0.0, 1.0 );
}

vec3 lig = normalize(vec3(1.0,0.9,0.7));

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;

	vec3 ro = vec3(0.0, 0.25, 2.0 );
	vec3 rd = normalize( vec3(p,-1.0) );
	
	vec3 col = vec3(0.0);

    float t = intersect(ro,rd);
    if( t>0.0 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);
		float sha = calcSoftshadow( pos + nor*0.01, lig, 32.0 );
		float occ = calcOcclusion( pos, nor );
		col =  vec3(0.9,0.6,0.3)*clamp( dot( nor, lig ), 0.0, 1.0 ) * sha;
		col += vec3(0.5,0.6,0.7)*clamp( nor.y, 0.0, 1.0 )*occ;
        col += 0.03;
		col *= exp( -0.2*t );
        col *= 1.0 - smoothstep( 5.0, 10.0, t );
	}

	col = pow( clamp(col,0.0,1.0), vec3(0.45) );
	   
    fragColor = vec4( col, 1.0 );
}

