// Shader downloaded from https://www.shadertoy.com/view/XdXSR8
// written by shadertoy user FabriceNeyret2
//
// Name: noise histogramm 2
// Description: Evaluates histogramm of Perlin noise algorithms.
//    In theory fbm should be Gaussian...
//    Try larger STEP to better average.
#define SAMPLE 200      // per 1x1 pixel bin
#define STEP 32.        // bin width
#define LAZZY 1         // lazzy exact noise evaluation
#define SMOOTH 0.       // smooth histogramm on 3 values.  0. / 1. / sub-relaxation
#define NOISE_SRC 1  	// 0: texture 1: math


#define NOISE_TYPE 1    // 1: linear  2: blobby (abs)  3:  hairy (1-abs)


#define ANIM 1          
#define PI 3.14159

#if ANIM
  float t = iGlobalTime;
#else
  float t = 0.; 
#endif
vec2 FragCoord;

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )  // base rand in [0,1]; 
{
#if NOISE_SRC==0
	return texture2D(iChannel0,vec2(n,n/256.)).r;
#elif NOISE_SRC==1
	return fract(sin(n-765.36334)*43758.5453);
#endif
   
    
}

float noise( in vec3 x ) // base noise in [0,1]; 
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
#if NOISE_TYPE==1
	return res;
#elif NOISE_TYPE==2
	return abs(2.*res-1.);
#elif NOISE_TYPE==3
	return 1.-abs(2.*res-1.);
#endif
}

float fbm( vec3 p ) // turbulent (=fractal) noise in [0,1]; 
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of: Created by inigo quilez --------------------


// for noise to be thresholded, we not always need to compute high freq

float fbm_lazzy( vec3 p , float v0, float v1) // v0,v1: min/max thresholds
{
    float v01 = .5*(v0+v1), dv = .5*(v1-v0);
	float s=1.,f,r=1.,t;
	
	              s*=.5; f  = s*noise( p ); r-=s; if (abs(f-v01)>r+dv) return f+.5*r; 
	p = m*p*2.02; s*=.5; f += s*noise( p ); r-=s; if (abs(f-v01)>r+dv) return f+.5*r; 
	p = m*p*2.03; s*=.5; f += s*noise( p ); r-=s; if (abs(f-v01)>r+dv) return f+.5*r;
	p = m*p*2.01; s*=.5; f += s*noise( p );

    return f;
}


// calc histogramm of noise

float histogramm(vec2 uv) {
	float dx = dFdx(uv.x)*STEP;   // slice size
	float s = 0., q=0., n;
	
	for (int j=0; j<= SAMPLE; j++)
	{
		float y = float(j)/float(SAMPLE);
#if !LAZZY
		n = fbm(8.*vec3(0.,y,t));
#else
		n = fbm_lazzy(8.*vec3(0.,y,t), uv.x, uv.x+dx);
#endif

		if (abs(n-uv.x) < .5*dx) s++;
		q++;
	}
	return .1*s/(q*dx);
}


// smmothing using hardware derivatives. if SMOOTH <1, sub-relaxation

float smooth(float v)
{
	float vx = -dFdx(v)*(2.*mod(FragCoord.x-.5,2.)-1.),
		  vy = -dFdy(v)*(2.*mod(FragCoord.y-.5,2.)-1.);

	return v + SMOOTH*(vx+vy)/3.;
}

// main loop

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    FragCoord=fragCoord;
	vec3 col=vec3(0.);
	if (uv.y < exp(-.5*pow((uv.x-.5)/.15,2.))*.5) col = vec3(0.,0.,.5);
	if (mod(uv.y,.1)<=1./iResolution.y) col = vec3(0.,1.,0.);
	if (mod(uv.y,.5)<=4./iResolution.y) col = vec3(0.,1.,0.);
	if (mod(uv.x,.1)<=1./iResolution.x) col = vec3(1.,0.,0.);
	if (mod(uv.x,.5)<=4./iResolution.x) col = vec3(1.,0.,0.);
	
	
	float t = histogramm(uv);
	
	if (SMOOTH != 0.) t = smooth(t);  // average with neightboor pixels
	if (t > uv.y)  col=vec3(1.);		     // draw bar
	
	fragColor = vec4(col,1.); 
}
