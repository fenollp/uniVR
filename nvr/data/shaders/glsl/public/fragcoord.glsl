// Shader downloaded from https://www.shadertoy.com/view/XlSGWG
// written by shadertoy user iq
//
// Name: FragCoord
// Description: FragCoord do not run from 0 to resolution-1. They run from 0.5 to resolution-0.5, for pixels are sampled at their geometrical center.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// gl_FragCoord does not run from 0 to resolution-1. It runs from 0.5 to resolution-0.5, 
// for pixels are sampled at their geometrical center. If they did, you'd see a black
// image, instead of a solid (0.5, 0.5, 0.0) color.
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = vec4(fragCoord.xy-floor(fragCoord.xy),0.0,1.0);
}