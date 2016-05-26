// Shader downloaded from https://www.shadertoy.com/view/lss3zs
// written by shadertoy user iq
//
// Name: IFS - brute force
// Description: Brute force approach to computing an approximate distance field to the classic IFS fern of Barnsley. This is how you want to NOT do things for rendering IFS fractals.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


float hash( in float n ) { return fract(sin(n)*43758.5453123); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
	
    uv = uv*12.0 - vec2(5.5,0.8);
		
    vec2 z = vec2( 0.0 );
	
	float dodither = smoothstep( 0.0, 1.0, cos(2.0+0.25*6.2831*iGlobalTime) );
	
    float p = mix( 0.5, hash( dot(fragCoord.xy,vec2(113.0,317.0))+iGlobalTime ), dodither );

	float d = 1000.0;
    for( int i=0; i<160; i++ ) 
    {
        p = fract( p/0.123454);  // generate a random number

             if( p < 0.01 ) z = vec2(  0.0, 0.16*z.y );
		else if( p < 0.84 ) z = vec2(  0.85*z.x + 0.04*z.y, -0.04*z.x + 0.85*z.y + 1.60 );
        else if( p < 0.92 ) z = vec2(  0.20*z.x - 0.26*z.y,  0.23*z.x + 0.22*z.y + 1.60 );
        else                z = vec2( -0.15*z.x + 0.28*z.y,  0.26*z.x + 0.24*z.y + 0.44 );

		d = min( d, dot(uv-z,uv-z) );
    }
	
	d = sqrt(d);
	
	float col = mix( 1.0*pow(d,0.3), 0.7 + 0.3*smoothstep(-1.0,-0.8,sin(15.0*d) ),  smoothstep(0.0,3.0,d) );

    fragColor = vec4( col, col, col, 1.0 );
}