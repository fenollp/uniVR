// Shader downloaded from https://www.shadertoy.com/view/XsSGRh
// written by shadertoy user iq
//
// Name: Sierpinski - 5x5 Carpet
// Description: A Sierpinski-Carpet-like structure, but in a 5x5  arragement. At every iteration, the whole unit square is divided in 5x5 sub-squares and the subsquares subsquares at (1,1), (3,1), (1,3) and (3,3) get removed.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// A Sierpinski Carpet like structure (2D Cantor). Instead of removing the central square 
// of a 3x3 subdivided square, in this shader I divide the square in 5x5 sub-squares and I 
// remove the four in the corners of the central one.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // animate	
    float s = 0.1*smoothstep( 0.7, 1.0, sin(3.1416*iGlobalTime) );
	
    // unit square covering the whole screen
	vec2 z = fragCoord.xy / iResolution.xy;

    // make it all white
    float f = 1.0;
	
    // iterate	
	for( int i=0; i<4; i++ ) 
	{
        //remove subsquares (1,1), (3,1), (1,3) and (3,3)
		f *= 1.0 - step( abs(abs(z.x-0.5)-0.2), 0.1-s )*step( abs(abs(z.y-0.5)-0.2), 0.1-s );
        // scale the shole thing down by a factor of 5
		z = fract( z*5.0 );
	}
	
	fragColor = vec4( f, f, f, 1.0 );
}
