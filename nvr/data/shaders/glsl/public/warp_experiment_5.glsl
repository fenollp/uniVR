// Shader downloaded from https://www.shadertoy.com/view/XstGzN
// written by shadertoy user aiekick
//
// Name: Warp Experiment 5
// Description: Warp Experiment 5
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.*fragCoord.xy - iResolution.xy)/iResolution.y;
    
    float r = length(uv);
    
    uv.x = r*r/uv.x;
    uv.y = uv.y/r/r;
    
    uv.x -= iGlobalTime; 
    
	vec2 ofs = .03 * vec2(1,.5);
    
	fragColor = 
        vec4( 
            texture2D(iChannel0, uv ).r,
            texture2D(iChannel0, uv-ofs ).g,
            texture2D(iChannel0, uv-ofs*2.).b,
            1 
        );
}