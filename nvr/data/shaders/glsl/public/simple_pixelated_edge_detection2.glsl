// Shader downloaded from https://www.shadertoy.com/view/ldKXzm
// written by shadertoy user Ippokratis
//
// Name: Simple pixelated edge detection2
// Description: simple pixelated edge detection 2
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 c = vec4 ( fwidth( texture2D( iChannel0, fragCoord.xy / floor(iResolution.xy) ).x*16.0 ) );
    c = pow (c, vec4(32.0));
    fragColor = 1.0-c*8000.0;
}