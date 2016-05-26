// Shader downloaded from https://www.shadertoy.com/view/Xlf3zl
// written by shadertoy user iq
//
// Name: Parametric graph by curvature
// Description: An attempt to find a way to compute the distance to a parametric curve map(t) that is better than linear search, based on curvature. An intuition really, need to think about this deeply. Inspired by eiffie's shaders.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// An attempt to find a way to compute the distance to a parametric curve p(t) that is
// better than linear search. In this case, I'm trying to measure curvature to concentrate
// the samples in highly curved areas.
//
// The shader switches between the linear search and the optimized version, showing how for the
// same amount of steps / complexity, the new method produces better results.
//
// I need to work on this more, I am not sure yet the right way to do this really, all I got was
// an intuition inspired by eiffie's shader https://www.shadertoy.com/view/4tfGRl.\


vec2 map(float t)
{
    return 0.85*cos( t + vec2(0.0,1.0) )*(0.6+0.4*cos(t*7.0+vec2(0.0,1.0)));
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p - a, ba = b - a;
	return length( pa - ba*clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 ) );
}

float graph( vec2 p, bool doOptimized )
{
    float h = doOptimized ? 0.05 : 6.2831/70.0;
	float t = 0.0;
    
    vec2  a = map(t);
    float d = length( p - a );
    
    t += h;
    for( int i=0; i<70; i++ )
    {
        vec2  b = map(t);
        d = min( d, sdSegment( p, a, b ) );
        
		t += (doOptimized) ? clamp( 0.026*length(a-p)/length(a-b), 0.02, 0.1 ) : h;
        a = b;
	}
    
	return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;
    
    bool doOptimized = sin(2.0*iGlobalTime) > 0.0;

    float d = graph( p, doOptimized );
        
    vec3 col = vec3(0.9);
    col *= 1.0 - 0.03*smoothstep(-0.3,0.3,sin( 120.0*d ));
    col *= smoothstep(0.0, 0.01, d );
    col *= 1.0 - 0.1*dot(p,p);

	fragColor = vec4( col, 1.0 );
}