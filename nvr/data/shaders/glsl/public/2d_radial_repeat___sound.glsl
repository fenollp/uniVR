// Shader downloaded from https://www.shadertoy.com/view/XsK3zD
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat : Sound
// Description: sound
// Created by Stephane Cuillerdier - @Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 f, in vec2 g )
{
	f = texture2D(iChannel0, g/iResolution.xy);
}