// Shader downloaded from https://www.shadertoy.com/view/MsjXRd
// written by shadertoy user iq
//
// Name: Taylor
// Description: Degree 6 Taylor expansion of cosine (and sine). There's a yellow true sin/circle graph rendered behind it, but the approximation is accurate to the pixel for this magnification level! Made after demofox' shader https://www.shadertoy.com/view/MdBSRt
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Degree 6 taylor sin and cosine, based on cosine:
//
// cos(x) = 1 - x^2/2 + x^4/24 - x^6/720 + ...
//
// The maximum error happens at x=1/2 (PI, in radians) (where the graph crosses the 
// x axis), and it is mySincos(1/2) = −0.000894546 instead of 0.0. This discontinuity
// could be fixed easily by offseting the result with that value as we approach the
// point x=1/2. The error term in the Taylos series is therefore
//
// e = -184320/(PI^8) + 23040/(PI^6) - 480/(PI^4) + 4/(PI^2) = 0.017377, which is of
// course clorse to 1/(8*7), the next term in the Taylor series (or order 8). An order 
// 8 approximation would bring the error from -0.000894546 down to +0.000024737


const float PI = 3.1415926536;
const float E6 = 0.017377;      // -184320/(PI^8) + 23040/(PI^6) - 480/(PI^4) + 4/(PI^2)

vec2 mySinCos( float a )
{
    vec2 y = a + vec2(0.0,0.25);
    
    vec2 s = (fract(1.0*y) - 0.5)*PI;
    vec2 x = (fract(2.0*y) - 0.5)*PI;
    vec2 z = x*x;
    
    // show and hide Taylor truncation compensation
    float errorFix = E6 * step(fract(iGlobalTime),0.5);

    return -sign(s)*(1.0-(1.0-(1.0-(1.0-(
                     z*errorFix))*
                     z/(6.0*5.0))*
                     z/(4.0*3.0))*
                     z/(2.0*1.0));
}

/*
// use this if you want to call sincos with radians insteaf of turns.

vec2 mySinCos( float a )
{
    vec2 y = a + vec2(0.0,0.5*PI);
    
    vec2 s = mod(0.5*y,PI) - 0.5*PI;
    vec2 x = mod(1.0*y,PI) - 0.5*PI;
    vec2 z = x*x;
    
    return -sign(s) * (1.0-(1.0-(1.0-(1.0-(
                       z*E6))*
                       z/(6.0*5.0))*
                       z/(4.0*3.0))*
                       z/(2.0*1.0));
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    float e = 1.0/iResolution.x;
    vec2  p = fragCoord.xy / iResolution.x;
    float m = 0.5*iResolution.y/iResolution.x;
    
    // show discontinuity, by zooming in 500 times 
    // 000894546*500 = 0.44 graph units -- approx halg screeen gap
    float zo = 1.0+500.0*pow(clamp(fract(0.34 + iGlobalTime/6.0)*3.0-1.0,0.0,1.0),4.0);p=vec2(0.5,m)+(p-vec2(0.5,m))/zo;e/=zo;
    
    vec3 col = vec3( 0.25 );
    
    // axis    
    float d = abs( p.y - m );
    col = mix( col, vec3(0.0,0.0,0.0), 1.0 - smoothstep( 0.0, e, d ) );

    // sine
    float y = m + m*sin( 6.2831*p.x );
    d = abs( p.y - y );
    col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 2.0*e, d ) );
        
    // approx sine
    y = m + m*mySinCos( p.x ).x;
    d = abs( p.y - y );
    col = mix( col, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 2.0*e, d ) );
    
    // circle, and approx circle
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
    col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 2.0*e, sqrt(d2) ) );
    col = mix( col, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 2.0*e, sqrt(d1) ) );

    fragColor = vec4( col, 1.0 );
}
