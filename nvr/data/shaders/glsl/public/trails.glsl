// Shader downloaded from https://www.shadertoy.com/view/MsKGWR
// written by shadertoy user iq
//
// Name: Trails
// Description: Doodle
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy + 0.01*iGlobalTime;
    
    vec3 col = vec3(0.0);
    
    for( int i=0; i<35; i++ )
    {
        vec2 off = 0.04*cos( 8.0*uv + 0.07*float(i) + 3.0*iGlobalTime + vec2(0.0,1.0));
        vec3 tmp = texture2D( iChannel0, uv + off ).yzx;
        col += tmp*tmp*tmp;
    }
    
    col /= 5.0;
    
	fragColor = vec4( col, 1.0 );
}