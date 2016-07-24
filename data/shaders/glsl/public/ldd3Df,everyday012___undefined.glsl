// Shader downloaded from https://www.shadertoy.com/view/ldd3Df
// written by shadertoy user Makio64
//
// Name: Everyday012 - Undefined
// Description: Everyday012 - Undefined
// Everyday012 - Undefined
// By David Ronai / @Makio64

float hash(vec2 p){return fract(21654.65155 * sin(35.51 * p.x + 45.51 * p.y));}
float smoothVoronoi( in vec2 x ){
    vec2 p = floor( x );
    vec2  f = fract( x );
    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ){
        vec2 b = vec2( i, j );
        vec2  r = vec2( b ) - f + hash( p + b );
        float d = dot( r, r );
        res += 1.0/pow( d, 16.0 );
    }
    return pow( 1.0/res, 1.0/16.0 );
}

float random(vec2 n, float offset ){
	return .5 - fract(sin(dot(n.xy + vec2( offset, 0. ), vec2(12.9898, 78.233)))* 43758.5453);
}

vec2 circularOut(vec2 t) { return sqrt((2.0 - t) * t);}

//------------------------------------------------------------------ MAIN
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = abs(uv-.5)+.5;
	uv = circularOut(uv)*3.;
    uv = cos(uv-iGlobalTime/10.);
    float v = smoothVoronoi(uv*6.);
    vec3 col = vec3(v);
    col *= vec3(1.,2.,4.);
	col += vec3( .2 * random( uv, .00001 * 1. * iGlobalTime ) );
    float dist = distance(fragCoord.xy / iResolution.xy, vec2(0.5, 0.5));
	col *= smoothstep(0.8, .4 * 0.799, dist * (.8 + .4));
    fragColor = vec4(col,1.0);
}