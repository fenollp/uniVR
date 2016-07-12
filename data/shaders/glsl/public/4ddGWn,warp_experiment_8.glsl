// Shader downloaded from https://www.shadertoy.com/view/4ddGWn
// written by shadertoy user aiekick
//
// Name: Warp Experiment 8
// Description: Warp Experiment 6
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 3. * (2.*fragCoord - iResolution.xy) / iResolution.y;
	
	uv *= dot(uv, uv) * .3;
	
	float r = mod( floor(uv.x-iGlobalTime) + floor(uv.y), 2.);
	
	fragColor = vec4(r);
}
