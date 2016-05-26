// Shader downloaded from https://www.shadertoy.com/view/llfGD4
// written by shadertoy user pheelicks
//
// Name: [2TC 15] 1 Tweet Sun
// Description: Single tweet shader, a bright sun. Inspired by https://www.shadertoy.com/view/ltXGW4
// Created by @pheeelicks
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 
void mainImage( out vec4 f, in vec2 p )
{
    vec2 d=p.xy/iResolution.x-.5;
    f=texture2D(iChannel0,vec2(atan(d.y,d.x),.3)+.02*iDate.w)/length(4.7*d);
}