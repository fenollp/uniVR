// Shader downloaded from https://www.shadertoy.com/view/4lXXDH
// written by shadertoy user 4rknova
//
// Name: Filter: Pixelize
// Description: A simple pixelization filter.
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define S (iResolution.x / 6e1) // The cell size.

void mainImage(out vec4 c, vec2 p)
{
    c = texture2D(iChannel0, floor((p + .5) / S) * S / iResolution.xy);
}