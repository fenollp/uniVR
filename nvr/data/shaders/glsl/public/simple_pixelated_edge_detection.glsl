// Shader downloaded from https://www.shadertoy.com/view/MsVXRm
// written by shadertoy user Ippokratis
//
// Name: Simple pixelated edge detection
// Description: simple pixelated edge detection 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 c = vec4 ( fwidth( texture2D( iChannel0, fragCoord.xy / iResolution.xy ).x *64.0) );
    c= floor(c);
    fragColor = 1.0-c;
}