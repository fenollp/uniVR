// Shader downloaded from https://www.shadertoy.com/view/Xds3zM
// written by shadertoy user iq
//
// Name: Stack
// Description: Implementing a stack in a shader, in order to render a recursive fractal with a distance field. Since all the traversing is static it can be resolved at compile/loop unrolling time by the GLSLES interpreter. ANGLE under Win seems to handle it correctly!
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// #define CAN_INDEX_ARRAYS

float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

vec2 udSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec2( length( pa - ba*h ), h );
}

struct Segment
{
	vec2 p;
	float a;
	float l;
	float wa;
	float wb;
	int level;
};

Segment stack[16];


Segment pop( int id )
{
#ifdef CAN_INDEX_ARRAYS    
    return stack[id]; 
#else    
    if( id== 0 ) return stack[ 0];
    if( id== 1 ) return stack[ 1];
    if( id== 2 ) return stack[ 2];
    if( id== 3 ) return stack[ 3];
    if( id== 4 ) return stack[ 4];
    if( id== 5 ) return stack[ 5];
    if( id== 6 ) return stack[ 6];
    if( id== 7 ) return stack[ 7];
    if( id== 8 ) return stack[ 8];
    if( id== 9 ) return stack[ 9];
    if( id==10 ) return stack[10];
    if( id==11 ) return stack[11];
    if( id==12 ) return stack[12];
    if( id==13 ) return stack[13];
    if( id==14 ) return stack[14];
    return stack[15];
#endif
}

void push( int id, Segment s )
{
#ifdef CAN_INDEX_ARRAYS    
    stack[id] = s;
#else    
         if( id== 0 ) stack[ 0] = s;
    else if( id== 1 ) stack[ 1] = s;
    else if( id== 2 ) stack[ 2] = s;
    else if( id== 3 ) stack[ 3] = s;
    else if( id== 4 ) stack[ 4] = s;
    else if( id== 5 ) stack[ 5] = s;
    else if( id== 6 ) stack[ 6] = s;
    else if( id== 7 ) stack[ 7] = s;
    else if( id== 8 ) stack[ 8] = s;
    else if( id== 9 ) stack[ 9] = s;
    else if( id==10 ) stack[10] = s;
    else if( id==11 ) stack[11] = s;
    else if( id==12 ) stack[12] = s;
    else if( id==13 ) stack[13] = s;
    else if( id==14 ) stack[14] = s;
    else              stack[15] = s;
#endif        
}
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
	vec2 m = vec2(0.0);
	if( iMouse.z>0.0 ) m=-1.0 + 2.0*iMouse.xy/ iResolution.xy;
		

	stack[0] = Segment( vec2(0.0,-0.85), 0.0, 0.6, 0.13, 0.08, 0 );
	int s = 0;
	
	float id = 0.0;
	float f = 100.0;
	float g = 100.0;
	for( int i=0; i<63; i++ )
	{
		/// pop from the stack
		Segment x = pop(s); s--;
		
		// render line
		vec2 a = x.p;
		vec2 b = x.p + x.l*vec2(sin(x.a),cos(x.a));
		vec2 h = udSegment( p, a, b );
		float d = h.x - mix(x.wa,x.wb,h.y);
		f = min( f,     d);
		g = min( g, abs(d) );

        // push new stuff into the stack		
		id += 1.0;
		if( x.level<5 )
		{
			float an = m.x + 0.5*sin(8.0*x.l+iGlobalTime)*x.l;
			float a1 = 0.2 + 0.8*hash(3313.115*id) + an;
			float a2 = 0.2 + 0.8*hash(1241.506*id) - an;
			float l1 = 0.5 + 0.3*hash(5241.343*id);
			float l2 = 0.5 + 0.3*hash(9741.241*id);
			push( ++s, Segment( b, x.a+a1, x.l*l1, x.wb, x.wb*0.65, x.level+1 ) );
			push( ++s, Segment( b, x.a-a2, x.l*l2, x.wb, x.wb*0.65, x.level+1 ) );
		}
	}

    // final color
	vec3 col = 0.2 + 0.6*vec3( sqrt(abs(f)) );
	col = mix( vec3(1.0,0.7,0.3), col, smoothstep( 0.0, 0.005, f ) );	
  	col *= smoothstep( 0.0, 0.01, g );
  	
	fragColor = vec4(col,1.0);
}