// Shader downloaded from https://www.shadertoy.com/view/XsjXzt
// written by shadertoy user iq
//
// Name: Sincos approximation
// Description: Improving boundary values for cos (and sin) approximation with some extra normalization. The magic number is sqrt(2)&middot;8/11. True sin/cos in yellow, approximate sin/cos (with and without normalization) in red.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// When approximating sine and cosine with a cubic polynomial as in
// 
// float f = abs(fract(x)-0.5);
// return -1.0 + f*f*(24.0-32.0*f;
//
// the modulo of a rotating vector sqrt(sin²(x) + cos²(x)) is not 1, but 
// m(x) = sqrt( 1 - 12x^2 + 64x^3 + 192x^4 - 1536x^5 + 2048x^6). This means it
// gets shorter on its way. The minimum peaks halfway the approximation, at x=1/8,
// where h(x) = 11·sqrt(2)/16.
//
// This means we can improve the results of the smoothstep(fract())) approximation
// by scaling it by a linear appoximation of 1/m(x). This is the second term in the
// product in line 34 (and 45).
//
// In this shader, real cos(x) in yellow, approximate cosine with and without 
// normalization approximation in red.
//
// Note, this approximation strategy is a pure exercise, there's no evidence that
// it is any faster than the native cos() implementation of the GPU (it's actually
// most probably slower)

#if 0

vec2 mySinCos( in float x )
{
    vec2  f = abs(fract(x-vec2(0.25,0.0))-0.5);
    float h = abs(fract(x*4.0)-0.5);
    
    //     approx sin/cos             * approx renormalization (sqrt(2)·8/11)
    return (-1.0 + f*f*(24.0-32.0*f)) * (1.028519 - 0.0570379*h); 
}

#else

vec2 mySinCos( in float x )
{
    vec2  f = abs(fract(x-vec2(0.25,0.0))-0.5);
    float h = abs(fract(4.0*x)-0.5);
    
    vec2 res = -1.0 + f*f*(24.0-32.0*f);
    if( mod(floor(iGlobalTime),2.0)>0.5 ) res *= (1.028519 - 0.0570379*h);

    return res;
}

#endif    


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec2  p = fragCoord.xy / iResolution.x;
    float m = 0.5*iResolution.y/iResolution.x;
    
    vec3 col = vec3( 0.25 );
    
    // axis    
    float d = abs( p.y - m );
    col = mix( col, vec3(0.0,0.0,0.0), 1.0 - smoothstep( 0.0, 1.0/iResolution.x, d ) );

    // cosine
    float y = m + m*sin( 6.2831*p.x );
    d = abs( p.y - y );
    col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 2.0/iResolution.x, d ) );
        
    // approx cosines (with and without normalization)    
    y = m + m*mySinCos( p.x ).x;
    d = abs( p.y - y );
    col = mix( col, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 2.0/iResolution.x, d ) );
    

    // circle, and approx circles (with and without normalization)    
    float d1 = 1.0;
    float d2 = 1.0;
    for( int i=0; i<256; i++ )
    {
        float h = float(i)/256.0;
        vec2 x1 = vec2(0.5,m) + 0.5*m*mySinCos( h );
        d1 = min( d1, dot(x1-p,x1-p) );
        vec2 x2 = vec2(0.5,m) + 0.5*m*vec2( sin(6.2831*h), cos(6.2831*h) );
        d2 = min( d2, dot(x2-p,x2-p) );
    }
    col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 2.0/iResolution.x, sqrt(d2) ) );
    col = mix( col, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 2.0/iResolution.x, sqrt(d1) ) );

    fragColor = vec4( col, 1.0 );
}
