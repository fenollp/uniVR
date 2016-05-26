// Shader downloaded from https://www.shadertoy.com/view/XstXWB
// written by shadertoy user Dave_Hoskins
//
// Name: Tiling a Texture
// Description: Creating a simple tiled texture. Merging the left and right edges together and then doing the top and bottom on a second pass.
//    Most of Shadertoy's textures are tile-able anyway.
// This just shows the final result tiled.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 xy = fragCoord.xy / iResolution.xy;
    fragColor = texture2D(iChannel0, fract(xy * (mod(floor(iGlobalTime*.5), 4.0)+1.0))); //'fract' is there because I can't use 'repeat' on buffered textures here.
      
}