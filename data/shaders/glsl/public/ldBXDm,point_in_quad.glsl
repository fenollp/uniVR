// Shader downloaded from https://www.shadertoy.com/view/ldBXDm
// written by shadertoy user iq
//
// Name: Point in Quad
// Description: Tests whether a point is inside a quad. Note than the quadrilateral can intersect itself. Derived from https://www.shadertoy.com/view/lsBSDm
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Point in Quad test. Note that it works for selfintersecting quads. No square roots
// required. Derived form this shader: https://www.shadertoy.com/view/lsBSDm

float cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

float pointInQuad( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d )
{
    vec2 e = b-a;
    vec2 f = a-d;
    vec2 g = a-b+c-d;
    vec2 h = p-a;
        
    float k0 = cross( f, g );
    float k1 = cross( e, g );
    float k2 = cross( f, e );
    float k3 = cross( g, h );
    float k4 = cross( e, h );
    float k5 = cross( f, h );
    
    float l0 = k2 - k3 + k0;
    float l1 = k2 + k3 + k1;
    float m0 = l0*l0 + k0*(2.0*k4 - l0);
    float m1 = l1*l1 + k1*(2.0*k5 - l1);
    float n0 = m0    + k0*(2.0*k4 + k3 - k2);
    float n1 = m1    + k1*(2.0*k5 - k3 - k2);
    
    float b0 = step( m0*m0, l0*l0*n0 );
    float b1 = step( m1*m1, l1*l1*n1 );

    float res = (m0>0.0) ? ((m1>0.0) ? b1*b0 : 
                                       b0) : 
                           ((m1>0.0) ? b1 : 
                                       b1 + b0 - b1*b0);

    if( l0*l1 < 0.0 )  res -= b1*b0;
    
    return res;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    
    vec2 a = cos( 1.11*iGlobalTime + vec2(0.1,4.0) );
    vec2 b = cos( 1.13*iGlobalTime + vec2(1.0,3.0) );
    vec2 c = cos( 1.17*iGlobalTime + vec2(2.0,2.0) );
    vec2 d = cos( 1.15*iGlobalTime + vec2(3.0,1.0) );
    
    float isQuad = pointInQuad( p, a, b, c, d );
    
    vec3 col = vec3( isQuad*0.5 );
    
    float h = 2.0/iResolution.y;
    col = mix( col, vec3(1.0), 1.0-smoothstep(h,2.0*h,sdSegment(p,a,b)));
    col = mix( col, vec3(1.0), 1.0-smoothstep(h,2.0*h,sdSegment(p,b,c)));
    col = mix( col, vec3(1.0), 1.0-smoothstep(h,2.0*h,sdSegment(p,c,d)));
    col = mix( col, vec3(1.0), 1.0-smoothstep(h,2.0*h,sdSegment(p,d,a)));
    
	fragColor = vec4( col,1.0);
}