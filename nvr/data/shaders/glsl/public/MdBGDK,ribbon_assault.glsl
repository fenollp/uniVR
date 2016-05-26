// Shader downloaded from https://www.shadertoy.com/view/MdBGDK
// written by shadertoy user Dave_Hoskins
//
// Name: Ribbon Assault
// Description: Inspired by the 'Kali2 scope' - https://www.shadertoy.com/view/lsBGWK
//    Should be fast full-screen for everybody. : )
//    Use mouse for manual movement.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/MdBGDK
// By David Hoskins.

float gTime = iGlobalTime+11.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float f = 3., g = 3.;
	vec2 res = iResolution.xy;
	vec2 mou = iMouse.xy;
	if (iMouse.z < 0.5)
	{
		mou.x = sin(gTime * .3)*sin(gTime * .17) * 1. + sin(gTime * .3);
		mou.y = (1.0-cos(gTime * .632))*sin(gTime * .131)*1.0+cos(gTime * .3);
		mou = (mou+1.0) * res;
	}
	vec2 z = ((-res+2.0 * fragCoord.xy) / res.y);
	vec2 p = ((-res+2.0+mou) / res.y);
	for( int i = 0; i < 20; i++) 
	{
		float d = dot(z,z);
		z = (vec2( z.x, -z.y ) / d) + p; 
		z.x =  abs(z.x);
		f = max( f, (dot(z-p,z-p) ));
		g = min( g, sin(dot(z+p,z+p))+1.0);
	}
	f = abs(-log(f) / 3.5);
	g = abs(-log(g) / 8.0);
	fragColor = vec4(min(vec3(g, g*f, f), 1.0),1.0);
}
