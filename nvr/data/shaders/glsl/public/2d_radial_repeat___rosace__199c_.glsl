// Shader downloaded from https://www.shadertoy.com/view/MsKGRm
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat : Rosace (199c)
// Description: Rosace
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 f, vec2 g )
{
	f = iDate;
	f.xyz = iResolution;
    g = (g+g-f.xy)/f.y;
	g = abs(fract(vec2(atan(g.x+cos(f.w), g.y + sin(f.w) * cos(f.w)), length(g))*3.18)-.5);
	f = vec4(85,16,39,1) / 4e3 / g.x / ( g.y - sin(g.x));
}