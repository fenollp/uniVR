// Shader downloaded from https://www.shadertoy.com/view/XsyXDh
// written by shadertoy user wjbgrafx
//
// Name: Kaliset Variations
// Description: Variations on the Kaliset Fractal, based on 'Simplicity', uploaded by JoshP on 2013-May-7 : https://www.shadertoy.com/view/lslGWr
/* 'Kaliset Variations' by wjbgrafx 
   
    Minor modifications to code from 'Simplicity', uploaded by JoshP on 2013-May-7 
    https://www.shadertoy.com/view/lslGWr
*/
//================================================================================

float field( vec3 p ) 
{
	// Pattern fades out at around 310 seconds. Rather than figure out why, just
    // reverse the time between 310 and 620 seconds ( You're *still* watching this!? )
    float time = mod( iGlobalTime, 620.0 );
    time = time > 310.0 ? 620.0 - time : time;
	    
    //float strength = 7.0 + 0.03 * log( 1.e-6 + fract( sin( time ) * 4373.11 ) ),
	// Smaller value of 'strength' = brighter image
	float strength = 4.0 - sin( time * 0.0005 ),
	      //power = 2.3,
	      power = 2.3 + sin( time * 0.003 ),
	      accum = 0.0,
	      prev = 0.0,
	      tw = 0.0;
	      
	for ( int i = 0; i < 32; i++ ) 
	{		
		float mag = dot( p, p ),
		      w = exp( -float( i ) / 7.0 );
		
		p = abs( p ) / mag + vec3( -0.5, -0.4, -1.5 );
		//accum += w * exp( -strength * pow( abs( mag - prev ), 2.3 ) );
		accum += w * exp( -strength * pow( abs( mag - prev ), power ) );
		tw += w;
		prev = mag;
	}
	
	return max( 0.0, 5.0 * accum / tw - 0.7 );
}
//------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float time = mod( iGlobalTime, 620.0 );
    time = time > 310.0 ? 620.0 - time : time;


    // 'uv' is a -1 to 1 range coord in both x and y ( without aspect ratio ).
	// 'uvs' is a -1 to 1 range coord in x, and a y-range of -y/x to +y/x =
	// smaller values since yres is smaller.
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - 1.0;
	vec2 uvs = uv * iResolution.xy / max( iResolution.x, iResolution.y );	
	
	//----------------------------------------------------------
	// Original - off-center image
	//vec3 p = vec3( uvs / 4.0, 0.0 ) + vec3( 1.0, -1.3, 0.0 );
	
	// Movement via altering the z position of off-center image
	//vec3 p = vec3( uvs / 4.0, 0.0 ) + vec3( 1.0, -1.3, time * 0.01 );
	
	// Altering z position of centered image
	//vec3 p = vec3( uvs / 4.0, time * 0.01 );// + vec3( 1.0, -1.3, time * 0.01 );
	
	// Using time to zoom in on the off-center image
	//vec3 p = vec3( uvs / (4.0 + time * 0.1 ), 0.0 ) + vec3( 1.0, -1.3, 0.0 );

	// Using time to zoom out of the centered image
	//vec3 p = vec3( uvs / (4.0 - time * 0.1 ), 0.0 );// + vec3( 1.0, -1.3, 0.0 );
	
	// Altering z position of centered image while slowly zooming in
	//vec3 p = vec3( uvs / exp( time * 0.005 ), time * 0.01 );
	
	// Very slow zoom-in
	//vec3 p = vec3( uvs / exp( time * 0.005 ), log( time * 0.01 ) );
	
	//--------------------------------------------------------------
	
	// Altering z position of centered image while slowly zooming out
	vec3 p = vec3( uvs / log( time * 0.001 ), exp( time * 0.005 ) );
	
	//----------------------------------------------------------
	
	// Moves the image around the screen in original code
	//----------------------------------
//	float transRate = 0.2;	
//	p += transRate * 
//	       vec3( sin( time / 16.0 ), sin( time / 12.0 ), sin( time / 128.0 ) );
	//----------------------------------
	
	// 'v' ranges from 0 at the edges of the screen, and rapidly approaches
	// 1.0 ( without equalling it ) towards the center of the screen; i.e.,
	// 1/10th of the way from edge to center, 'v' already equals about 0.45;
	// 1/4 of the way, 'v' equals about 0.75; 1/2 of the way, 'v' equals about
	// 0.9475; 3/4 of the way, 'v' equals about 0.986. This applies when the
	// multiplier = 6.0. A smaller multiplier makes the range smoother, larger
	// makes the range increase very rapidly moving away from the edges, but 
	// still approaching but not reaching 1.0.
	float t = field( p ),
	      v = ( 1.0 - exp( ( abs( uv.x ) - 1.0 ) * 6.0 ) ) * 
	          ( 1.0 - exp( ( abs( uv.y ) - 1.0 ) * 6.0 ) );
	          
//------------------------------------------------------------------
// Original
// -------- Mixing based on 'v' makes multiplier of final color 0.4 at the 
// edges, rapidly increasing towards 1.0 at the center ( see value of 'v', above).
	
//	fragColor = mix( 0.4, 1.0, v ) * vec4( 1.8 * t * t * t, 
//	                                          1.4 * t * t, t, 1.0 );
//------------------------------------------------------------------
// Modified original
// -----------------

	float rTime = time * 0.05,
		  gTime = time * 0.03,
	      bTime = time * 0.01,
	      red = mod( ( 1.1 + sin( rTime) ) * t * t * t + rTime, 2.0 ),
	      grn = mod( ( 1.1 + sin( gTime ) ) * t * t + gTime, 2.0 ),
	      blu = mod( t + bTime, 2.0 );
	      
	red = red > 1.0 ? 2.0 - red : red;
	grn = grn > 1.0 ? 2.0 - grn : grn;
	blu = blu > 1.0 ? 2.0 - blu : blu;	      
	
	fragColor = mix( 0.05, 1.1 + sin( bTime ), v ) * vec4( red, grn, blu, 1.0 );
		
//------------------------------------------------------------------
	
// Simple greyscale
//	fragColor = vec4( t, t, t, 1.0 );

//------------------------------------------------------------------

// Abhuese
/*
	float red = mod( t * t + v * v, 2.0 ),
	      grn = t * v,
	      blu =  dot( t, v );
	      
	red = ( red > 1.0 ) ? 2.0 - red : red;
	
	red = mod( red + grn, 1.0 );
	grn = mod( grn + blu, 1.0 );	      
	blu = mod( blu + red, 1.0 );

	fragColor = vec4( red,grn,blu, 1.0 );
*/
//------------------------------------------------------------------

// ( and now for ) Something completely different
/*
	float red = t,
	      grn = v,
	      blu = t + v;
	      	      
	fragColor = vec4( red,grn,blu, 1.0 );
*/

//------------------------------------------------------------------

// Something else entirely
/*	
	float red = mod( 2.0 * t * t * t, 2.0 ),
	      grn = mod( red * t * t, 2.0 ),
	      blu = mod( grn * t, 2.0 );
	      
	      
	red = red > 1.0 ? 2.0 - red : red;
	grn = grn > 1.0 ? 2.0 - grn : grn;
	blu = blu > 1.0 ? 2.0 - blu : blu;
		                                               
	fragColor = vec4( red,grn,blu, 1.0 );
*/
}

