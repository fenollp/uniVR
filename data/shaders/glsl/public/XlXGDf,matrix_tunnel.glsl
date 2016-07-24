// Shader downloaded from https://www.shadertoy.com/view/XlXGDf
// written by shadertoy user hunter
//
// Name: Matrix Tunnel
// Description: orginal by: Iain Melvin ( https://www.shadertoy.com/view/4dfSRS )
// 
// orginal by: Iain Melvin ( https://www.shadertoy.com/view/4dfSRS )
//

#define PI 3.14159

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.st / iResolution.xy;
	uv = abs( 2.0 * ( uv - 0.5 ) );

	float theta = 1.0 * ( 1.0 / ( PI / 2.0 ) ) * atan( uv.x, uv.y );
	float r = length( uv );
	float a = 0.01 - r;
	uv = vec2( theta, r );

	vec4 t1 = texture2D( iChannel0, vec2( uv[0], 0.9 ) );
	vec4 t2 = texture2D( iChannel0, vec2( uv[1], 0.9 ) );
	float y = t1[0] * t2[0] * a * 15.5;
	fragColor = vec4( sin( y * PI ), sin(y * PI ), sin( y * PI ), 1.0 );
}