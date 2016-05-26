// Shader downloaded from https://www.shadertoy.com/view/Xsl3WH
// written by shadertoy user 4rknova
//
// Name: Sine Line
// Description: A simple sine line.
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

#define A .1 // Amplitude
#define V 8. // Velocity
#define W 3. // Wavelength
#define T .1 // Thickness
#define S 3. // Sharpness

float sine(vec2 p, float o)
{
    return pow(T / abs((p.y + sin((p.x * W + o)) * A)), S);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy * 2. - 1.;
	fragColor = vec4(vec3(sine(p, iGlobalTime * V)), 1);
}