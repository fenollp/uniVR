// Shader downloaded from https://www.shadertoy.com/view/4sySzw
// written by shadertoy user cornusammonis
//
// Name: Obra Dinn Dithering
// Description: An implementation of the dithering shader in Return of the Obra Dinn.
/*
	This shader implements the dithering scheme created by Koloth (Brent Werness) 
	used in the game Return of the Obra Dinn. This version makes the changes necessary
	to run the shader in a lower GLSL version. In the original implementation,
	the error diffusion is run a fixed number of times (36 in the Processing version),
	but here the error diffusion is allowed to run continuously.

	Based on this Processing implementation:
	https://github.com/akavel/WernessDithering
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(texture2D(iChannel0, uv).z);
}