// Shader downloaded from https://www.shadertoy.com/view/4stGWn
// written by shadertoy user aiekick
//
// Name: Warp Experiment 7
// Description: Warp Experiment 7
#define Arms 2.*sin(iGlobalTime*.2)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.*fragCoord - iResolution.xy)/iResolution.y;
    
	float a = atan(uv.x, uv.y) * 0.4779 * floor(Arms)/3.;
    
	uv = vec2(length(uv) + a);
    
	vec2 vv = vec2(mod(iGlobalTime, 10.)*.1, 0.);
    
	fragColor = texture2D(iChannel0, uv - vv);
}
