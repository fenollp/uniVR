// Shader downloaded from https://www.shadertoy.com/view/MsK3WW
// written by shadertoy user bitgrinder
//
// Name: Sin Wavey Van Damme
// Description: Just wavy effect at the right speed and scale to compliment Van Damme's antics.
//    This is just a modification of https://www.shadertoy.com/view/4ljSDh#
//    originally by user: https://www.shadertoy.com/user/Hanley
//This is borrowed from: https://www.shadertoy.com/view/4ljSDh#
//originally by user: https://www.shadertoy.com/user/Hanley
// its only slightly modified to make it much more funny
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalised pixel position
	vec2 uv = fragCoord.xy / iResolution.xy; // pixelPos_n
    
    // Amount to offset a row by
    float rowOffsetMagnitude = sin(iGlobalTime*10.0) * 0.05;
    
    // Determine the row the pixel belongs too
    float row = floor(uv.y/0.001);
    // Offset Pixel according to its row
    uv.x +=  sin(row/100.0)*rowOffsetMagnitude;
    
    // set pixel color
    fragColor = texture2D(iChannel0, uv);
}