// Shader downloaded from https://www.shadertoy.com/view/MlsGWS
// written by shadertoy user iq
//
// Name: Distance - PN Static
// Description: Statically subdividing a set of segments into 8 times the number of segments in a cubic manner. See [url]https://www.shadertoy.com/view/4ts3DB[/url] for more information.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Tesselating a set of segments with a cubic bezier (PN-segmetns), quite like
// https://www.shadertoy.com/view/4ts3DB, but statically.

float sdLine( vec2 p, vec2 a, vec2 b )
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

// cubic polynomial evaluated at fixed points t = i/8, i = 0, 1, 2, ... 8
//
// p(t) = a*t^3 + d*(1-t)^3 + 3b*t^2*(1-t) + 3c*t*(1-t)^2;
//
vec2 cubic_0d000( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return a; }
vec2 cubic_0d125( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a*343.0 + b*147.0 + c*21.0 + d)/512.0; }
vec2 cubic_0d250( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a*27.0 + b*27.0 + c*9.0 + d)/64.0; }
vec2 cubic_0d375( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a*125.0 + b*225.0 + c*135.0 + d*27.0)/512.0; }
vec2 cubic_0d500( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a + b*3.0 + c*3.0 + d)/8.0; }
vec2 cubic_0d625( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a*27.0 + b*135.0 + c*225.0 + d*125.0)/512.0; }
vec2 cubic_0d750( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a + b*9.0 + c*27.0 + d*27.0)/64.0; }
vec2 cubic_0d875( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return (a + b*21.0 + c*147.0 + d*343.0)/512.0; }
vec2 cubic_1d000( in vec2 a, in vec2 b, in vec2 c, in vec2 d ) { return d; }

//----------------------------------------------------------
float sdSegment_1( vec2 p, vec2 a, vec2 d, vec2 na, vec2 nd )
{
    return sdLine( p, a, d );
}

float sdSegment_2( vec2 p, vec2 a, vec2 d, vec2 na, vec2 nd )
{
    // secondary points
    vec2 b = (a*2.0+d)/3.0; b = a + na*dot(na,b-a)/dot(na,na);
    vec2 c = (d*2.0+a)/3.0; c = d + nd*dot(nd,c-d)/dot(nd,nd);

    float r = length(p-a);
    
    vec2 k0 = cubic_0d000( a, b, c, d );
    vec2 k1 = cubic_0d500( a, b, c, d );
    vec2 k2 = cubic_1d000( a, b, c, d );

    r = min( r, sdLine( p, k0, k1 ) );
    r = min( r, sdLine( p, k1, k2 ) );
    
    return r;
}

float sdSegment_4( vec2 p, vec2 a, vec2 d, vec2 na, vec2 nd )
{
    // secondary points
    vec2 b = (a*2.0+d)/3.0; b = a + na*dot(na,b-a)/dot(na,na);
    vec2 c = (d*2.0+a)/3.0; c = d + nd*dot(nd,c-d)/dot(nd,nd);

    float r = length(p-a);
    
    vec2 k0 = cubic_0d000( a, b, c, d );
    vec2 k1 = cubic_0d250( a, b, c, d );
    vec2 k2 = cubic_0d500( a, b, c, d );
    vec2 k3 = cubic_0d750( a, b, c, d );
    vec2 k4 = cubic_1d000( a, b, c, d );

    r = min( r, sdLine( p, k0, k1 ) );
    r = min( r, sdLine( p, k1, k2 ) );
    r = min( r, sdLine( p, k2, k3 ) );
    r = min( r, sdLine( p, k3, k4 ) );
    
    return r;
}

float sdSegment_8( vec2 p, vec2 a, vec2 d, vec2 na, vec2 nd )
{
    // secondary points
    vec2 b = (a*2.0+d)/3.0; b = a + na*dot(na,b-a)/dot(na,na);
    vec2 c = (d*2.0+a)/3.0; c = d + nd*dot(nd,c-d)/dot(nd,nd);

    float r = length(p-a);
    
    vec2 k0 = cubic_0d000( a, b, c, d );
    vec2 k1 = cubic_0d125( a, b, c, d );
    vec2 k2 = cubic_0d250( a, b, c, d );
    vec2 k3 = cubic_0d375( a, b, c, d );
    vec2 k4 = cubic_0d500( a, b, c, d );
    vec2 k5 = cubic_0d625( a, b, c, d );
    vec2 k6 = cubic_0d750( a, b, c, d );
    vec2 k7 = cubic_0d875( a, b, c, d );
    vec2 k8 = cubic_1d000( a, b, c, d );

    r = min( r, sdLine( p, k0, k1 ) );
    r = min( r, sdLine( p, k1, k2 ) );
    r = min( r, sdLine( p, k2, k3 ) );
    r = min( r, sdLine( p, k3, k4 ) );
    r = min( r, sdLine( p, k4, k5 ) );
    r = min( r, sdLine( p, k5, k6 ) );
    r = min( r, sdLine( p, k6, k7 ) );
    r = min( r, sdLine( p, k7, k8 ) );
    
    return r;
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

//======================================================

float dDistance_1( in vec2 v )
{
    float d0 = sdSegment_1( v, p0, p1, t0, t1 );
    float d1 = sdSegment_1( v, p1, p2, t1, t2 );
    float d2 = sdSegment_1( v, p2, p3, t2, t3 );
    float d3 = sdSegment_1( v, p3, p4, t3, t4 );
    float d4 = sdSegment_1( v, p4, p5, t4, t5 );
    float d5 = sdSegment_1( v, p5, p6, t5, t6 );
    float d6 = sdSegment_1( v, p6, p7, t6, t7 );
    float d7 = sdSegment_1( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

float dDistance_2( in vec2 v )
{
    float d0 = sdSegment_2( v, p0, p1, t0, t1 );
    float d1 = sdSegment_2( v, p1, p2, t1, t2 );
    float d2 = sdSegment_2( v, p2, p3, t2, t3 );
    float d3 = sdSegment_2( v, p3, p4, t3, t4 );
    float d4 = sdSegment_2( v, p4, p5, t4, t5 );
    float d5 = sdSegment_2( v, p5, p6, t5, t6 );
    float d6 = sdSegment_2( v, p6, p7, t6, t7 );
    float d7 = sdSegment_2( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

float dDistance_4( in vec2 v )
{
    float d0 = sdSegment_4( v, p0, p1, t0, t1 );
    float d1 = sdSegment_4( v, p1, p2, t1, t2 );
    float d2 = sdSegment_4( v, p2, p3, t2, t3 );
    float d3 = sdSegment_4( v, p3, p4, t3, t4 );
    float d4 = sdSegment_4( v, p4, p5, t4, t5 );
    float d5 = sdSegment_4( v, p5, p6, t5, t6 );
    float d6 = sdSegment_4( v, p6, p7, t6, t7 );
    float d7 = sdSegment_4( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

float dDistance_8( in vec2 v )
{
    float d0 = sdSegment_8( v, p0, p1, t0, t1 );
    float d1 = sdSegment_8( v, p1, p2, t1, t2 );
    float d2 = sdSegment_8( v, p2, p3, t2, t3 );
    float d3 = sdSegment_8( v, p3, p4, t3, t4 );
    float d4 = sdSegment_8( v, p4, p5, t4, t5 );
    float d5 = sdSegment_8( v, p5, p6, t5, t6 );
    float d6 = sdSegment_8( v, p6, p7, t6, t7 );
    float d7 = sdSegment_8( v, p7, p0, t7, t0 );

    return min(d0,min(d1,min(d2,min(d3,min(d4,min(d5,min(d6,d7)))))));
}

//====================================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2  p = (-iResolution.xy+2.0*fragCoord.xy) / min(iResolution.x,iResolution.y);

    float c = dDistance_1( p );
    float d = dDistance_2( p );
    float e = dDistance_4( p );
    float f = dDistance_8( p );
    
    float t = iGlobalTime*0.5 + 0.01;
    
    vec4 w = step( mod(t+4.0-vec4(0.0,1.0,2.0,3.0),4.0),vec4(1.0));
    float a = step(4.0,mod(t,8.0));

    float r = c*w.x + d*w.y + e*w.z + f*w.w;
    
    
    vec3 col = vec3(1.0,1.0,1.0)*clamp( 0.75*r, 0.0, 1.0 ) + 0.02*smoothstep(0.8,0.9,sin(100.0*r));
    
    col = mix( col, (0.5+100.0*vec3(dFdx(r),dFdy(r),0.0))*exp(-r), a );
    col = mix( col, (1.0 - 0.75*w.xyz)*(1.0-a), 1.0-smoothstep(0.0,0.01,r) );
    
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p0)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p1)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p2)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p3)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p4)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p5)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p6)) );
    col = mix( col, vec3(1.0,0.0,0.0)*(1.0-a), 1.0-smoothstep(0.017,0.02,length(p-p7)) );

	fragColor = vec4( col, 1.0 );
}