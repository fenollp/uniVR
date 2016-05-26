// Shader downloaded from https://www.shadertoy.com/view/4slGRH
// written by shadertoy user iq
//
// Name: Primes
// Description: Computes pr-ime numbers. The quadratic patterns (vertical lines in this case) of Euler can be clearly seen. Checks are done by following the sequence {2, 4, 2, 4, 6, 2, 6, 4} which skips multiples of 2, 3 and 5.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Info on prime hunting: http://www.iquilezles.org/blog/?p=1558
float isPrime( float x )
{
	if( x==1.0 ) return 0.0;
	if( x==2.0 ) return 1.0;
	if( x==3.0 ) return 1.0;
	if( x==5.0 ) return 1.0;
	if( x==7.0 ) return 1.0;
	
	if( mod(x,2.0)==0.0 ) return 0.0;
	if( mod(x,3.0)==0.0 ) return 0.0;
	if( mod(x,5.0)==0.0 ) return 0.0;

	float y = 7.0;
	for( int i=0; i<200; i++ ) // count up to 6000
	{
		if( mod(x,y)==0.0 )  return 0.0;
		y += 4.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 2.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 4.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 2.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 4.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 6.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 2.0; if( y>=x ) return 1.0;
		if( mod(x,y)==0.0 )  return 0.0;
		y += 6.0; if( y>=x ) return 1.0;
        
        
        
        // speeds up, slows down, or crashes your compiler, 
        // depending on your GLSL implementation:
        
        //if( (y*y) > x ) break; 
	}
	
	return 1.0;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float s = 0.5 + 0.5*cos(6.2831*iGlobalTime/10.0);
	s = 0.1 + 0.9*s;
	float xres = s*iResolution.x;
	vec2  uv   = s*fragCoord.xy;

	vec3 col = vec3(0.0);
	
	float y = 1.0 + floor(uv.y);
	float o = floor(xres/2.0 - uv.x);
	if( abs(o)<y )
	{
	    float n = y*y-2.0*y + 2.0 - o  + y -1.0;
	    float f = isPrime( n );
	    col = vec3( f*0.25,f,0.0);
	}
	
	fragColor = vec4( col, 1.0 );
}