// Shader downloaded from https://www.shadertoy.com/view/4dBXz3
// written by shadertoy user iq
//
// Name: Vector reflect/clip
// Description: How to clip a vector to a hemisphere, and to to reflect it (useful for making sure your vectors are in the positive side of a plane/normal). Move the mouse to see how it behaves.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Very important trick to avoid discontinuities in rendering:
//
// http://www.iquilezles.org/blog/?p=1419

//===============================================================

// Reflect a vetor to be in a given half plane (this works in 3D too)
vec2 reflVector( in vec2 v, in vec2 n )
{
    return v + 2.0*n*max(0.0,-dot(n,v));
}

// Clip a vetor to a given half plane (this works in 3D too)
vec2 clipVector( in vec2 v, in vec2 n )
{
    float k = dot(n,v);
    return v - n*k*(0.5-0.5*sign(k));
}

//===============================================================

float distanceToSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return length( pa - ba*h );
}

float e = 2.0/min(iResolution.y,iResolution.x);

float line( in vec2 p, in vec2 a, in vec2 b, float w )
{
    return 1.0 - smoothstep( -e, e, distanceToSegment( p, a, b ) - w );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	vec2 p = (-iResolution.xy*0.5 + fragCoord.xy)*e;
 	vec2 m = (-iResolution.xy*0.5 + iMouse.xy)*e;
    if( iMouse.z<0.01 ) m = 0.8*vec2( cos(iGlobalTime), sin(iGlobalTime) );

    vec2 no = normalize( vec2(0.2 + 0.5*cos(0.3*iGlobalTime), 0.5 ) );
    vec2 pe = no.yx*vec2(-1.0,1.0);
    vec2 re = reflVector( m, no );
    vec2 cl = clipVector( m, no );
    
    vec3 col = vec3( 0.5 - 0.2*smoothstep(-e,e,dot(p,no)) );
    
    col = mix( col, vec3(0.5,0.5,0.5), line(p, vec2(0.0), no*0.5, 0.012) );
    col = mix( col, vec3(0.5,0.5,0.5), line(p, no*0.5, no*0.5+( pe-no)*0.1, 0.012) );
    col = mix( col, vec3(0.5,0.5,0.5), line(p, no*0.5, no*0.5+(-pe-no)*0.1, 0.012) );

    col = mix( col, vec3(1.0,0.6,0.0), line(p, vec2(0.0), re, 0.01) );
    col = mix( col, vec3(0.7,0.3,0.0), line(p, vec2(0.0), cl, 0.01) );
    col = mix( col, vec3(0.1,0.1,0.1), line(p, vec2(0.0), m, 0.01) );
    
    
    fragColor = vec4( col, 1.0 );
}