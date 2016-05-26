// Shader downloaded from https://www.shadertoy.com/view/4dG3R1
// written by shadertoy user iq
//
// Name: 2D Cloth
// Description: Verlet integrated cloth. Next step, 3D
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float hash1( vec2 p ) { float n = dot(p,vec2(127.1,311.7)); return fract(sin(n)*153.4353); }

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

vec4 getParticle( vec2 id )
{
    return texture2D( iChannel0, (id+0.5)/iResolution.xy );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.y;
    
    vec3 f = vec3(0.0);
    for( int j=0; j<10; j++ )
    for( int i=0; i<10; i++ )
    {
        vec2 id = vec2( float(i), float(j) );
        vec4 p = getParticle( id );

        float d = 1.0;
        
        #if 1
        if( i<9 )        d = min(d, sdSegment( uv, p.xy, getParticle( id+vec2(1.0,0.0) ).xy ));
        if( j<9 )        d = min(d, sdSegment( uv, p.xy, getParticle( id+vec2(0.0,1.0) ).xy ) );
        if( i<9 && j<9 ) d = min(d, sdSegment( uv, p.xy, getParticle( id+vec2(1.0,1.0) ).xy ));
        if( i>0 && j<9 ) d = min(d, sdSegment( uv, p.xy, getParticle( id+vec2(-1.0,1.0) ).xy ) );
        f = mix( f, vec3(0.4,0.6,0.8), 1.0-smoothstep( 0.0, 0.005, d ) );
        #endif
        
        d = length(uv-p.xy)-0.035;
        vec3 col = 0.6 + 0.4*sin( hash1(id)*30.0 + vec3(0.0,1.0,2.0) );
        col *= 0.8 + 0.2*smoothstep( -0.1, 0.1, sin(d*400.0) );
        f = mix( f, col, 1.0-smoothstep( -0.001, 0.001, d ) );
            
    }
    
    fragColor = vec4(f,1.0);
}