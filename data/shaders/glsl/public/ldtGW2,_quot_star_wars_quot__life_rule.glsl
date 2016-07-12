// Shader downloaded from https://www.shadertoy.com/view/ldtGW2
// written by shadertoy user Flyguy
//
// Name: &quot;Star Wars&quot; Life Rule
// Description: A cellular automata thing showing the &quot;Star Wars&quot; rule. The shader can be easily configured for any 3x3 kernel, Survive/Birth/History type cellular automata rule.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0,uv);
}