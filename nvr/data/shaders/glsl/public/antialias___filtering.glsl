// Shader downloaded from https://www.shadertoy.com/view/4ssSRl
// written by shadertoy user iq
//
// Name: Antialias / filtering
// Description: Used filter width (fwidth) to antialias edges (no supersampling). See the jagged edges in the left side of the screen vs the smooth edges in the right side. Both pre and post gamma filtering are implemented (move mouse to change the areas)
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// distance to a line (can't get simpler than this)
float line( in vec2 a, in vec2 b, in vec2 p )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.yy;
	vec2 q = p;
	
	vec2 c = vec2(0.0);
	if( iMouse.z>0.0 ) c=(-iResolution.xy + 2.0*iMouse.xy) / iResolution.yy;
	
    // background	
	vec3 col = vec3(0.5,0.85,0.9)*(1.0-0.2*length(p));
	if( q.x>c.x && q.y>c.y ) col = pow(col,vec3(2.2));

    // zoom in and out	
	p *= 1.0 + 0.2*sin(iGlobalTime*0.4);
	
	
	// compute distance to a set of lines
    float d = 1e20;	
	for( int i=0; i<7; i++ )
	{
        float anA = 6.2831*float(i+0)/7.0 + 0.15*iGlobalTime;
        float anB = 6.2831*float(i+3)/7.0 + 0.20*iGlobalTime;
		vec2 pA = 0.95*vec2( cos(anA), sin(anA) );		
        vec2 pB = 0.95*vec2( cos(anB), sin(anB) );		
		float h = line( pA, pB, p );
		d = min( d, h );
	}

    // lines/start, left side of screen	: not filtered
	if( q.x<c.x )
	{
		if( d<0.12 ) col = vec3(0.0,0.0,0.0); // black 
		if( d<0.04 ) col = vec3(1.0,0.6,0.0); // orange
	}
    // lines/start, right side of the screen: filtered
	else
	{
		float w = 0.5*fwidth(d); 
		w *= 1.5; // extra blur
		
		if( q.y<c.y )
		{
		col = mix( vec3(0.0,0.0,0.0), col, smoothstep(-w,w,d-0.12) ); // black
		col = mix( vec3(1.0,0.6,0.0), col, smoothstep(-w,w,d-0.04) ); // orange
		}
		else
		{
		col = mix( pow(vec3(0.0,0.0,0.0),vec3(2.2)), col, smoothstep(-w,w,d-0.12) ); // black
		col = mix( pow(vec3(1.0,0.6,0.0),vec3(2.2)), col, smoothstep(-w,w,d-0.04) ); // orange
		}
	}
	

	if( q.x>c.x && q.y>c.y )
		col = pow( col, vec3(1.0/2.2) );
	
    // draw left/right separating line
	col = mix( vec3(0.0), col, smoothstep(0.007,0.008,abs(q.x-c.x)) );
	col = mix( col, vec3(0.0), (1.0-smoothstep(0.007,0.008,abs(q.y-c.y)))*step(0.0,q.x-c.x) );
	
	
	fragColor = vec4( col, 1.0 );
}