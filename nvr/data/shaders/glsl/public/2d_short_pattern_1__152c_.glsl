// Shader downloaded from https://www.shadertoy.com/view/Md3XDf
// written by shadertoy user aiekick
//
// Name: 2d Short Pattern 1 (152c)
// Description: Short version of [url=https://www.shadertoy.com/view/XtB3WD]Mod Experiment 1[/url]
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

//* 152 by GregRostami
void mainImage(out vec4 f,vec2 g)
{
	g = 4.*(g+g - (f.xy=iResolution.xy) ) / f.y;
	g *= mat2( sin( g.xyxy + 1.57*vec4(3,0,0,1) ) );
	f += .1/dot(g = mod( g += iDate.xw, .9 ) - .4, g) - f;
}/**/

/* original 165c
void mainImage( out vec4 f, vec2 g )
{
    f.xyz = iResolution;
	g = (g+g-f.xy)/f.y * 4.;
    g *= mat2(cos(g.x), sin(g.y), -sin(g.x), cos(g.y));
    g.x += iDate.w;
	g = mod(g, .9) - .45;
    f += .1/dot(g,g) - f;
}/**/