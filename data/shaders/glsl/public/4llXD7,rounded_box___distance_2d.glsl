// Shader downloaded from https://www.shadertoy.com/view/4llXD7
// written by shadertoy user iq
//
// Name: Rounded Box - distance 2D
// Description: SIGNED distance to a rounded box
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// signed distance to a 2D rounded box

float sdRoundBox( in vec2 p, in vec2 b, in float r ) 
{
    vec2 q = abs(p) - b;
    vec2 m = vec2( min(q.x,q.y), max(q.x,q.y) );
    float d = (m.x > 0.0) ? length(q) : m.y; 
    return d - r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;

	vec2 ra = 0.4 + 0.3*cos( iGlobalTime + vec2(0.0,1.57) + 0.0 );

	float d = sdRoundBox( p, ra, 0.2 );

    vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
	col *= 1.0 - exp(-2.0*abs(d));
	col *= 0.8 + 0.2*cos(120.0*d);
	col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.02,abs(d)) );

	fragColor = vec4(col,1.0);
}