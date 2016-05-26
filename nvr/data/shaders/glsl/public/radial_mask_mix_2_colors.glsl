// Shader downloaded from https://www.shadertoy.com/view/XdVXDz
// written by shadertoy user Ippokratis
//
// Name: Radial mask mix 2 Colors
// Description: Mix 2 colors via a radial mask. Thanks LaBodilsen for suggesting using mouse coords
vec4 rgb (vec4 inCol)       // Use rgb values for defining colors
{
	return inCol/vec4(255.0); // rgb/255 = 0-1 range glsl colors
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / vec2(100.0);// iResolution.xy makes the circle elipse, so I use a "virtual" 
    									//	resolution of 100:100
    normalize(uv);
   	float r_in = 0.0;         // inner limit of the mask 
   	float r_out = 3.0;       // outer limit of the mask 
    							
    						 // inner<outer = transition colA->colB
							// if inner>outer, the transition inverses from colA->colB to colB->colA   
    
	vec2 pos = vec2( iMouse.xy/vec2(100.0) );  // Click / click'n'drag on the screen to define new position
    										  // Thanks LaBodilsen for the suggestion
                                             // https://www.shadertoy.com/user/LaBodilsen
    										// vec2(100) used as above 		
    float radius = length( uv-pos );

 	float mask = ( radius-r_in ) / ( r_out-r_in );
    
    vec4 colA = rgb( vec4( 125.0, 91.0, 95.0, 255.0 ) ); //turn rgb values to glsl float 0-1 values
    vec4 colB = rgb( vec4( 222.0, 131.0, 112.0, 255.0 ) );
    
    vec4 col = mix( colA, colB, mask);
	col = min( col, colB);    // Make sure that the color will be colB, not white
	col = max( col, colA);   // Make sure that the color will be colA, not black

    fragColor = col;
}