// Shader downloaded from https://www.shadertoy.com/view/lsjXDc
// written by shadertoy user iq
//
// Name: acos
// Description: Approximation for acos(), by Sebastien Lagarde
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// acos() approximation by Sebastien Lagarde

// In yellow, the real acos()
// In red, the approximation

// Mathematica: F[x_] = Sqrt[1 - x] * MiniMaxApproximation[ArcCos[x] / Sqrt[1 - x], { x, { 0, 0.71}, 1, 0}][[2,1]]
// Note interval is [0, 1] but there is a singularity at 1. Experimenting with various value 
// and plotting error show that 0.71 give the best approx here.

float sacos( float y )
{
    float x = abs( clamp(y,-1.0,1.0) );
    float z = (-0.168577*x + 1.56723) * sqrt(1.0 - x);
    return mix( 0.5*3.1415927, z, sign(y) );
}
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec2  p = fragCoord.xy / iResolution.x;
    p = vec2(-1.0,0.0) + p*vec2( 2.0, 3.1415927*iResolution.x/iResolution.y );

    vec3 col = vec3( 0.25 );
    
    // acos
    float y = acos( p.x );
    col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 6.0/iResolution.x, abs( p.y - y ) ) );
        
    // approx acos
    y = sacos( p.x );
    col = mix( col, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 6.0/iResolution.x, abs( p.y - y ) ) );
    
    fragColor = vec4( col, 1.0 );
}
