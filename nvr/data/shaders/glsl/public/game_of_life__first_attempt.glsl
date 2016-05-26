// Shader downloaded from https://www.shadertoy.com/view/Xd33WS
// written by shadertoy user klk
//
// Name: Game Of Life, first attempt
// Description: Convay's Game Of Life
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = vec4(texture2D(iChannel0,fragCoord / iResolution.xy).xxzx);
}