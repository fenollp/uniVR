// Shader downloaded from https://www.shadertoy.com/view/MdVGzy
// written by shadertoy user DrLuke
//
// Name: Goorus
// Description: A slight variation from https://www.shadertoy.com/view/MsVGRy
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}