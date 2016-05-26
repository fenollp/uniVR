// Shader downloaded from https://www.shadertoy.com/view/MdG3Wd
// written by shadertoy user piotrekli
//
// Name: Music visualisation test
// Description: a very simple music visualisation
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).xyz;
	fragColor = vec4(color, 1.0);
}