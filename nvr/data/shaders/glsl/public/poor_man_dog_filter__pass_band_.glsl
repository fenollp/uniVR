// Shader downloaded from https://www.shadertoy.com/view/lsVGRd
// written by shadertoy user FabriceNeyret2
//
// Name: poor man DoG filter (pass band)
// Description: band-pass filter can be approximate easily with differences in MIPmapping.
//    This can  be used for edge detection, or for reinforcing or suppressing elements at one given scale.
void mainImage( out vec4 O,  vec2 U )
{
	U /= iResolution.xy; 
    float t = mod((iGlobalTime),12.); 
    bool m = t>=6.; if (m) t = 12.-t;
    t = floor(t); // comment for continuous tuning
    
    // poor man DoG (differential of Gaussians) - for band detection
    vec4 d = texture2D(iChannel0,U,t+1.)-texture2D(iChannel0,U,t);
    
    O = m ?  texture2D(iChannel0,U,0.) - d*2. * step(.5,U.x) // right: enforce the band
          :  .5 +  d*2.;  // display the band filtering of the image
}