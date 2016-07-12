// Shader downloaded from https://www.shadertoy.com/view/lljSRt
// written by shadertoy user Donzanoid
//
// Name: Eye Trickery
// Description: Monotonic, non-linear gradient gives illusion that the boundary between inner/outer circles is darker than inner circle.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float i = length(uv * 2.0 - 1.0);
    
    // Source range to carve up
    float s0 = 0.495;
    float s1 = 0.505;
    
    // Destination range to interpolate between source points
    float d0 = 0.45;
    float d1 = 0.1;
    
    // Range map scales
    float k0 = d0 / s0;
    float k1 = d1 / (s1 - s0);
    
    // Rectangle window
    i = i < s0 ? i = i * k0 :
    	i < s1 ? i = d0 + (i - s0) * k1 :
    	d0 + d1 + (i - s1) * k0;
    
    fragColor = vec4(i, i, i, 1.0);
}