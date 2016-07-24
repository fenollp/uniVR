// Shader downloaded from https://www.shadertoy.com/view/MssSDH
// written by shadertoy user FabriceNeyret2
//
// Name: parabolic mirror
// Description: reflection by a parabolic mirror
//    
//    (tune light position with mouse)
#define NB_RAY 80.
#define x0 .85


#define PI 3.1415927
float t = .3*iGlobalTime;

// pow allowing -int
float mypow(float x, int n) {	
	return pow(abs(x),float(n)) * ( (2*(n/2)==n) ? 1. : sign(x) ); 
} 


// antialiased cos
float icos(float a) {
	float da = length(vec2(dFdx(a),dFdy(a)));
	return (sin(a+da)-sin(a-da))/(2.*da);				  
}

// antialiased cos^n
float icospow(float a, int n) { // for odd n only
	// cos^(2n+1) = cos.(1-sin²)^n = cos.sum{ Ci,n. (-sin²)^i }
	// -> int = sum{ Ci,n. (-1)^i.sin^(2i+1)/(2i+1) }
	float da = length(vec2(dFdx(a),dFdy(a)));

	float s = 0., C = 1.; n = (n-1)/2;	
	for (int i=0; i<=50; i++)	{
		if (i>n) return s/(2.*da);
		
		int p = 2*i+1;
		s += C*( mypow(sin(a+da),p) - mypow(sin(a-da),p) )/float(p);
		C *= -float(n-i)/max(float(i),1.);
	}
	return s/(2.*da);	
}

// antialiased exp
float iexp(float a) {
	float da = length(vec2(dFdx(a),dFdy(a)));
	return (exp(a+da)-exp(a-da))/(2.*da);	
}
// antialiased gauss
float igauss(float v, float s) {
	// exp(-n/2.(x)^2) ~ cos(x)^n
	// -> exp(-1/2.(x/s)^2) ~ cos(x)^(1/s^2) ~ cos(x/(s.sqrt(n)))^n
	int n = 11; // int(.5+1./(s*s)); n=2*(n/2)+1;
	v /= s*sqrt(float(n));
	if (abs(v)>1.5) return 0.;
	return icospow(v,n);
}
	
// -----------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.y;
	vec2 m = floor(iMouse.xy/2.)*2. / iResolution.y;
	if (iMouse.z<=0.) 
		m = (.5+.3*vec2(cos(t)+sin(5.234*t)/2.,sin(1.351*t)-cos(7.453*t)/2.)/1.5)*vec2(1.8,1.);

	float ray=0., reflected=0.;
	
	for (float i=0.; i<NB_RAY; i++) {
		
		// ray dir
		float c=cos(2.*PI*i/NB_RAY), s=sin(2.*PI*i/NB_RAY);

		// rays from mouse to mirror
		vec2  n = vec2(s,-c); 		// ortho to ray. ray: n.(p-p0) = 0
		float v = dot(p-m,n), d;  
		if (i<NB_RAY/2.) ray += exp(-2e5*v*v);
		
		// intersection on parabolic miror at p0
		float x = m.x-x0, 
			  A = c*c, B = 2.*c*x-s, C = x*x-m.y;
		if (A<1e-4) 
			d = -C/B;
		else {
			float D = B*B-4.*A*C; 
			if (D<0.) continue;
			d = (-B+sqrt(D))/(2.*A);
		}
		vec2 p0 = m+d*vec2(c,s); // point on mirror for ray i
		
		// normal at p0
		x = p0.x-x0;  vec2 N = normalize(vec2(1.,2.*x));
		// reflected ray = sym(ray) relative to N

		n = 2.*dot(N,n)*N-n;   		// sym 
		v = dot(p-p0,n);      // reflected ray: n.(p-p0) = 0
		reflected += exp(-1e5*v*v);
	}
	
	// draw rays clamped by the mirror
	float x = p.x-x0, v = p.y-x*x;
	fragColor = (v>0.) ? vec4(reflected,ray*(1.-reflected),0.,1.) : vec4(0.);

	// draw mirror
	fragColor += vec4(smoothstep(.0001,0.,v*v));
}