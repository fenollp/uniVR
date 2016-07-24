// Shader downloaded from https://www.shadertoy.com/view/ldlGR7
// written by shadertoy user iq
//
// Name: IK Solver
// Description: An analytical solver for 2-bone joins. This is a 2D version, the 3d version can be found in the . Move the mouse around to see the behavior. The background goes grey when there's no solution
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// An analytical IK solver for 2 segments. A 3D version of this is used in the Insect shader
// https://www.shadertoy.com/view/Mss3zM
//
// Move the mouse to see the behavior of the solver.
//
// Given two points (white and yellow) at which the bones start and end, the red point (join)
// is computed automatically by the solver.


vec2 solve( vec2 p, float l1, float l2 )
{
	vec2 q = p*( 0.5 + 0.5*(l1*l1-l2*l2)/dot(p,p) );

	float s = l1*l1/dot(q,q) - 1.0;

	if( s<0.0 ) return vec2(-100.0);
	
    return q + q.yx*vec2(-1.0,1.0)*sqrt( s );
}

float sdSegment( vec2 a, vec2 b, vec2 p )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0 + 2.0*fragCoord.xy / iResolution.xy;
	vec2 mo = -1.0 + 2.0*iMouse.xy/iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	mo.x *= iResolution.x/iResolution.y;
	
	if( iMouse.w<=0.0001 ) { mo = vec2(1.0+0.2*sin(iGlobalTime),0.2+0.3*sin(iGlobalTime*3.3)); }
	
	float l1 = 0.9;
	float l2 = 0.4;
	vec2 a = vec2(0.0,0.0);
	vec2 c = mo;
	vec2 b = solve( c, l1, l2 );

	vec3 col = vec3(0.0);
	if( b.x<-99.0 )
	{
	col = vec3(0.1);
	}

	col = mix( col, vec3(0.2,0.2,0.2), 1.0-smoothstep( 0.0, 0.01, abs(length( a - uv )-l1) ) );
	col = mix( col, vec3(0.2,0.2,0.2), 1.0-smoothstep( 0.0, 0.01, abs(length( c - uv )-l2) ) );

	if( b.x>-99.0 )
	{
	float f = min( sdSegment( a, b, uv ), sdSegment( b, c, uv ) );
	col = mix( col, vec3(1.0,1.0,1.0), 1.0-smoothstep( 0.00, 0.01, f ) );
	col = mix( col, vec3(1.0,0.0,0.0), 1.0-smoothstep( 0.02, 0.03, length( b - uv ) ) );
	}

	col = mix( col, vec3(1.0,1.0,1.0), 1.0-smoothstep( 0.02, 0.03, length( a - uv ) ) );
	col = mix( col, vec3(1.0,1.0,0.0), 1.0-smoothstep( 0.02, 0.03, length( c - uv ) ) );
	
	
	fragColor = vec4( col, 1.0 );
}