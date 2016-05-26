// Shader downloaded from https://www.shadertoy.com/view/XdcSRM
// written by shadertoy user WojtaZam
//
// Name: Imperial Japanese Navy Flag
// Description: Learning how to paint with math.
const vec4 red = vec4( 198, 12 ,48, 255 ) / 255.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy;
    vec2 p = ( 2.0 * fragCoord - res )/res.y;
    
	vec4 color = vec4( 1.0 );
	float xOffset = 0.5;
    //rays
    float r = cos( atan( p.y, p.x + xOffset ) * 16.0 );
    float f = smoothstep( r, r + 0.1, length( p )*0.05 );
	color = mix( red, color, f );
    //circle
    r = 0.6;
    f = smoothstep( r, r + 0.01, length( p + vec2( xOffset, 0.0 ) ) );
    color = mix( red, color, f );
    
    fragColor = color;
}