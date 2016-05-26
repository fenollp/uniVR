// Shader downloaded from https://www.shadertoy.com/view/XddGWj
// written by shadertoy user Flyguy
//
// Name: Lorenz Attractor Scope
// Description: A Lorenz attractor plotter thing made to look like an analog oscilloscope. Lower the speed to see the motion more clearly.
#define COLOR_BACK vec3(0.10, 0.10, 0.10)
#define COLOR_TRACE vec3(0.10, 1.10, 0.50)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float b = texture2D(iChannel0, uv).x;
    
	fragColor = vec4(mix(COLOR_BACK, COLOR_TRACE, b), 1.0);
}