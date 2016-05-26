// Shader downloaded from https://www.shadertoy.com/view/4stGzN
// written by shadertoy user aiekick
//
// Name: Warp Experiment 6
// Description: Warp Experiment 6
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.*fragCoord.xy - iResolution.xy)/iResolution.y;
    
    uv = length(uv) - vec2(iGlobalTime*.5, atan(uv.x, uv.y) * 0.4775 * floor(5. * sin(iGlobalTime*0.2)));
    
	fragColor = texture2D(iChannel0, uv);
}