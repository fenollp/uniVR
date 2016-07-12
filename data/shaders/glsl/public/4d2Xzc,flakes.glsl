// Shader downloaded from https://www.shadertoy.com/view/4d2Xzc
// written by shadertoy user iq
//
// Name: Flakes
// Description: Texture convolution based flakes
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy/iResolution.xy;
        
    vec3  col = vec3( 0.0 );
    
    for( int i=0; i<150; i++ )
    {
        float an = 6.2831*float(i)/150.0;
        vec2  of = vec2( cos(an), sin(an) ) * (1.0+0.6*cos(7.0*an+iGlobalTime)) + vec2( 0.0, iGlobalTime );
        col = max( col, texture2D( iChannel0, p + 20.0*of/iResolution.xy ).xyz );
        col = max( col, texture2D( iChannel0, p +  5.0*of/iResolution.xy ).xyz );
    }
    
    col = pow( col, vec3(1.0,2.0,3.0) ) * pow( 4.0*p.y*(1.0-p.y), 0.25 );
    
	fragColor = vec4( col, 1.0 );
}