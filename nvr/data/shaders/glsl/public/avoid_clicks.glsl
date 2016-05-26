// Shader downloaded from https://www.shadertoy.com/view/4sSXRh
// written by shadertoy user iq
//
// Name: Avoid Clicks
// Description: One simple way to avoid clicks in sound - make sure you fit an integer amount of wave cycles per note. Uncomment line 14 to hear the clicks
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0);
	fragColor = vec4(col,1.0);
}