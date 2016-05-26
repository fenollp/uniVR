// Shader downloaded from https://www.shadertoy.com/view/4dXGDX
// written by shadertoy user iq
//
// Name: Julia - Generic
// Description: A generic Julia set renderer, using distance to the set (Douady_Hubbard potential). In this case I'm using a rational function of order 6: f(z) = (z-(1+i)/10)(z-i)(z-1)^4 / (z+1)(z-(1+i)) + c
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//------------------------------------------------------------
// complex number operations
vec2 cadd( vec2 a, float s ) { return vec2( a.x+s, a.y ); }
vec2 cmul( vec2 a, vec2 b )  { return vec2( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x ); }
vec2 cdiv( vec2 a, vec2 b )  { float d = dot(b,b); return vec2( dot(a,b), a.y*b.x - a.x*b.y ) / d; }
vec2 csqr( vec2 a ) { return vec2(a.x*a.x-a.y*a.y, 2.0*a.x*a.y ); }
vec2 csqrt( vec2 z ) { float m = length(z); return sqrt( 0.5*vec2(m+z.x, m-z.x) ) * vec2( 1.0, sign(z.y) ); }
vec2 conj( vec2 z ) { return vec2(z.x,-z.y); }
vec2 cpow( vec2 z, float n ) { float r = length( z ); float a = atan( z.y, z.x ); return pow( r, n )*vec2( cos(a*n), sin(a*n) ); }
//------------------------------------------------------------


vec2 f( vec2 z, vec2 c )
{
	//return csqr(z) + c;   // tradicional z -> z^2 + c Julia set

	return c + cdiv( cmul( z-vec2(0.0,1.0), cmul( cpow(z-1.0,4.0), (z-vec2(-0.1)) ) ), 
					 cmul( z-vec2(1.0,1.0), z+1.0));
}

vec2 df( vec2 z, vec2 c )
{
	vec2 e = vec2(0.001,0.0);
    return cdiv( f(z,c) - f(z+e,c), e );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
	p.y *= iResolution.y/iResolution.x;
	p = 2.5*(p+vec2(0.25,0.37));
	
	float time = iGlobalTime;
	vec2 c = vec2( 0.1-0.08, 0.55-0.3 ) + 
		     0.30*vec2( sin(0.31*(time-10.0)), cos(0.37*(time-10.0)) ) - 
		     0.01*vec2( sin(2.17*(time-10.0)), cos(2.31*(time-10.0)) );
	

	// iterate		
	vec2 dz = vec2( 1.0, 0.0 );
	vec2 z = p;
	float g = 1e10;
	for( int i=0; i<100; i++ )
	{
		if( dot(z,z)>10000.0 ) continue;

        // chain rule for derivative		
		dz = cmul( dz, df( z, c ) );

        // function		
		z = f( z, c );
		
		g = min( g, dot(z-1.0,z-1.0) );
	}

    // distance estimator
	float h = 0.5*log(dot(z,z))*sqrt( dot(z,z)/dot(dz,dz) );
	
	h = clamp( h*100.0, 0.0, 1.0 );
	
	
	vec3 col = 0.6 + 0.4*cos( log(log(1.0+g))*0.5 + 4.5 + vec3(0.0,0.5,1.0) );
	col *= h;
	fragColor = vec4( col, 1.0 );

}
