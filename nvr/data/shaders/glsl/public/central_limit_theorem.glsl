// Shader downloaded from https://www.shadertoy.com/view/4tf3Wl
// written by shadertoy user FabriceNeyret2
//
// Name: Central Limit Theorem
// Description: left to right: std-dev of the average of N random values,
//    N going from 0 to 400 from left to right.
//    -&gt; remaining fluctuations of the estimator = 1/sqrt(N) of initial fluctuations.
#define N 100
#define PI 3.1415927
float noise(vec2 p) {
    float v = 1234.5*p.x-34.17*p.y+123.4;
    return -1.+2.*fract(1000.*sin(v));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float s=0.;
    float n = (uv.y<.8) ? uv.x*400. : 1.;
    for(int i=0; i<N; i++)
        if (float(i)<=n) s += noise(uv+float(i));
	fragColor = vec4(.5+1.*s/n);
}