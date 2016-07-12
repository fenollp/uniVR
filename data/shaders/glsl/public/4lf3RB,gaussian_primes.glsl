// Shader downloaded from https://www.shadertoy.com/view/4lf3RB
// written by shadertoy user elias
//
// Name: Gaussian Primes
// Description: .
#define t iGlobalTime*0.5
#define R (100.+cos(t+1.)*50.)

float isPrime(float n)
{
	float d = floor(sqrt(n))+1.0;

	for(int i = 0; i < 1000; i++)
    {
		if (d < 2.0) { break; }
        if (mod(n,d--) == 0.0) { return 0.0; }
	}
 
	return 1.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 z = floor(R*(2.*fragCoord.xy-iResolution.xy)/iResolution.xx+0.5);
	fragColor = vec4(floor(isPrime(dot(z,z))))*cos(length(z)*0.01);
}