// Shader downloaded from https://www.shadertoy.com/view/XdG3WR
// written by shadertoy user FabriceNeyret2
//
// Name: patterned dithering
// Description: using one (time shifting) texture as pattern for dithering another texture (here video).
//    Try to change texture in channel1  ! 
void mainImage( out vec4 O,  vec2 U )
{
	O = step(texture2D(iChannel1,U/iChannelResolution[1].xy+fract(1e4*sin(iDate.w*vec2(17.94,1)))),
             texture2D(iChannel0,U/iResolution.xy));
}