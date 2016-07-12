// Shader downloaded from https://www.shadertoy.com/view/ldXGzr
// written by shadertoy user unai
//
// Name: Mouse Scroller
// Description: Demostrate the use of mouse input and global time.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// We will use the mouse as base position.
	vec2 uv = (fragCoord.xy+iMouse.xy) / iResolution.xy;

	// iGlobalTime will scroll the result.
	fragColor = texture2D( iChannel0, iGlobalTime + (uv*4.0) );
}