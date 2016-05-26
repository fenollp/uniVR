// Shader downloaded from https://www.shadertoy.com/view/Md2GzR
// written by shadertoy user iq
//
// Name: Sierpinski - 2D
// Description: 2D Sierpinski fractal. See  for the 3D version.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float length2( in vec2 p ) { return dot(p,p); }

const vec2 va = vec2(  0.0, 1.73-0.85 );
const vec2 vb = vec2(  1.0, 0.00-0.85 );
const vec2 vc = vec2( -1.0, 0.00-0.85 );

// return distance and address
vec2 map( vec2 p )
{
	float a = 0.0;
	vec2 c;
	float dist, d, t;
	for( int i=0; i<7; i++ )
	{
		d = length2(p-va);                 c = va; dist=d; t=0.0;
        d = length2(p-vb); if (d < dist) { c = vb; dist=d; t=1.0; }
        d = length2(p-vc); if (d < dist) { c = vc; dist=d; t=2.0; }
		p = c + 2.0*(p - c);
		a = t + a*3.0;
	}
	
	return vec2( length(p)/pow(2.0, 7.0), a/pow(3.0,7.0) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy - iResolution.xy)/iResolution.y;

	vec2 r = map( uv );
	
	vec3 col = 0.5 + 0.5*sin( 3.1416*r.y + vec3(0.0,5.0,5.0) );
	col *= 1.0 - smoothstep( 0.0, 0.02, r.x );
	
	fragColor = vec4( col, 1.0 );
}