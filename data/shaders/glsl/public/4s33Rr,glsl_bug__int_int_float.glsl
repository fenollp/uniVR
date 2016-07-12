// Shader downloaded from https://www.shadertoy.com/view/4s33Rr
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug: int/int=float
// Description: it seems that on macOs  1 / 2 = 0.5 instead of 0, so that this shader should appears grey instead of black.
void mainImage( out vec4 fragColor, vec2 fragCoord )
{
    int a = 1, b = 2;
	   fragColor = vec4( a / b );
	// fragColor = vec4( 1 / 2 );
}