// Shader downloaded from https://www.shadertoy.com/view/Xs3GzM
// written by shadertoy user FabriceNeyret2
//
// Name: Warp Experiment 5b
// Description: a video variant of aiekick's https://www.shadertoy.com/view/XstGzN#
//    only change: tile and checker-flip video
// adapted from https://www.shadertoy.com/view/XstGzN#

void mainImage( out vec4 fragColor, vec2 uv )
{
	vec2 R=iResolution.xy;
    uv = (2.*uv - R) / R.y;
    
    float r = length(uv);
    
    uv.x = r*r/uv.x;
    uv.y = uv.y/r/r;
    
    uv.x -= iGlobalTime; 
    
    uv = mod(uv+.5,2.); uv -=2.*clamp(uv-1.,0.,1.); // tile and flip
    
	fragColor = texture2D(iChannel0, uv);
}