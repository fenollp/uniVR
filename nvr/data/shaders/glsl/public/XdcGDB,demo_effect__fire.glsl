// Shader downloaded from https://www.shadertoy.com/view/XdcGDB
// written by shadertoy user 4rknova
//
// Name: Demo Effect: Fire
// Description: The classic fire effect
// by Nikos Papadopoulos, 4rknova / 2016
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage(out vec4 c, vec2 p)
{
	c = texture2D(iChannel0, p.xy / iResolution.xy);
    c = 1. - cos(c*3.14159/1.3); // Contrast
	c = vec4(min(c.x*1.7, 1.), pow(c.x, 2.6), pow(c.x, 10.), 1); // Palette
}