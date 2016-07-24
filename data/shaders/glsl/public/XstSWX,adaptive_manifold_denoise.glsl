// Shader downloaded from https://www.shadertoy.com/view/XstSWX
// written by shadertoy user cornusammonis
//
// Name: Adaptive Manifold Denoise
// Description: A cheap and relatively effective denoising/smoothing technique that preserves hard edges.
/*
	Adaptive Manifold Denoise

	Loosely based on this approach: http://inf.ufrgs.br/~eslgastal/AdaptiveManifolds/

	Computes three filters: a standard gaussian blur, a max filter, and a min filter.
	The max and min filters are computed using normalized convolution on color values
    greater than or less than the gaussian blur value (respectively). The three filtered
	images are blended together using normalized convolution, with weights determined
    by the distance between the color values in the original image and the color values
    in each of the filtered images.

	The noise level and the gaussian width in the final blending pass are animated to
    demonstrate the use of this filter for both smoothing and denoising.
*/

#define STDEV 0.2	// max gaussian width

vec4 gaussian(vec4 x, vec4 m, float s) {
    return exp(-(x-m)*(x-m)/(s*s));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    bool ypass = mod(float(iFrame), 2.0) >= 1.0;
    if (ypass) {
        vec4 smax = texture2D(iChannel0, uv);
        vec4 smin = texture2D(iChannel1, uv);
        vec4 savg = texture2D(iChannel2, uv);
        vec4 nois = texture2D(iChannel3, uv);
        
        // the gaussian width is animated in sync with the noise amount. 
        // generally a larger width is better for noisier data
        float s = STDEV * (sin(iDate.w) + 1.3);
        
        vec4 gmax = gaussian(smax, nois, s);
        vec4 gmin = gaussian(smin, nois, s);
        vec4 gavg = gaussian(savg, nois, s);
        vec4 gsum = gmax + gmin + gavg;
        gmax /= gsum;
        gmin /= gsum;
        gavg /= gsum;

        vec4 res = gmax * smax + gmin * smin + gavg * savg;
    
        if (uv.x < 0.5) {
            fragColor = res;
        } else {
            fragColor = nois;
        }
    } else {
        // discard every other frame, because the buffers haven't completed both blur passes
        discard;
    }

}