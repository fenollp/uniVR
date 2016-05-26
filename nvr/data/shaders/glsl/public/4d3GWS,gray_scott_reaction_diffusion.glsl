// Shader downloaded from https://www.shadertoy.com/view/4d3GWS
// written by shadertoy user Eybor
//
// Name: Gray Scott Reaction Diffusion
// Description: An implementation of Gray Scott Model of Reaction Diffusion using multipass shaders . When your display is resized you can use the space bar in order for the image to be resized too.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
        
	fragColor = texture2D(iChannel0, uv);
}