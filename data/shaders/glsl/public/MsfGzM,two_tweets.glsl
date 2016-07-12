// Shader downloaded from https://www.shadertoy.com/view/MsfGzM
// written by shadertoy user iq
//
// Name: Two Tweets
// Description: Line 6 is modelling. Line 10 is rendering. Line 11 is shading. Inspired by Nautilus. It's an experiment to see how far I could go in less than 280 characters, which is the size of two tweets ^_^
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float f(vec3 p) 
{ 
	p.z+=iGlobalTime;return length(.05*cos(9.*p.y*p.x)+cos(p)-.1*cos(9.*(p.z+.3*p.x-p.y)))-1.; 
}
void mainImage( out vec4 c, vec2 p )
{
    vec3 d=.5-vec3(p,1)/iResolution.x,o=d;for(int i=0;i<99;i++)o+=f(o)*d;
    c=vec4(abs(f(o-d)*vec3(0,.1,.2)+f(o-.6)*vec3(.2,.1,0))*(10.-o.z),1);	
}