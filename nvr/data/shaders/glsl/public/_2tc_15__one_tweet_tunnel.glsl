// Shader downloaded from https://www.shadertoy.com/view/ltXGW4
// written by shadertoy user iq
//
// Name: [2TC 15] ONE Tweet Tunnel
// Description: In fact, it's [b]ONE[/b] tweet long, inspired by [url]https://www.shadertoy.com/view/4tfGDN[/url]
//    I sacrificed texture mapping precision by using iDate.w instead of iGlobalTime which saved 4 chars. So you better watch this shader soon after midnight...
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 c, in vec2 p )
{
    p = p/iResolution.y - .5;
    c.w = length(p);
    c = texture2D( iChannel0, vec2(atan(p.y,p.x), .2/c.w)+iGlobalTime )*c.w;
}