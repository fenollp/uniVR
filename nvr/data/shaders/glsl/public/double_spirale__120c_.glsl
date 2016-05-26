// Shader downloaded from https://www.shadertoy.com/view/ldyGRw
// written by shadertoy user aiekick
//
// Name: Double Spirale (120c)
// Description: Double Spirale
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/* 120 c thanks to GregRostani and FabriceNeyret2 */ 
void mainImage( out vec4 f, vec2 v )
{
    f.xyz = iResolution;
	f.xy = abs(fract( 
    	length(v+= v-f.xy)/f.y - iDate.w + atan(v, v.yx) * 1.6
   	)-.5);
}

/* 144c
void mainImage( out vec4 f, vec2 v )
{
    f.xyz = iResolution;
	v = (v+v - f.xy)/f.y;
	v = vec2(1,-1) * (length(v) - iDate.w) + atan(v.x, v.y) * 1.6;
	f.xy = abs(fract(v)-0.5);
}*/

/* original code
void main(void)
{
	vec2 uv = (2. * v.xy - iResolution.xy)/iResolution.y;
	
	float a = atan(uv.x, uv.y) / 3.14159 * 5.;
	float r = length(uv) - iDate.w;
	
	uv = abs(fract(vec2(a+r,a-r))-0.5);
	
	f = vec4(uv, 0.5 + 0.5*sin(iDate.w), 1.0);
}*/