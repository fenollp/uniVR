// Shader downloaded from https://www.shadertoy.com/view/XsjSzc
// written by shadertoy user iq
//
// Name: Oscilomushroom
// Description: Made after this: . No actual implicit procedural modeling used!
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// This shader is doing the "right thing" --> generating two time signals and then lighting the electron
// beam as it gets moved by then. No actual implicit procedural modeling used!

float length2( in vec2 v ) { return dot(v,v); }

float ssdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2  pa = p - a;
	vec2  ba = b - a;
    float bam = dot(ba,ba);
    if( bam>0.1 ) return 10.0;
	float h = clamp( dot(pa,ba)/bam, 0.0, 1.0 );
	
	return length2( pa - ba*h );
}

const float freq = 100.0;

float saw( float x ) { return -1.0 + 2.0*fract(x); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
    p *= 1.25;
    
    float f = 1.5;
    float ox = 0.0;
    float oy = 0.0;
    for( int i=0; i<1024; i++ )
    {
        float h = float(i)/1024.0;
    
        float t = iGlobalTime + 10.0*h/freq;
    
        //----------------        
        float x = 0.6*cos( 5.0*freq*6.2831*t ) * 
                      sin( 1.0*freq*6.2831*t/12.0) *
                 (0.1+0.9*step(fract(t*freq/12.0),0.25)) - 
                  0.2*sin(t*6.2831*freq/12.0 + t*2.0) * 
                 (1.0-fract(t*freq/12.0));
        float y = 0.1*sin( 5.0*freq*6.2831*t ) - 
                  1.0*saw( 1.0*freq*t/12.0 );
        //----------------        
        
        
        if( i>0 ) 
        {
            float dis = ssdSegment( p, vec2(x,y), vec2(ox,oy) );
            f += exp( -5000.0*dis )*1.00 + 
                 exp( - 100.0*dis )*0.04;
        }
        ox = x;
        oy = y;
    }    
    
    float h = clamp( f*0.05, 0.0, 1.0 );
    vec3 col = vec3( h*h, h, h*h*h )*3.0;
   
    vec2 q = fragCoord.xy/iResolution.xy;
    col *= pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );

    float grid = 1.0;
    grid *= 1.0-smoothstep( 0.98, 0.99, 2.0*abs(fract( q.x*10.0 )-0.5) );
    grid *= 1.0-smoothstep( 0.96, 0.98, 2.0*abs(fract( q.y*6.0 )-0.5) );
    grid *= 1.0-smoothstep( 0.90, 0.92, 2.0*abs(fract( q.x*50.0 )-0.5) )*
                smoothstep( 0.84, 0.85, 2.0*abs(fract( q.y* 6.0 )-0.5) );
    grid *= 1.0-smoothstep( 0.91, 0.92, 2.0*abs(fract( q.y*30.0 )-0.5) )*
                smoothstep( 0.85, 0.86, 2.0*abs(fract( q.x*10.0 )-0.5) );
    col *= 0.5 + 0.5*grid;
  
    col += 0.06*smoothstep(0.2,0.7,q.y);
    
	fragColor = vec4( col, 1.0 );
}