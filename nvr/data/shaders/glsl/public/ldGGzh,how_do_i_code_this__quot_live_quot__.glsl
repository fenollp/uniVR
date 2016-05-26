// Shader downloaded from https://www.shadertoy.com/view/ldGGzh
// written by shadertoy user mds2_oblong
//
// Name: How do I code this &quot;live&quot;?
// Description: A test to see how I can share a live-coding session with another participant (if at all possible)
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}