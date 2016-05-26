// Shader downloaded from https://www.shadertoy.com/view/XsKSDz
// written by shadertoy user Ippokratis
//
// Name: Simple radial mask
// Description: A simple radial mask.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy) / iResolution.y;
    
   	float r_in = 0.15;         // inner limit of the mask
   	float r_out = 0.2;        // outer limit of the mask
    						// inner-outer = grey transition from white to black
							// if inner>outer, the transition inverses from white->black to black->white    
    
	vec2 pos =   vec2( iMouse.xy/iResolution.y)-vec2(iResolution.x/iResolution.y,1.);
    // the position of the mask, 0-1 left - right, bottom - top
	
    float radius = length( uv-pos );

 	float mask = ( radius-r_in ) / ( r_out-r_in );
    
	fragColor = vec4( mask );
}