// Shader downloaded from https://www.shadertoy.com/view/ldVGR1
// written by shadertoy user Impossible
//
// Name: Forest fire
// Description: Forest fire cellular automata.
//    https://en.wikipedia.org/wiki/Forest-fire_model
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 samp = texture2D(iChannel0,uv);
    
    fragColor = samp;
}