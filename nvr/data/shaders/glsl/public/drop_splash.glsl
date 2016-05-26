// Shader downloaded from https://www.shadertoy.com/view/ldlXDN
// written by shadertoy user FabriceNeyret2
//
// Name: drop splash
// Description: Real drop splashes are *not* sin(k(d-ct)) !
//    - wave speed depends on wavelenght (dispertion). slowest=.4 cm; faster for larger (gravity) and smaller (capillary)
//    - vertical displ = A.sin, horiz displ = A.cos -&gt; trochoids, not sinusoids (not drawn here).
#define Wmin 50.    // spectrum shape of exciter 
#define Wmax 200.
#define Wsamples 150.
#define AMP(w) (1./(w))

#define COL 0		// water reflects
#define CAM 1		// perspective camera
#define PULSE 1     // time shape of exciter  1: square 2: smooth
// SPACE to toggle spreaded source

float t = .3*iGlobalTime;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

// --- rand
float hash(float x) { return fract(sin(3234.*x)*6563.234); }

// --- solve degree 3 equation
float solveP3(float a, float c, float d) {
	c /= a; d /= a;
	float C = -d/2.*(1.+sqrt(1.+(c*c*c)/(d*d)*4./27.));  
	C = sign(C)*pow(abs(C),1./3.);
    return C-c/(3.*C);
}

// --- Pierson-Moskowitz oceanographic spectrum   V = wind at 20m height
float PM(float w,float V) { return 8.1E-3*9.81*9.81/pow(w,5.)*exp(-0.74*pow(9.81/(V*w),4.)); }

// --- drop exciter
float pulse(float t) {
#if   PULSE==1
	return (mod(t,1.)<.1) ? 1.: 0.;      // square signal
#elif PULSE==2
	return pow(.5+.5*cos(6.283*t),20.);  // smoothed signal
#endif
}

// === main loop

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.9,.5));
	vec2 m  =      2.*( iMouse.xy / iResolution.y - vec2(.9,.5));
	if (length(iMouse.zw)==0.) m = vec2(1e-5);
	
#if CAM
	// set view conditions and get water plane position viewed in the pixel
	float b = 3.14*length(m), a = atan(m.y,m.x);
	vec3 eye = vec3(sin(b)*cos(a),sin(b)*sin(a),cos(b)); // vec3(2.*m,2.);
	mat3 M; 					// view matrix
	M[0] = normalize(-eye);
	M[2] = normalize(vec3(0.,0.,1.)-M[0].z*M[0]);
	M[1] = cross(M[0],M[2]);
	vec3 ray = normalize(M*vec3(1.,uv));
	if (abs(ray.z)>1e-3) {
		float l = -eye.z/ray.z; vec3 P = eye + l*ray; // point on water plane
		uv = P.xy;
	}
#endif
	
	vec2 dir = normalize(uv);
	float d = 10.*length(uv);
	float x = 0., y = 0.; vec4 col = vec4(0.);
	
	// k = 2Pi/L , w = 2Pi/T
	// complete waves dispertion equation: w^2 = (gk + sigma/rho k^3) tanh(kh)
	// here, ignore tan(kh) ( = deep water case )
	
	// sum on wave spectrum // < 85: gravity waves  > 85: capillary waves
	for (float w = Wmin; w < Wmax; w += (Wmax-Wmin)/Wsamples) 
	{  
	    float k = solveP3(9.81, 0.074/1000.,-w*w);  // k(w)
		if (keyToggle(32)) d = 10.*length(uv+.03*(2.*vec2(hash(1./w),1.+hash(1./w))-1.));
		float phi =k*d-w*t ,						// wave phase
			  phi0 = 6.283*hash(w);   				// random phasing(w)
		float A = 2.*AMP(w) * pulse(-phi/w);		// amplitude
#if !COL
		y += A*sin(phi+phi0);
		// x += A*cos(phi+phi0);
#else
		A *= 1.;
		// normal to the surface, and ray reflection in the cubemap.
		vec3 N = normalize(vec3( A*k*cos(phi+phi0)*dir,-(1.-A*k*sin(phi+phi0)))),
			 V = reflect(ray,N);
		col += textureCube(iChannel0, V.xzy );
#endif
	}
	
#if COL
	fragColor = vec4(col/Wsamples); 
#else
	fragColor = vec4(.5+y); fragColor.b += .1;
#endif
}