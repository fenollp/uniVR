// Shader downloaded from https://www.shadertoy.com/view/llXSWN
// written by shadertoy user aiekick
//
// Name: 2D Meteor effect
// Description: accident based on [url=https://www.shadertoy.com/view/ltXSWN][2TC15] Warp Experiment 3 (271c)[/url]: 2D Meteor effect. click and drag ith mouse to see different effect :)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define b(p) vec4( vec2(T=.7*length((v+v-R)/R.y-p)),1e-3/T/T,0)
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy;
    float T=iGlobalTime*.5, C=cos(T);
    
    f = .8*vec4(C, T=sin(T), C+C, -.5*T);
    if((f=iMouse).z>0.)f=b((2.*f.xy-R)/R.y);
    f = b(0.) + b(f.xy*.5) + b(f.xw) + b(f.zy);
    f = texture2D(iChannel0, f.xy) + f.z;
}
