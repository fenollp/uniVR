// Shader downloaded from https://www.shadertoy.com/view/4sfGRn
// written by shadertoy user iq
//
// Name: Radial Blur
// Description: A GLSL version of the oldschool radialblur effect
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 deform( in vec2 p )
{
    vec2 uv;

    vec2 q = vec2( sin(1.1*iGlobalTime+p.x),sin(1.2*iGlobalTime+p.y) );

    float a = atan(q.y,q.x);
    float r = sqrt(dot(q,q));

    uv.x = sin(0.0+1.0*iGlobalTime)+p.x*sqrt(r*r+1.0);
    uv.y = sin(0.6+1.1*iGlobalTime)+p.y*sqrt(r*r+1.0);

    return texture2D( iChannel0, uv*.3).yxx;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    vec2 s = p;

    vec3 total = vec3(0.0);
    vec2 d = (vec2(0.0,0.0)-p)/40.0;
    float w = 1.0;
    for( int i=0; i<40; i++ )
    {
        vec3 res = deform(s);
        res = smoothstep(0.0,1.0,res);
        total += w*res;
        w *= .99;
        s += d;
    }
    total /= 40.0;
    float r = 3.0;

	fragColor = vec4( total*r,1.0);
}