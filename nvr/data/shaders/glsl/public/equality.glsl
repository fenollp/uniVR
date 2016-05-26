// Shader downloaded from https://www.shadertoy.com/view/ldl3R4
// written by shadertoy user iq
//
// Name: Equality
// Description: Equallty in love
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0 + 2.0*fragCoord.xy / iResolution.xy;

	// bands
    float f  = step( 0.15, abs(uv.y) );
          f -= step( 0.70, abs(uv.y) );
          f *= step( abs(uv.x), 0.7 );
	

    // hearts	
	uv = fract( uv*6.0 ) - 0.5;
	uv.y -= 0.8*abs(uv.x);
	f *= step( 0.25, length( uv ) );
	
	fragColor = vec4( 0.79 + 0.11*f, 0.55*f, 0.55*f, 1.0 );
}