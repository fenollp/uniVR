// Shader downloaded from https://www.shadertoy.com/view/XtsXWB
// written by shadertoy user MrBodean
//
// Name: Background Vertical Scroller
// Description: THis is a test for background scroll based on https://www.shadertoy.com/view/ltB3Dc
const float pixelSize  =    1.00; // base pixelization 			   <- set this to desired pixel size
const float zoom       =   1.00; // zoom range
const float radius     = 3600.00; // planar movement radius
const float speed      =    0.05; // zoom / move speed

////////////////////////////////////////////////////////////////////////////////////////////////////

float time   = iGlobalTime * speed;
float scale  = pixelSize + ((sin(time / 3.7) + 1.0) / 2.0) * (zoom - 1.0) * pixelSize;

vec2  center = iResolution.xy / 1.0;
vec2  offset = vec2(0, sin(time)) * radius;

////////////////////////////////////////////////////////////////////////////////////////////////////

void mainImage( out vec4 color, in vec2 pixel )
{
    // add some movement:
    pixel = ((pixel + offset) - center) / scale + center;

    // basic sampling:
    vec2 uv = floor(pixel) + 0.5;
    
    // subpixel filtering algorithm (comment out to compare):
    uv += 1.0 - clamp((1.0 - fract(pixel)) * scale, 0.0, 1.0);

   	color = texture2D(iChannel0, uv  / iChannelResolution[0].xy);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// alternative version with split-screen side-by-side comparison vs regular discrete-pixel rendering:
// https://www.shadertoy.com/view/ltB3Dc












//     try
//    other
//   bitmaps
//     _|_
//     \ /
//      V                      note: this technique doesn't work with bitmaps that use point sampling (nyan cat, 8x8 checkerboard)