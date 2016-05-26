// Shader downloaded from https://www.shadertoy.com/view/XtXGWX
// written by shadertoy user mpcomplete
//
// Name: Burning Mandelbrot
// Description: Testing fractals with orbit traps.
#define USE_NOISE 1

#if USE_NOISE
const float kTrapScale = 1.;
#else
const float kTrapScale = 2.;
#endif

float time = iGlobalTime * 0.3;

vec3 noise3(in vec2 uv)
{
    vec3 f = texture2D(iChannel0, uv/256.0).xyz;
	f = f*f*(3.0-2.0*f);
    return f;
}

// https://code.google.com/p/fractalt}erraingeneration/wiki/Fractional_Brownian_Motion
vec3 fbm(in vec2 p)
{
    const float gain = 0.5;
    const float lacunarity = 2.;

    vec3 total;
	float amplitude = gain;

	for (int i = 0; i < 7; i++) {
		total += noise3(p) * amplitude;
		amplitude *= gain;
		p *= lacunarity;
	}
	return total;
}

vec2 cxMult(in vec2 c1, in vec2 c2) {
	return vec2(c1.x*c2.x - c1.y*c2.y, c1.x*c2.y + c1.y*c2.x);
}

float cxModuloSquared(in vec2 c) {
    return dot(c, c);
}

float distanceSquared(in vec2 x, in vec2 y) {
    return dot(x-y, x-y);
}

float calcDistance(in vec2 c, out float trapDist)
{
    vec2 z, dz;
    float m2;

    vec2 trap = vec2(.5, 2.)*(sin(1.5*time));
	#if USE_NOISE
    trap += 2.5*(2.*fbm(c*1000. + 3.*(1. + sin(.6*time))).xy - 1.);
	#endif
    trapDist = 1e20;
    for( int i=0; i<150; i++ ) {
		// Z' -> 2*Z*Z' + 1
        dz = 2.0*cxMult(z, dz) + vec2(1.0,0.0);

        // Z -> Z^2 + c
        z = c + cxMult(z, z);

        m2 = cxModuloSquared(z);
        trapDist = min(trapDist, distanceSquared(z, trap));
        if( m2>1024. )
            break;
    }

    trapDist = sqrt(trapDist)*2.;

    // distance estimation: G/|G'|
    return sqrt(m2/cxModuloSquared(dz)) * log(m2);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

    float zoom = 1./(250. + 100.*(1. + sin(time)));
    if (iMouse.w > .001) zoom = 1./(exp(10.*iMouse.x/iResolution.x)*100.);
	p = vec2(-0.53453,0.5263) + p*zoom;

    float trapDist;
    float d = calcDistance(p, trapDist)*1000.;

    float c1 = d*5.;
	float c2 = pow( clamp( .3*trapDist, 0.0, 1.0 ), 2.0 );
	float c3 = pow( clamp( 1.7*trapDist, 0.0, 1.0 ), 2.0 );
//    float c3 = trapDist*5.;

	vec3 col1 = 0.5 + 0.5*sin( 3.0 + 4.0*c2 + vec3(0.0,0.5,1.0) );
	vec3 col2 = 0.5 + 0.5*sin( 4.1 + 2.0*c3 + vec3(1.0,0.5,0.0) );
	vec3 col = 2.0*sqrt(c1*col1*col2);

	fragColor = vec4( col, 1.0 );

}