// Shader downloaded from https://www.shadertoy.com/view/ldyGDD
// written by shadertoy user weyland
//
// Name: Scope Multipass Feedback
// Description: Cheap quick and dirty feedback and scope fun, hacked together from multiple shaders
//    
//    updated with smoother falloff and feedback, feel free to put your own audio in channel0 in buf A
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}