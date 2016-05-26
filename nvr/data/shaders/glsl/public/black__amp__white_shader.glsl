// Shader downloaded from https://www.shadertoy.com/view/XsV3Rd
// written by shadertoy user doubleoseven1
//
// Name: Black &amp; White Shader
// Description: Turns a picture or video black and white. 
// This code is run for each pixel

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Make the fragCoordinate within the range of 0 and 1
	vec2 xy = fragCoord.xy / iResolution.xy;
   
    // Rrutrn the color of the texture in Channel0
    vec4 texColor = texture2D(iChannel0, xy);
    
 	// Initialize the variables
    vec4 white = vec4(1, 1, 1, 1);
    vec4 black = vec4(0, 0, 0, 1);
    
    // Average the color out
	float average = texColor.r + texColor.g + texColor.b/3.0;
    
    // Check if it's closer to white or black
    if (average <= 0.5)
    {
        texColor = black;
    }
    else 
        texColor = white;

  	// sets the pixels color
    fragColor = texColor;
}