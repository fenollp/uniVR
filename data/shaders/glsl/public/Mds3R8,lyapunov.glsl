// Shader downloaded from https://www.shadertoy.com/view/Mds3R8
// written by shadertoy user iq
//
// Name: Lyapunov
// Description: Markus-Lyapunov diagram for AAAAABBBBBB. More info: http://www.iquilezles.org/www/articles/lyapunovfractals/lyapunovfractals.htm. It was 12 years I didn't code one of these :)
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// More info here:  http://www.iquilezles.org/www/articles/lyapunovfractals/lyapunovfractals.htm

vec3 calc( in vec2 p )
{
    float x = 0.5;
	float h = 0.0;
	for( int i=0; i<150; i++ )
	{
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));
		x = p.x*x*(1.0-x); h += log2(abs(p.x*(1.0-2.0*x)));

        x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
		x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
		x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
		x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
		x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
		x = p.y*x*(1.0-x); h += log2(abs(p.y*(1.0-2.0*x)));
	}
    h /= 150.0*12.0;
	
	
	vec3 col = vec3(0.0);
	if( h<0.0 )
	{
		h = abs(h);
		col = 0.5 + 0.5*sin( vec3(0.0,0.4,0.7) + 2.5*h );
		col *= pow(h,0.25);
	}
	

	return col;
}
	
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	#if 0
	vec3 col = calc( vec2(2.5,3.5) + 1.0*fragCoord/iResolution.x );
	#else
	vec3 col = calc( vec2(2.5,3.5) + 1.0*(fragCoord+vec2(0.0,0.0)) / iResolution.x ) +
	           calc( vec2(2.5,3.5) + 1.0*(fragCoord+vec2(0.0,0.5)) / iResolution.x ) +
	           calc( vec2(2.5,3.5) + 1.0*(fragCoord+vec2(0.5,0.0)) / iResolution.x ) +
	           calc( vec2(2.5,3.5) + 1.0*(fragCoord+vec2(0.5,0.5)) / iResolution.x );
    col /= 4.0;
	#endif
	
	fragColor = vec4( col, 1.0 );
}