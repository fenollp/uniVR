// Shader downloaded from https://www.shadertoy.com/view/ldB3zc
// written by shadertoy user iq
//
// Name: Voronoi - smooth
// Description: Smooth Voronoi - avoiding aliasing, by replacing the usual min() function, which is discontinuous, with a smooth version. That can help preventing some aliasing, and also provides with more artistic control of the final procedural textures/models.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Smooth Voronoi - avoiding aliasing, by replacing the usual min() function, which is
// discontinuous, with a smooth version. That can help preventing some aliasing, and also
// provides with more artistic control of the final procedural textures/models.

// The parameter w controls the smoothness

float hash1( float n ) { return fract(sin(n)*43758.5453); }
vec2  hash2( vec2  p ) { p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) ); return fract(sin(p)*43758.5453); }

vec4 voronoi( in vec2 x, float w )
{
    vec2 n = floor( x );
    vec2 f = fract( x );

	vec4 m = vec4( 8.0, 0.0, 0.0, 0.0 );
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
        vec2 o = hash2( n + g );
		
		// animate
        o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o );

        // distance to cell		
		float d = length(g - f + o);
		
        // do the smoth min for colors and distances		
		vec3 col = 0.5 + 0.5*sin( hash1(dot(n+g,vec2(7.0,113.0)))*2.5 + 3.5 + vec3(2.0,3.0,0.0));
		float h = smoothstep( 0.0, 1.0, 0.5 + 0.5*(m.x-d)/w );
		
	    m.x   = mix( m.x,     d, h ) - h*(1.0-h)*w/(1.0+3.0*w); // distance
		m.yzw = mix( m.yzw, col, h ) - h*(1.0-h)*w/(1.0+3.0*w); // color
    }
	
	return m;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy/iResolution.yy;
	
	float k = 2.0 + 70.0 * pow( 0.5 + 0.5*sin(0.25*6.2831*iGlobalTime), 4.0 );
	k = 0.5 - 0.5*cos(0.25*6.2831*iGlobalTime);
    vec4 c = voronoi( 6.0*p, k );

    vec3 col = c.yzw;
	
	col *= 1.0 - 0.8*c.x*step(p.y,0.33);
	col *= mix(c.x,1.0,step(p.y,0.66));
	
	col *= smoothstep( 0.005, 0.007, abs(p.y-0.33) );
	col *= smoothstep( 0.005, 0.007, abs(p.y-0.66) );
	
    fragColor = vec4( col, 1.0 );
}