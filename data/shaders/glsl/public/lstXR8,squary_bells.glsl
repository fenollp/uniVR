// Shader downloaded from https://www.shadertoy.com/view/lstXR8
// written by shadertoy user eiffie
//
// Name: Squary Bells
// Description: Playing around with visualizing harmonics. (inside square shaped bells??) ...needs more cowbell
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0,uv);
}