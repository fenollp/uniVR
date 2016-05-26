// Shader downloaded from https://www.shadertoy.com/view/ldK3Rd
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat : Rosace 2 159c
// Description: Rosace 2
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/* 160c with help of fabriceneyret2 */
void mainImage( out vec4 f, vec2 g )
{
	f.xyz = iResolution;
    g += g-f.xy;
   	g = abs(fract( atan(g.x, g.y) * 1.59 + vec2(0, 2. * length(g)/f.y - iDate.w)) -.5);
	f = vec4(4,1,2,2) / 2e2 / g.x / g.y;
}

/* 177c
void mainImage( out vec4 f, vec2 g )
{
	f = iDate;
	f.xyz = iResolution;
    g = (g+g-f.xy)/f.y;
   	g = abs(fract(vec2(f.x = atan(g.x, g.y) * 1.592, length(g) * 2. + f.x - f.w))-.5);
	f = vec4(85,16,39,1) / 4e3 / g.x / g.y;
}*/

/* original xshade code
void main(void)
{
	vec2 g = gl_FragCoord.xy;
	vec2 s = uScreenSize;
	vec2 u = (g+g-s)/s.y;
	
	float a = atan(u.x, u.y) / 3.14159 * uSlider;
	float r = length(u)*2.;
	vec2 ar = vec2(a,r);

	ar.y += ar.x - uTime;
	
	ar = abs(fract(ar)-0.5);
		
	vec3 col = uColor * uSlider1 / (ar.x * ( ar.y - sin(ar.x) * cos(ar.y) * uSlider2));

	gl_FragColor = vec4(col, 1);
}*/