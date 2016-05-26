// Shader downloaded from https://www.shadertoy.com/view/ltlGDN
// written by shadertoy user iq
//
// Name: [2TC 15] Cave
// Description: Motionblurred relief/displaced cylinder.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define t texture2D(iChannel0,p*.1,3.

void mainImage( out vec4 f, in vec2 p )
{
    vec4 q = p.xyxy/iResolution.y - .5, c=q-q;
    
    for( float s=0.; s<.1; s+=.01 )
    {
        float x = length( q.xy ), z = 1.; p.y = atan( q.x, q.y );
        
        for( int i=0; i<99; i++ )
        {
            p.x = iGlobalTime*3. + s + 1./(x+x*z);
            if( t).x > z ) break;
            z -= .01;
        }

        f = c += t*x)*z*x*.2;
    }
}