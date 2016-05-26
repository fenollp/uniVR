// Shader downloaded from https://www.shadertoy.com/view/Xll3zX
// written by shadertoy user iq
//
// Name: Voronoi - hierarchical
// Description: Hierarchical Voronoi. An attempt really.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// An attempt to hierarchical Voronoi. Failed so far.

#define LEVEL 3
#define BORDERS 

vec3 rand3( vec2 p ) { return texture2D( iChannel0, (p*8.0+0.5)/256.0, -100.0 ).xyw; }

vec3 voronoi( in vec2 x )
{
    vec2 n = floor(x);
    vec2 f = fract(x);

	float id, le;

    float md = 10.0;
    
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g1 = n + vec2(float(i),float(j));
        vec3 rr = rand3( g1 );
		vec2 o = g1 + rr.xy;
        vec2 r = x - o;
        float d = dot(r,r);
        float z = rr.z;
        
        #if LEVEL>0
        if( z<0.75 )
        #endif            
        {
            if( d<md )
            {
                md = d;
                id = z + g1.x + g1.y*7.0;
                le = 0.0;
            }
        }
        #if LEVEL>0
        else
        {
            for( int l=0; l<2; l++ )
            for( int k=0; k<2; k++ )
            {
                vec2 g2 = g1 + vec2(float(k),float(l))/2.0;
                rr = rand3( g2 );
                o = g2 + rr.xy/2.0;
                r = x - o;
                d = dot(r,r);
                z = rr.z;
                #if LEVEL>1
                if( z<0.8 )
                #endif                    
                {
                    if( d<md )
                    {
                        md = d;
                        id = z + g2.x + g2.y*7.0;
                        le = 1.0;
                    }
                }
                #if LEVEL>1
                else
                {
                    for( int n=0; n<2; n++ )
                    for( int m=0; m<2; m++ )
                    {
                        vec2 g3 = g2 + vec2(float(m),float(n))/4.0;
                        rr = rand3( g3 );
                        o = g3 + rr.xy/4.0;
                        r = x - o;
                        d = dot(r,r);
                        z = rr.z;

                        #if LEVEL>2
                        if( z<0.8 )
                        #endif                    
                        {
                            if( d<md )
                            {
                                md = d;
                                id = z + g3.x + g3.y*7.0;
                                le = 2.0;
                            }
                        }
                        #if LEVEL>2
                        else
                        {
                            for( int t=0; t<2; t++ )
                            for( int s=0; s<2; s++ )
                            {
                                vec2 g4 = g3 + vec2(float(s),float(t))/8.0;
                                rr = rand3( g4 );
                                o = g4 + rr.xy/8.0;
                                r = x - o;
                                d = dot(r,r);
                                z = rr.z;

                                if( d<md )
                                {
                                    md = d;
                                    id = z + g4.x + g4.y*7.0;
                                    le = 3.0;
                                }
                            }
                        }
                        #endif
                    }
                }
                #endif
            }
        }
        #endif        
    }

    return vec3( md, le, id );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy/iResolution.x;
    p += 0.5*cos( 0.1*iGlobalTime + vec2(0.0,1.57) );
    
    const float scale = 8.0;
    
    vec3 c = voronoi( scale*p );

    vec3 col = 0.6 + 0.4*cos( c.y*0.6 + vec3(0.0,0.9,1.5) );
    col *= 0.96 + 0.04*sin( 10.0*c.z );
    col *= smoothstep( 0.008, 0.015, sqrt(c.x) );
#ifdef BORDERS    
    vec2 e = vec2( 2.0, 0.0 )/iResolution.x;
    vec3 ca = voronoi( scale*(p + e.xy) );
    vec3 cb = voronoi( scale*(p + e.yx) );
    col *= 1.0 - clamp( abs(2.0*c.z-ca.z-cb.z)*1000.0,0.0,1.0);
#else
    col *= 1.0 - clamp(fwidth(c.z)*1000.0,0.0,1.0);
#endif
    
    
    fragColor = vec4( col, 1.0 );
}
