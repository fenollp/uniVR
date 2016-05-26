// Shader downloaded from https://www.shadertoy.com/view/XtjSzR
// written by shadertoy user akaitora
//
// Name: Worley Tunnely
// Description: A Worley Tunnel
// Endless Tunnel
// By: Brandon Fogerty
// bfogerty at gmail dot com

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;


vec2 hash( vec2 p )
{
	mat2 m = mat2( 	34789.23472, 28371.2387,
		      	58217.2387, 947823.213 );
	
    p = mod( p, 4. );
    
	return fract( sin( m * p ) * 48938.43982 );
}

float v( vec2 p )
{
    p.x = mod(p.x,4.0);
	vec2 g = floor( p );
	vec2 f = fract( p );
	
	vec2 res = vec2( 1.0 );
	for( int y = -1; y <= 1; y++ )
	{
		for( int x = -1; x <= 1; x++ )
		{
			vec2 off = vec2( x, y );
			float h = distance( off + hash( g + off), f );
			
			if( h < res.x )
			{
				res.y = res.x;
				res.x = h;
			}
            else if( h < res.y )
            {
                res.y = h;
            }
		}
	}
	
	return res.y - res.x;
}


vec3 tunnel( vec2 p, float scrollSpeed, float rotateSpeed )
{    
    float a = 2.0 * atan( p.x, p.y );

    a *= (3.0 / 3.141596);
    
    float r = length(p) * 0.9;
    vec2 uvp = vec2( 0.4/r + (iGlobalTime*scrollSpeed), a + (iGlobalTime*rotateSpeed));	
    vec3 finalColor = vec3( v( uvp * 1.0 ) );
    finalColor *= r * 5.0;
	
    return finalColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    float timeSpeedX = iGlobalTime * 0.3;
    float timeSpeedY = iGlobalTime * 0.2;
    vec2 p = uv + vec2( -0.50+cos(timeSpeedX)*0.2, -0.5-sin(timeSpeedY)*0.3 );

    vec3 finalColor = tunnel( p , 1.0, 0.0);

    fragColor = vec4( finalColor, 1.0 );
}