// Shader downloaded from https://www.shadertoy.com/view/ldtSRl
// written by shadertoy user aiekick
//
// Name: 2D Rad Rep : Particles 2 (196c)
// Description: 2D Radial Repeat : Particles 2
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

//* 196c by FabriceNeyret2
void mainImage( out vec4 f, vec2 g )
{
    f = iDate;   
	g += g - (f.xy=iResolution.xy); 
	g.x = ( atan(g.x, g.y)* 1.59+f.w ) * floor( g.y = length(g+g)/ f.y * 1.59 ) 
         + fract(g.y) * sin(f.w) * 4.;	
	f = vec4(.06, .1, .04, 1) / dot(g=fract(g)-.5, g);
}/**/

/* 222c 
void mainImage( out vec4 f, vec2 g )
{
    f = iDate;
    f.xyz = iResolution;
	g = (g+g-f.xy)/f.y;
	g = vec2(atan(g.x, g.y), length(g+g)) * 1.59;
	g.x *= floor(g.y);
    g.x += fract(g.y) * sin(f.w) * 4. + floor(g.y) * f.w;
	g = fract(g) - .5;
	f = vec4(.06,.1,0.04,.1)/dot(g,g);
}/**/

/* original 231c 
void mainImage( out vec4 f, vec2 g )
{
    f = iDate;
    f.xyz = iResolution;
	g = (g+g-f.xy)/f.y*3.;
	g = vec2(atan(g.x, g.y) * 1.59, length(g));
	g.x *= floor(g.y);
	g.x += fract(g.y) * sin(f.w) * 4.;
	g.x += floor(g.y) * f.w * .2;
	g = fract(g) - .5;
	f = vec4(.06,.1,0.04,.1)/dot(g,g);
}/**/