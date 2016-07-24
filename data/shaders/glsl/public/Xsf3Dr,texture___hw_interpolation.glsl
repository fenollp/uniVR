// Shader downloaded from https://www.shadertoy.com/view/Xsf3Dr
// written by shadertoy user iq
//
// Name: Texture - HW interpolation
// Description: HW linear interpolation vs manual interpolation. Depending on your display the two might or might not look the same. However, taking derivatives highlights the problem - HW interpolation does not produce the expected constant derivative.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
//
// HW linear interpolation vs manual interpolation. 
//
// Depending on your display the two might or might look to be similar or
// even the same. However, taking derivatives  highlights the problem: HW 
// interpolation does not produce the expected constant derivative, but a 
// series of discrete jumps.
//
// You can undefine the USE8BIT below and check that indeed HW is using 8 
// bit point arighmetic.


//#define USE8BIT

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
	
	// texture resolution
	float texRes = 64.0;
	
	// pixel under examination
    vec2 pixOff = vec2(430.5,40.5)/texRes;
	
    // linear interpolation done by the hardware	
	vec3 c = texture2D( iChannel0, pixOff+vec2(p.x/texRes,0.0) ).xyz;

	// linear interpolation made by hand
	vec3 d = mix( texture2D( iChannel0, pixOff+vec2(0.0/texRes,0.0) ).xyz, 
				  texture2D( iChannel0, pixOff+vec2(1.0/texRes,0.0) ).xyz, 
#ifdef USE8BIT
                  floor(p.x*256.0-0.5)/256.0	 );
#else
				  p.x );
#endif

	// compare both. upper half: HW, lower half: manual
	vec3 r = c; if( p.y<0.5 ) r=d;
	
    // show derivatives
	if( abs(p.y-0.5)>0.3 ) r = 2.0*abs(dFdx(r))*iResolution.x;
	
	r *= smoothstep( 0.002, 0.004, abs(p.y-0.5) );
	r *= smoothstep( 0.002, 0.004, abs(p.y-0.2) );
	r *= smoothstep( 0.002, 0.004, abs(p.y-0.8) );
	
	fragColor = vec4(r,1.0);
}