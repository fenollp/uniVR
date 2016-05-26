// Shader downloaded from https://www.shadertoy.com/view/MsdGD2
// written by shadertoy user iq
//
// Name: One Sample Blur
// Description: How to do a 2x2 box blur with a single texture sample.
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Trick: take one single texture sample at the very corner of a texel, right where the 
// four texels meet. That way the bilinear filtering hardware will average the four
// pixels for you, meaning you no longer need to sample the texture four tims in order
// to do a downsample or a box blur operation. This can be useful if you need a fast
// reduction of your framebuffer to half resolution for doing SSAO or some postprocessing 
// effect.
//
// This shader shows the technique by blurring an image repeatedly with only ONE texture
// sample.
//
// A more advanced use of this for gaussian blurs here: https://www.shadertoy.com/view/Xd33Rf


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = texture2D( iChannel0, fragCoord / iResolution.xy );
}