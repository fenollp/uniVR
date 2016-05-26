// Shader downloaded from https://www.shadertoy.com/view/ltfXDN
// written by shadertoy user aiekick
//
// Name: Particle Experiment 8
// Description: Particle Experiment 8
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{       
	fragColor = texture2D(iChannel0, fragCoord/iResolution.xy);
}
