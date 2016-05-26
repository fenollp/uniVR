// Shader downloaded from https://www.shadertoy.com/view/ld2GzR
// written by shadertoy user iq
//
// Name: IFS - dragon
// Description: IFS Dragon. Iterating the IFS and gathering pixel colors is the most inefficient way to render an IFS ever :(
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Dragon fractal: http://en.wikipedia.org/wiki/Dragon_curve

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy - iResolution.xy)/iResolution.y;

	uv = 0.8*uv + vec2( 0.5, 0.0 );
	
	float p = sin( dot(fragCoord.xy,vec2(13.1,17.1)) );

    float m = 1e10;	
	float d = 0.0;
    vec2 z = vec2( 0.0 );
    for( int i=0; i<768; i++ ) 
    {
		p = fract( p*8.13 ); // random number
		
        z = vec2( z.x - z.y, z.x + z.y ) * 0.5;
		z = vec2( step( 0.5, p ), 0.0 ) - z*sign(p-0.5);
		
        d = max( d, exp( -2500.0*dot(uv-z,uv-z) ) );
		m = min( m, dot(z-uv,z-uv) );
    }
	m = 1.0 - exp( -2.0*sqrt(m) );
	
	vec3 col = d*vec3(1.0,0.7,0.2) + m*vec3(0.6,1.0,1.0);
	
	fragColor = vec4( col, 1.0 );
}