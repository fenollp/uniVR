// Shader downloaded from https://www.shadertoy.com/view/Mdt3Dl
// written by shadertoy user sixstring982
//
// Name: Buddha-brot
// Description: Buddhabrot fractal. Takes a while to generate (about 15 mins before it starts looking like the buddhabrot on my machine). Adjust Buf D's scaling parameters as the image generates.
/**
 *  Buddha-brot
 *  sixstring982 2016
 *
 *  The Buddhabrot fractal, discovered by Melinda Green in the
 *  1990s. This uses three Multipass buffers, one for each color
 *  channel. Each has an iterations parameter at the top; playing
 *  with these will change the generated image.
 *
 *  The buddhabrot takes a long time to generate, and isn't easy
 *  to parallelize in the manner that Shadertoy likes to parallelize
 *  things. Therefore, it takes a long time to generate the final
 *  image (about 15 mins on my machine).
 *
 *  Normally, the image brightness can be automatically adjusted
 *  by finding the brightest pixel and normalizing the rest to it,
 *  but this isn't easy to do with Shadertoy at the moment. Instead,
 *  the two parameters at the top of Buf D can help adjust the image
 *  brightness. Buf D also applies anti-aliasing, which can be
 *  adjusted as well.
 */

// This can be tweaked once enough of the image has been
// generated
#define LOG_SCALE 100.0

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
	fragColor = texture2D(iChannel3, uv);
}