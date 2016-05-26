// Shader downloaded from https://www.shadertoy.com/view/4dsSR2
// written by shadertoy user FabriceNeyret2
//
// Name: gauss / poisson process
// Description: Poisson process = uniform points distribution (e.g, stars) with average M per pixel.
//    pixel-average law = Poisson(M) ~ gauss(M-.5,sqrt(M))
//    density = 2^(10*Mouse.y) , mouse in -1..1
//    Left: pixel-based Poisson.   Right: recursive Poisson.  
float M = 10.;

float rnd(vec2 uv, float n) {
#if 1
	uv -= .5*n;
	return mod(sin(34556.456*uv.x-457523.345*uv.y)*345674.54,1.);
#else
	uv *= 4.*iResolution.y/256.;
	return (n==0.) ? texture2D(iChannel0,uv).r : texture2D(iChannel0,uv).g;
#endif
}

float gauss(float m, float s, vec2 uv) {
	float x = rnd(uv,0.), y=rnd(uv,1.);
	return m + s* sqrt(-2.*log(x+1e-6))*cos(2.*3.14159*y); // http://en.wikipedia.org/wiki/Normal_distribution#Generating_values_from_normal_distribution
}

float poisson(float m, vec2 uv) { // good approx for m >= 10 
	return gauss(m-.5,sqrt(m),uv);  // http://en.wikipedia.org/wiki/Poisson_distribution#Related_distributions
}

#define SCALES 8.
float poisson_rec(float m, vec2 uv) {
	float s = pow(4.,SCALES);
	m *= s;
	for (float i=0.; i<SCALES; i++) {
		m = poisson(m/4.,(uv+i)/s);  // +i)/s for decorrelation
		s /= 4.;
	}
	
	return m;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float c;
	vec2 uv = fragCoord.xy / iResolution.y;
	vec2 mouse = iMouse.xy/iResolution.xy;
	if (iMouse.x+iMouse.y>0.)
		M = pow(2., 20.* (mouse.y-.5));
	
	if (abs(uv.x-.5*iResolution.x/iResolution.y)<2e-3) {
		fragColor = vec4(1.,0.,0.,0.);
		return;
	}
	
	//uv *= 2.*mouse.x;
	if (uv.x<0.)
		c = poisson(M,uv)/(2.*M);
	else
		c = poisson_rec(M,uv)/(2.*M);
	
	fragColor = vec4(c);
}