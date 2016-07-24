// Shader downloaded from https://www.shadertoy.com/view/XdBSzd
// written by shadertoy user iq
//
// Name: Tissue
// Description: Another experiment in stacking texture in a 2D plane deformation.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define HSAMPLES 128    // try 256
#define MSAMPLES   4    // try  12

#define DISABLE_MIPMAP  // slower, but if fixes errors in some systems

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2  p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;
    float t =  iGlobalTime + 10.0*iMouse.x/iResolution.x;
	#ifdef DISABLE_MIPMAP
    float lodbias = -100.0;
    #else
    float lodbias = 0.0;
    #endif
    float ran = texture2D( iChannel1, fragCoord.xy/iChannelResolution[1].xy ).x;
    float dof = dot( p, p );

    vec3 tot = vec3(0.0);
    for( int j=0; j<MSAMPLES; j++ )
    {
        float mnc = (float(j)+ran)/float(MSAMPLES);
        float tim = t + 0.5*(1.0/24.0)*(float(j)+ran)/float(MSAMPLES);
        vec2  off = vec2( 0.2*tim, 0.2*sin(tim*0.2) );
 	
	    vec2 q = p + dof*0.03*mnc*vec2(cos(15.7*mnc),sin(15.7*mnc));
        vec2 r = vec2( length(q), 0.5+0.5*atan(q.y,q.x)/3.1416 );

        vec3 uv;
        for( int i=0; i<HSAMPLES; i++ )
        {
            uv.z = (float(i)+ran)/float(HSAMPLES-1);
            uv.xy = off + vec2( 0.2/(r.x*(1.0-0.6*uv.z)), r.y );
            if( texture2D( iChannel0, uv.xy, lodbias ).x < uv.z )
                break;
        }
    
        vec2  uv2 = uv.xy + vec2(0.02,0.0);
        float dif = clamp( 8.0*(texture2D(iChannel0, uv.xy, lodbias).x - texture2D(iChannel0, uv2.xy, lodbias).x), 0.0, 1.0 );
        vec3  col = vec3(1.0);
        col *= 1.0-texture2D( iChannel0, 1.0*uv.xy, lodbias ).xyz;
        col = mix( col*1.2, 1.5*texture2D( iChannel0, vec2(uv.x*0.4,0.1*sin(2.0*uv.y*3.1316)), lodbias ).yzx, 1.0-0.7*col );
        col = mix( col, vec3(0.2,0.1,0.1), 0.5-0.5*smoothstep( 0.0, 0.3, 0.3-0.8*uv.z + texture2D( iChannel0, 2.0*uv.xy + uv.z, lodbias ).x ) );      
        col *= 1.0-1.3*uv.z;
        col *= 1.3-0.2*dif;        
        col *= exp(-0.35/(0.0001+r.x));
        
        tot += col;
    }
    tot /= float(MSAMPLES);
 
    tot.x += 0.05;
    tot = pow( tot, vec3(0.6,1.0,1.0) );
    
    fragColor = vec4( tot*smoothstep(0.0,2.0,iGlobalTime), 1.0 );
}