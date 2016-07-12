// Shader downloaded from https://www.shadertoy.com/view/Xs3GW2
// written by shadertoy user XT95
//
// Name: Light painting
// Description: Shutdown the lights. Take your lighter and draw some art with you webcam !
//    Click on the screen to reset the buffer.
//    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D( iChannel0, uv);
}