// Shader downloaded from https://www.shadertoy.com/view/MscGDf
// written by shadertoy user wjbgrafx
//
// Name: psychedeliscope v2
// Description: Vertex coordinates of polygons of varying number of sides and radii are calculated and connected with lines to form &quot;star polygons&quot;. - FIXED
//    
/*
	Psychedeliscope
	===============

	1-05-16	
	Recreating an old java applet in a shader.	
	
	I first encountered "star polygons" in Robert Dixon's 1987 book,
	'Mathographics' ( pg. 126 ). 
	
	One of the formulas in the "Computer Drawings" chapter shows how a star 
	polygon of a given number of points can be drawn, working in polar
    coordinates. The formula is roughly this :

	For a polygon of N points and S sides:
 
	for( S = 0; S <= N; S++ )
                                             
    Angle = 360 * S * M / N; // where M is a whole number between 1 and N
                             // which shares no common factor with N. 

	The angle increment from one star point to the next is determined by this
	equation, above, and then the polar coordinates ( angle, radius ) are
	converted to Cartesian with these equations:
	
                       x = R * Cos( Angle );
                       y = R * Sin( Angle );
                       
	If values of M and N are chosen which do share a common factor, the angle 
	increment is still 360 * M / N, but since M / N can be reduced by a common 
	factor, the number of sides in the polygon is the reduced value of N, and 
	that polygon is drawn over itself the reduced value of M times.
    
    For example, if M = 8 and N = 12, 8 / 12 = 2 / 3, and a 3-sided polygon is
    drawn in the exact same position, 2 times.
 		
*/
//==============================================================================

// cosine based palette, 4 vec3 params
// http://www.iquilezles.org/www/articles/palettes/palettes.htm

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b * cos( 6.28318 * ( c * t + d ) );
}

//------------------------------------------------------------------------------

// IQ rainbow palette.

vec3 b = vec3( 0.5, 0.5,  0.5 ),
     c = vec3( 0.5, 0.5,  0.5 ),
     d = vec3( 1.0, 1.0,  1.0 ),
     e = vec3( 0.0, 0.33, 0.67 );		

//------------------------------------------------------------------------------

float random( vec2 p )
{
	return fract( sin( dot( p.xy, vec2( 12.9898, 78.233 ) ) ) * 
	                                             43758.5453123 + iGlobalTime );
}
	                                                           
//------------------------------------------------------------------------------

// DRAW LINE : antialiased
// =========

// by mlatu
// https://stackoverflow.com/questions/15276454/
//                   is-it-possible-to-draw-line-thickness-in-a-fragment-shader

float drawLine( vec2 p1, vec2 p2, vec2 uv, float thickness ) 
{
	float a = abs( distance( p1, uv ) ),
	      b = abs( distance( p2, uv ) ),
	      c = abs( distance( p1, p2 ) );
	
	if ( a >= c || b >=  c ) return 0.0;
	
	float p = (a + b + c) * 0.5;
	
	// median to ( p1, p2 ) vector
	float h = 2.0 / c * sqrt( p * ( p - a ) * ( p - b ) * ( p - c ) );
	
	return mix( 1.0, 0.0, smoothstep( 0.5 * thickness, 1.5 * thickness, h ) );
}

//------------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// -1 to 1 screen
	// --------------
	// Adjust aspect ratio, normalize coords, center origin in xy-plane.	
	// xRange = -1.7777778 to 1.775926, yRange = -1.0 to 0.9981482 at 1920x1080
	vec2 curPix = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;

	float time = iGlobalTime;
	
	// Rotating screen.
	//-----------------	
	float x = curPix.x,
	      y = curPix.y,
	      ang = 2.0 * sin( time * 1.5 ); 
	
	curPix.x += x * cos( ang ) - y * sin( ang );
	curPix.y += x * sin( ang ) + y * cos( ang );	
	//--------------------------------------
	
	// ( 1.0 - abs( 2.0 * fract( time ) - 1.0 ) ) produces a linear progression
	// from 0.0 to 1.0 to 0.0.
	
	int numSides =  
	       4 + int( 24.0 * ( 1.0 - abs( 2.0 * fract( time * 0.05 ) - 1.0 ) ) ),
	    
	    // Randomized numRevs value makes fuzzy figures. 
	    // Larger multiplier = fuzzier.
	    //numRevs = 17 + int( random( curPix ) * 1.5 ); // * 3.0
	    
	    // Constant numRevs for sharp lines. 17 is lowest prime that avoids 
	    // drawing straight horizontal lines	
	    numRevs = 17; 
	
	float angle = 0.0,
	      maxPolyRadius = 2.25,

		  // A linear radius size progression.
//	      polyRadius = maxPolyRadius *  
//	                                ( 1.0 - abs( 2.0 * fract( time ) - 1.0 ) ),
	      
	      // Controls speed of radius size change for non-linear progression.
	      t = time,// * 2.0,
	      
	      // A non-linear radius size progression
	      polyRadius = maxPolyRadius * ( abs( sin( t * 1.63 ) * 
	                                    sin( t * 1.79 ) + sin ( t * 2.39 ) ) ),
	      oldx = 0.0,
	      oldy = 0.0,
	      firstx = 0.0,
	      firsty = 0.0,
	      //thickness = 0.025,
	      thickness = 0.0075 +  // minimum line thickness plus varying
	                          // additional thickness over time.
	                0.05 * ( 1.0 - abs( 2.0 * fract( time * 0.025 ) - 1.0 ) ),	                                                                 
	      clr = 0.0;	    
	
	// POLYGON DRAWING LOOP. ( Sets the value of 'clr' to non-zero in the 
	// drawLine() function to indicate the current pixel is part of a line,
	// if it is. The pixel's color is not set until this loop completes. )
	// ---------------------
	
    const int maxSides = 28;
    // Because loop index must be compared with a constant expression, the value
    // of 'numSides' is used within the loop to break out, rather than in the
    // 'for(... ) line. This value should be >= the actual maximum value
    // numSides can be assigned, above.
    
    for( int curSide = 0; curSide < maxSides; curSide++ )
    {
        angle = 360.0 * float( curSide ) * float( numRevs ) / float( numSides );
                                                    
        x = polyRadius * cos( radians( angle ) );
        y = polyRadius * sin( radians( angle ) );
        
        if ( curSide == 0 )
        {
        	//Store the first coord
        	firstx = x;
        	firsty = y;
        }
        else
        {
        	clr += drawLine( vec2( oldx, oldy ), vec2( x, y ), 
        	                                               curPix, thickness );       
        	// Connect the last vertex to the first.
        	if ( curSide == numSides - 1 )
        	{
        		clr += drawLine( vec2( firstx, firsty ), vec2( x, y ), 
        		                                           curPix, thickness );	
				break;
            }
		}        		                                           
        	
        oldx = x;
        oldy = y;
        	
	}
	
	// end polygon drawing loop
	
	//----------------------------------------------------------------
	
	// Prevent erasure of previous drawing by drawing only pixels with
	// non-zero values, and discarding those with a zero value.
	if ( clr != 0.0 )
	{	
		// Modifiying the b vector components of the rainbow palette over time.		
		b  = vec3( fract( sin( time * 0.07 ) ),
				   fract( sin( time * 0.13 ) ),	
				   fract( sin( time * 0.11 ) ) );
				  
		vec3 color = palette( fract( clr + clr + time ), b, c, d, e );				
		fragColor = vec4( color, 1.0 );
		
		// Low alpha value blends colors but looks blurrier and not as bright.
		//fragColor = vec4( color, 0.2 );
		
		// Grey-scale figures only. Can combine with black screen erase.
		//fragColor = vec4( vec3( clr ), 1.0 );
	}
	else
    {
		//-------------------------------------------------------------------
		// I think I read somewhere that the shadertoy app disregards the alpha
	    // value, so these comments don't apply here.
	        
	    // ERASE occasionally. The alpha value can be set low to make the old
		// drawing fade out slowly, rather than abruptly disappearing.
		
		// With a very low alpha value, a larger compare value is needed to 
		// erase the background completely. When alpha = 0.15, compare needs to 		 
		// be around 0.0075 to erase ( almost ) completely. 	
		float compare = 0.001,
		      alpha = 1.0;
		
		if ( 1.0 + sin( time * 0.5 ) < compare )
		{
			//fragColor = vec4( vec3( 0.0 ), 0.175 );
			
			// Erase to black screen:
			//fragColor = vec4( vec3( 0.0 ), 1.0 );
			
			// Erase to current palette color:
			// Adjust the 'compare' value so that it's low enough to prevent 
			// the entire screen flashing through multiple erase colors before
			// drawing starts again.
			vec3 color = palette( clr + time, b, c, d, e );				
			fragColor = vec4( fract( color.r ), fract( color.g ), 
			                                       fract( color.b ), alpha );
		}
		//-------------------------------------------------------------------	
	    else
	    {
	        discard;   
	    }
    }

}