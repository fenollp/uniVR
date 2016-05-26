// Shader downloaded from https://www.shadertoy.com/view/MsfXzM
// written by shadertoy user FabriceNeyret2
//
// Name: Gabor3
// Description: mouse: freq and dir of Gabor.
//    A: mouse.y tunes angular spread instead.
//    T: mouse.x tunes gaussian thickness instead.
//    Red: Fourier representation of the Gabor function.
//    Cyan: Signal representation of the Gabor function.
// inspired from https://www.shadertoy.com/view/MdjGWy#


// for faster eval, you can decrease proportionnaly NB and GAUSS_F to keep coverage
float GAUSS_F = .1;    // size of gabor blobs
#define NB 100.        // number or gabor blobs

#define SCALE 30.      // SCALING FACTOR for superimposing signal and fourier spaces

#define PI 3.14159265358979

// --- key toggles -----------------------------------------------------

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}


// --- util math func  -----------------------------------------------------

#if 0  // 1: texture-based noise  0: function-based noise
float rnd(vec2 uv, int z) 
{
	if      (z==0) return texture2D(iChannel1,uv).r;
	else if (z==1) return texture2D(iChannel1,uv).g;
	else if (z==2) return texture2D(iChannel1,uv).b;
	else           return texture2D(iChannel1,uv).a;
}
float rndi(float i, float j)
{
	vec2 uv = vec2(.5+i,.5+j)/ iChannelResolution[1].x;
	return texture2D(iChannel1,uv).r;
}
#else
float rndi(float i, float j)
{
	return fract(sin(i+9876.*j)*12345.678);
}
#endif

float gauss(float x, float s) {
    return exp(-.5*(x*x)/(s*s)); 
}
float gauss(float x) {
    return exp(-.5*x*x); 
}
float gauss(float s,vec2 D) {
	float d = dot(D,D)/(s*s);
	return exp(-.5*d); 
}

#define SQR(x) ((x)*(x))

float gabor(vec2 pos, vec2 k, float gaussF, float phi) {
	float g = gauss(length(pos), 1./gaussF);
    float s = .5*sin(2.*PI*dot(pos,k) - phi);
	return g*s;
}

// -----------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.85,.5));

	// --- tuning 
	
	vec4 mouse; 
	mouse.xy = 2.*(iMouse.xy/  iResolution.y - vec2(.85,.5));
	mouse.zw = 2.*(abs(iMouse.zw)/  iResolution.y - vec2(.85,.5));
	if (iMouse.x+iMouse.y==0.) mouse = vec4(.5);
	vec3 col;
	float vS=0.,vF=0.,A=0.;
	
	vec2 k = mouse.xy; // wave number
	
	if (!keyToggle(65)) { // tune angular spread
		A = PI/2.* .5*(1.+mouse.y);
		k.y = mouse.w;
	}
	if (keyToggle(84)) { // tune angular spread
		GAUSS_F *= 4.*iMouse.x/iResolution.x;
		k.x = abs(mouse.z);
	}
	
	
	// --- display
	
	vec2 k_ortho = vec2(-k.y,k.x);
	
	// in Fourier space, Gabor = Gauss(s)*F(sin) = 2 Gaussians at k and -k
	// in signal space, Gabor = Gauss(1/s).sin(kx)  * white

	for (float i=0.; i<NB; i++) { 
		
		// random sample within angular spread
		float a = A*(2.*i/NB-1.);
		vec2 Rk = cos(a)*k + sin(a)*k_ortho;

		// signal space:  white := Poisson point distrib -> sum random pos
		vec2 pos =2.*vec2(1.5*rndi(i,0.),rndi(i,1.))-1.;		
		vS += gabor(SCALE*(uv-pos), Rk, GAUSS_F, 10.*iGlobalTime +float(i));
		// Fourier: (dirac+ + dirac-)*gauss
		vF += 		 gauss(    GAUSS_F,uv-Rk) + gauss(    GAUSS_F,uv+Rk)
			 - 10.*( gauss(.02*GAUSS_F,uv-Rk) + gauss(.02*GAUSS_F,uv+Rk) );
	}
	
	vF *= max(1., length(k)*2.*A/(PI*GAUSS_F)) /float(NB); // normalization
	vS = (1.-vF)*(vS*sqrt(3.*GAUSS_F)+1.)/2.;

	fragColor = vec4(vF,vS,vS,1.);
}
                  
