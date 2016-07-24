// Shader downloaded from https://www.shadertoy.com/view/Xd2GzR
// written by shadertoy user iq
//
// Name: Dual Complex Numbers
// Description: Implementation of dual-complex numbers, which are useful to compute derivatives of complex functions analytically without central differences or limits/epsilon differentiation. More info in dual numbers here: http://jliszka.github.io/2013/10/24/exact-nume
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// An experiment on implementing "dual complex" numbers, in order to compute complex function
// derivatives analytically without resorting to numerical differenciation. That way I can compute
// derivatives, gradients and distance estimations analytically, easily and elegantly.!

// In this case, I use them for rendering the Mandelbrot with a distance estimation coloring algorithm.
// 
// See my "Mandelbrot - distance" shader for comparison: https://www.shadertoy.com/view/lsX3W4
//
// See this article on dual numbers: http://jliszka.github.io/2013/10/24/exact-numeric-nth-derivatives.html


//-------------- dual complex numbers --------------

// Z = { x, y, dx, dy } = (x + dx) + i·(y + dy)

vec4 dcAdd( vec4 a, vec4 b )
{
    return a + b;
}

vec4 dcMul( vec4 a, vec4 b )
{
    return vec4( a.x*b.x - a.y*b.y, 
				 a.x*b.y + a.y*b.x,
				 a.x*b.z + a.z*b.x - a.y*b.w - a.w*b.y,
				 a.x*b.w + a.w*b.x + a.z*b.y + a.y*b.z );
}

vec4 dcSqr( vec4 a )
{
    return vec4( a.x*a.x - a.y*a.y, 
				 2.0*a.x*a.y,
				 2.0*(a.x*a.z - a.y*a.w),
				 2.0*(a.x*a.w + a.y*a.z) );
}

//--------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

    // animation	
	float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
    float zo = pow( 0.5, 13.0*tz );
	
    vec4 c = vec4( vec2(-0.05,.6805) + p*zo, 1.0, 0.0 );

	float m2 = 0.0;
    float co = 0.0;
	
	vec4 z = vec4( 0.0, 0.0, 0.0, 0.0 );
	
    for( int i=0; i<256; i++ )
    {
        if( m2>1024.0 ) continue;
			
        // Z -> Z² + c		
		z = dcAdd( dcSqr(z), c );
		
		m2 = dot( z.xy, z.xy );
        co += 1.0;
    }

    // distance	
	// d(c) = |Z|·log|Z|/|Z'|
	float d = 0.0;
	if( co<256.0 ) d = sqrt( dot(z.xy,z.xy)/dot(z.zw,z.zw) )*log(dot(z.xy,z.xy));

	
    // do some soft coloring based on distance
	d = clamp( 4.0*d/zo, 0.0, 1.0 );
	d = pow( d, 0.25 );
    vec3 col = vec3( d );
    
    fragColor = vec4( col, 1.0 );
}