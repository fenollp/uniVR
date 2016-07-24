// Shader downloaded from https://www.shadertoy.com/view/4ts3DB
// written by shadertoy user iq
//
// Name: Distance - PN Continuous
// Description: Subdivision / Tesselation of a piecewise linear shape into a cubic, by means of PN-Triangle like tesselation/. I implemented a a cheap but inaccurate (in short distances) way to compute distances, and a brute force one for comparison.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Subdividing a piecewise linear shape into a cubic shape with continuity, ala PN-Triangles,
// but in 2D (or in other words, with bezier curves)

// I have implemented two different version of the distance to the cubic. One is cheap and only
// works for concave shapes. It fails at short distances, but is good enough in the distance. The
// other one is a brute force one, for comparison.

// Linear segments in red, cheap approximation in green, brute force in blue

// Every other cycle derivatives are shown to judge the quality of the field.



float length2( in vec2 v ) { return dot(v,v); }

float sdLine2( vec2 p, vec2 a, vec2 b )
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length2( pa - ba*h );
}

vec2 cubic( in vec2 a, in vec2 b, in vec2 c, in vec2 d, float v1 )
{
    float u1 = 1.0 - v1;
    float u2 = u1*u1;
    float v2 = v1*v1;
    float u3 = u2*u1;
    float v3 = v2*v1;
    return a*u3 + d*v3 + b*3.0*u2*v1 + c*3.0*u1*v2;
}

//----------------------------------------------------------

float sdSegment_Cheap( vec2 p, vec2 a, vec2 b, vec2 na, vec2 nb )
{
    // secondary points
    vec2 k1 = (a*2.0+b)/3.0; k1 = a + na*dot(na,k1-a)/dot(na,na);
    vec2 k2 = (b*2.0+a)/3.0; k2 = b + nb*dot(nb,k2-b)/dot(nb,nb);

	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );

    return sqrt( sdLine2( p, cubic( a, k1, k2, b, clamp( h-0.1, 0.0, 1.0) ), 
                             cubic( a, k1, k2, b, clamp( h+0.1, 0.0, 1.0) ) ) );
}

float sdSegment_Expensive( vec2 p, vec2 a, vec2 b, vec2 na, vec2 nb )
{
    // secondary points
    vec2 k1 = (a*2.0+b)/3.0; k1 = a + na*dot(na,k1-a)/dot(na,na);
    vec2 k2 = (b*2.0+a)/3.0; k2 = b + nb*dot(nb,k2-b)/dot(nb,nb);
    
    float md = length2(p-a);
    vec2 ov = a;
    for( int i=1; i<32; i++ )
    {
        vec2 v = cubic( a, k1, k2, b, float(i+0)/31.0 );
        float di = sdLine2( p, v, ov ); ov = v;
        md = min( di, md );
    }

    return sqrt(md);
}


//======================================================

// shape points

vec2 p0 = vec2( 0.6, 0.1)*1.3;
vec2 p1 = vec2( 0.4, 0.3)*1.3;
vec2 p2 = vec2(-0.2, 0.5)*1.3;
vec2 p3 = vec2(-0.6, 0.4)*1.3;
vec2 p4 = vec2(-0.8, 0.1)*1.3;
vec2 p5 = vec2(-0.7,-0.1)*1.3;
vec2 p6 = vec2( 0.0,-0.2)*1.3;
vec2 p7 = vec2( 0.7,-0.2)*1.3;

#if 0

// bad shape tangents

vec2 t0 = p1-p7;
vec2 t1 = p2-p0;
vec2 t2 = p3-p1;
vec2 t3 = p4-p2;
vec2 t4 = p5-p3;
vec2 t5 = p6-p4;
vec2 t6 = p7-p5;
vec2 t7 = p0-p6;

#else

// shape normals

vec2 n01 = normalize(p1-p0);
vec2 n12 = normalize(p2-p1);
vec2 n23 = normalize(p3-p2);
vec2 n34 = normalize(p4-p3);
vec2 n45 = normalize(p5-p4);
vec2 n56 = normalize(p6-p5);
vec2 n67 = normalize(p7-p6);
vec2 n70 = normalize(p0-p7);

// good shape tangents

vec2 t0 = n70+n01;
vec2 t1 = n01+n12;
vec2 t2 = n12+n23;
vec2 t3 = n23+n34;
vec2 t4 = n34+n45;
vec2 t5 = n45+n56;
vec2 t6 = n56+n67;
vec2 t7 = n67+n70;

#endif

//======================================================

// distance to linear segments
float cDistance( in vec2 v )
{
    float d0 = sdLine2( v, p0, p1 );
    float d1 = sdLine2( v, p1, p2 );
    float d2 = sdLine2( v, p2, p3 );
    float d3 = sdLine2( v, p3, p4 );
    float d4 = sdLine2( v, p4, p5 );
    float d5 = sdLine2( v, p5, p6 );
    float d6 = sdLine2( v, p6, p7 );
    float d7 = sdLine2( v, p7, p0 );
    return sqrt( min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7))))))) );
}

// distance to cubic segment
float dDistance_Cheap( in vec2 v )
{
    float d0 = sdSegment_Cheap( v, p0, p1, t0, t1 );
    float d1 = sdSegment_Cheap( v, p1, p2, t1, t2 );
    float d2 = sdSegment_Cheap( v, p2, p3, t2, t3 );
    float d3 = sdSegment_Cheap( v, p3, p4, t3, t4 );
    float d4 = sdSegment_Cheap( v, p4, p5, t4, t5 );
    float d5 = sdSegment_Cheap( v, p5, p6, t5, t6 );
    float d6 = sdSegment_Cheap( v, p6, p7, t6, t7 );
    float d7 = sdSegment_Cheap( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

// distance to cubic segment
float dDistance_Expensive( in vec2 v )
{
    float d0 = sdSegment_Expensive( v, p0, p1, t0, t1 );
    float d1 = sdSegment_Expensive( v, p1, p2, t1, t2 );
    float d2 = sdSegment_Expensive( v, p2, p3, t2, t3 );
    float d3 = sdSegment_Expensive( v, p3, p4, t3, t4 );
    float d4 = sdSegment_Expensive( v, p4, p5, t4, t5 );
    float d5 = sdSegment_Expensive( v, p5, p6, t5, t6 );
    float d6 = sdSegment_Expensive( v, p6, p7, t6, t7 );
    float d7 = sdSegment_Expensive( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

//====================================================================================

vec3 profile( vec3 x )
{
    x = mod( x, 12.0 );
    return clamp(x,0.0,1.0) - clamp(x-4.0,0.0,1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float m = min(iResolution.x,iResolution.y);
    vec2  p = (-iResolution.xy+2.0*fragCoord.xy) / m;

    float c = cDistance( p );
    float d = dDistance_Cheap( p );
    float e = dDistance_Expensive( p );
    
    float t = iGlobalTime + 4.0;
    
    vec3  w = profile( 2.0*t + 12.0 - vec3(0.0,4.0,8.0) );
    float a = smoothstep(5.5,6.5,mod(t,12.0));
    
    float f = c*w.x + d*w.y + e*w.z;
    
    
    vec3 col = vec3(1.0,1.0,1.0)*clamp( 0.75*f, 0.0, 1.0 ) + 0.02*smoothstep(0.8,0.9,sin(100.0*f));
    
    col = mix( col, (0.5+0.25*m*vec3(dFdx(f),dFdy(f),0.0))*exp(-f), a );

        
    col = mix( col, (0.25 + 0.75*w)*(1.0-a), 1.0-smoothstep(0.0,0.01,f) );
    
    
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p0)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p1)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p2)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p3)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p4)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p5)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p6)) );
    col = mix( col, vec3(1.0,1.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p7)) );

	fragColor = vec4( col, 1.0 );
}