// Shader downloaded from https://www.shadertoy.com/view/lsSSzz
// written by shadertoy user iq
//
// Name: Painting - Sho style
// Description: A super quick doodling session, using Sho Murase's work as reference.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

float hash( vec2 p )
{
	float h = dot(p,vec2(127.1,311.7));
	
    return -1.0 + 2.0*fract(sin(h)*43758.5453123);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000*noise( p ); p = m*p*2.02; p.y += 0.02*iGlobalTime;
    f += 0.2500*noise( p ); p = m*p*2.03; p.y -= 0.02*iGlobalTime;
    f += 0.1250*noise( p ); p = m*p*2.01; p.y += 0.02*iGlobalTime;
    f += 0.0625*noise( p );
    return f/0.9375;
}

vec2 fbm2( vec2 p )
{
    return vec2( fbm(p.xy), fbm(p.yx) );
}

vec3 doImage( vec2 p, vec2 q )
{   
    p *= 0.25;
    
    float f = 0.3 + fbm( 1.0*(p + fbm2(2.0*(p + fbm2(4.0*p)))) );

    vec2 r = p.yx*2.0;
    f -= 0.2*(1.0-2.0*abs(f))*clamp( 0.5 + 3.0*fbm( 1.0*(r + fbm2(2.0*(r + fbm2(4.0*r)))) ), 0.0, 1.0 );

    float v = 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y);
    f += 1.1*(1.0-smoothstep( 0.0, 0.6, v ));
    
    float w = fwidth(f);
    float bl = smoothstep( -w, w, f );

    float ti = smoothstep( -0.9, 0.7, fbm(3.0*p+0.5) );
    
	return mix( mix( vec3(0.0,0.0,0.0), 
                     vec3(0.9,0.0,0.0), ti ), 
                     vec3(1.0,1.0,1.0), bl );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/ iResolution.y;
    vec2 q = p;
    
    q = 0.5 + 0.5*q/vec2(600.0/800.0,1.0);
    
    vec3 col = doImage( (p-0.0), clamp(q,0.0,1.0) );
    
    col *= 1.0 - smoothstep( 0.0, 1.0/iResolution.y, abs(q.x - 0.5)-0.5 );
    
    fragColor = vec4( col, 1.0 );
}