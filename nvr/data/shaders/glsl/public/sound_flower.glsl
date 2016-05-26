// Shader downloaded from https://www.shadertoy.com/view/Msf3Dn
// written by shadertoy user iq
//
// Name: Sound Flower
// Description: A circle deformed by the sound waveform
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0+2.0*fragCoord.xy/iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	
	float r = length( uv );
	float a = atan( uv.x, uv.y );

	float w = texture2D( iChannel0, vec2( abs(a)/6.28,1.0) ).x;
	
	float t = 3.0*sqrt(abs(w-0.5));

	float f = 0.0;
	if( r<t ) f = (1.0-r/t);
	vec3 col = pow( vec3(f), vec3(1.5,1.1,0.8) );

	fragColor = vec4( col, 1.0 );
}