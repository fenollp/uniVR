// Shader downloaded from https://www.shadertoy.com/view/4dGGzD
// written by shadertoy user aiekick
//
// Name: Radial Repeat (179c)
// Description: Radial Repeat
// Created by Stephane Cuillerdier - @Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 f, in vec2 g )
{
    vec2 
        s = iResolution.xy,
        u = (g+g-s)/s.y,
		ar = vec2(atan(u.x, u.y) / 3.14, length(u)) * 10.,
        v;
    
    ar.x += ar.y * sin(iDate.w);
    
	v = mod(ar,2.) - 1.;
    
	f = f-f + 1. - 0.1/dot(v, v);
}