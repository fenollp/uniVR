// Shader downloaded from https://www.shadertoy.com/view/lt2SDm
// written by shadertoy user Mx7f
//
// Name: Circular Sound Visualizer
// Description: Very simple sound visualizer; value of the green channel is equal to the frequency value at the x coordinate corresponding to distance from the center.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 h = (iResolution.xy*0.5);
	float r = length((fragCoord.xy - h) / h.y);
    fragColor = vec4(0.0,r > 1.0 ? 0.0 : texture2D( iChannel0, vec2(r,0.25) ).x,0.0, 1.0);  
}
