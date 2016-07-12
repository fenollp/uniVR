// Shader downloaded from https://www.shadertoy.com/view/XlsGDs
// written by shadertoy user FabriceNeyret2
//
// Name: Gabor 4: normalized
// Description: mouse.x:  freq
//    mouse.y: % normalization      S: tune spectrum instead
//    C: colormap  M/N: modulations of contrast (before normalization) D:+derivatives
//    T: stop time  Z: show complex Gabor F: flip left/right 
//    K: clamp normalization (no div by 0)
//    P,RGB
// inspired from https://www.shadertoy.com/view/MdjGWy#

#define NB 600.        // number or gabor blobs
float SIZE   = 0.0566; // .22 size of gabor blobs
float SPREAD = 0.;     // .5  angular variation

// --- utilities ------------------------------

#define PI     3.14159265358979
#define ISQRT2 0.7071067811865

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float gauss(float x,float s) {
    return exp(-.5*(x*x)/(s*s)); 
}
float gauss(vec2 v,float s) { return gauss(v.x,s)*gauss(v.y,s); }

float rnd(vec2 uv, int z) {
	if      (z==0) return texture2D(iChannel1,uv).r+texture2D(iChannel1,uv).b/256.;
	else if (z==1) return texture2D(iChannel1,uv).g+texture2D(iChannel1,uv).a/256.;
	else if (z==2) return texture2D(iChannel1,uv).b;
	else           return texture2D(iChannel1,uv).a;
}
float rndi(float i, float j) {
# if 1 // precision required !
    return fract(1e5*sin(i+3.*j+0.567));
#else
    j += i / iChannelResolution[1].x; i = mod(i,  iChannelResolution[1].x);
	vec2 uv = vec2(.5+i,.5+j)/ iChannelResolution[1].x;
	return texture2D(iChannel1,uv).r+texture2D(iChannel1,uv).b/256.;
#endif
}

float BesselJ0(float x) {
    x=abs(x); return (x>PI/2.) ? sqrt(2./(PI*x))*cos(x-PI/4.) : cos(x*ISQRT2);
}
float BesselJ1(float x) {
    float s=sign(x); x=abs(x);
    return (x>2.4) ? s*sqrt(2./(PI*x))*sin(x-PI/4.) : s*0.581865*sin(PI/2.*x/1.8411838);    
}

// --- complex Gabor ------------------------------
vec2 Gabor(vec2 pos, float freq, float a) {
    float t = (keyToggle(64+20))? 0. : iGlobalTime; // 'T'
    float g = gauss(pos,SIZE);
    if (g < 1e-3) return vec2(0.);
    vec2 dir = ISQRT2*(cos(a)*vec2(1.,1.)+ sin(a)*vec2(-1.,1.));
    float phi = freq*dot(pos,dir) * 2.*PI - 10.*t;

    #define CAS 1 // 1: normal   others: experiments
#if CAS==1 // bilobe
    return g*vec2(cos(phi),sin(phi));

#elif CAS==2 // blob
    a = 2.*PI*length(dir);
    return - 2.*PI*SIZE*SIZE*gauss(a*SIZE,1.)*vec2(cos(-10.*t),sin(-10.*t));
#elif CAS==3 // quadrilobe
    dir = vec2(-dir.y,dir.x);
    float phi2 = freq*dot(pos,dir) * 2.*PI - 10.*t;
    return (g*vec2(cos(phi),sin(phi)) +g*vec2(cos(phi2),sin(phi2)))/2. ;
#elif CAS==4 // 1/2 ring (sampled)
    vec2 n=vec2(0.);
    for (float a=0.; a<PI/2.; a+= PI/20.) {
     	dir = ISQRT2*(cos(a)*vec2(1.,1.)+ sin(a)*vec2(-1.,1.));
    	phi = freq*dot(pos,dir) * 2.*PI - 10.*t;
        n += g*vec2(cos(phi),sin(phi));
    }
    return (n/10.);
#elif CAS==5 // ring-cos
    phi = freq*length(pos) * 2.*PI - 10.*t;
    return g*vec2(cos(phi),sin(phi));
#else // ring-Bessel
    phi = freq*length(pos) * 2.*PI - 10.*t;
    return vec2(BesselJ0(phi),BesselJ1(phi)); // where to put SIZE ?
#endif
}

// --- complex Gabor noise = kernel * point distrib
vec2 GaborNoise(vec2 uv, float freq, float dir) {
    vec2 f=vec2(0.); float fa=0.;
	for (float i=0.; i<NB; i++) { 
		vec2 pos = vec2(1.8*rndi(i,0.),rndi(i,1.));
        float a = dir + SPREAD *PI*(2.*i/NB-1.);
		f += Gabor(uv-pos, freq, a);
        // fa += pow(gauss(uv-pos),2.);
	}
   //fragColor = vec4(100.*fa/NB); return;
	return f *sqrt(200./NB); // /6.;
}

// ------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // --- controls 
    vec2 uv = fragCoord.xy / iResolution.y;
    vec2 mouse = iMouse.xy / iResolution.xy;
    float m = .5* iResolution.x / iResolution.y; // mid x
	float freq = mix(10., iResolution.x/10., mouse.x);
    if (keyToggle(64+19)) SPREAD = mouse.y;      // 'S'
    if (keyToggle(64+16)) SIZE *= .1;            // 'P'
	    
    // --- Gabor noise = kernel * point distrib
	vec2 f  = GaborNoise(uv,freq,0.); 
    float l0 = length(f), k=.5;
#if 0
    vec2 f2 = GaborNoise(uv,freq,PI/2.);
    float l2 = length(f2);
	f = f+f2; l0 = sqrt(l0*l0+l2*l2);
#endif
    
    // --- Display energy 
    if(keyToggle(64+13)) {           // 'M'
	    fragColor = vec4(.5*l0);     // show amplitude
    	if (l0<.2) fragColor.r = 1.-fragColor.r/.2; // div by ~0
        if(keyToggle(64+4)) {                             // 'D'
            fragColor.gb = vec2(0.);
            if (keyToggle(64+18)) fragColor.r=0.;         // 'R'
            float g = length(vec2(dFdx(l0),dFdy(l0)))*iResolution.y;
        	if (!keyToggle(64+7)) fragColor.g = 1.-.05*g; // 'G' low gradient
        	//k = clamp(1.-.01*g,0.,1.)*clamp(1.-.4*l0/.2,0.,1.);
            k = .0005*length(vec2(dFdx(g),dFdy(g)))*iResolution.y;
			if (!keyToggle(64+2)) fragColor.b = (2.*k);   // 'B' marks discontinuities
        }
    }
    // --- Normalize and display Gabor noise
    else {
	    float b = (keyToggle(64+19)) ? 1. : 1.-mouse.y;
        if(keyToggle(64+11)) l0 = max(k,l0); // 'K': clamp normalization
    	if ((uv.x<m)==!keyToggle(64+6)) f *= .5; else f /= mix(2.,l0,b);
        //f0 = f;
   		if(!keyToggle(64+26)) f.x=f.y;       // real vs complex Gabor
        if(keyToggle(64+3))                  // 'C'  colorMap
        	{ f = cos(3.14*f); if(!keyToggle(64+26)) f.y*=-1.; }
    	fragColor = vec4(.5+.5*f.x,.5+.5*f.y,0.,1.);
    }
    if(keyToggle(64+14)) fragColor = mix(fragColor,.5*vec4(l0),.5);
}

