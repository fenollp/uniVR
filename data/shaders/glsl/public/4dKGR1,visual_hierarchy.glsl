// Shader downloaded from https://www.shadertoy.com/view/4dKGR1
// written by shadertoy user eiffie
//
// Name: Visual Hierarchy
// Description: Testing the difference in speed/quality between standard march and the hierarchical method explored by Dave. After testing on several machines all I can say is its VERY machine dependent.
//    
//The hierarchy test is in buf A
//the original is from Dave Hoskins https://www.shadertoy.com/view/4tfXDN

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(texture2D(iChannel0,uv).rgb,1.0);
}