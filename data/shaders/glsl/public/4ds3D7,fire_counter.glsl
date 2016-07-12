// Shader downloaded from https://www.shadertoy.com/view/4ds3D7
// written by shadertoy user FabriceNeyret2
//
// Name: Fire Counter
// Description: combine counter[1] and noise[2]
//    [1]: https://www.shadertoy.com/view/XslGD7
//    [2]: https://www.shadertoy.com/view/XslGRr
// ------------- Counter. (c) Fabrice NEYRET June 2013 -----------------------\\

#define STYLE 2     // 1/2
#define EFFECT 2    // 0/1/2
#define E (1./6.)   // segment thickness
#define DELAY 4.    // effect periodicity
float rad = 4.;     // segment shape ratio
#define ANIM true

#define PI 3.1415927
vec2 FragCoord;

vec2 pos   = vec2(.94*float(iResolution.x), .6*float(iResolution.y));
vec2 scale = 1.5*vec2(.25*float(iResolution.y),.375*float(iResolution.y));
#define offset .0

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of Created by inigo quilez

vec2 noise2( vec2 p )
{
	if (ANIM) p += iGlobalTime;
    float fx = noise(vec3(p,.5));
    float fy = noise(vec3(p,.5)+vec3(1345.67,0,45.67));
    return vec2(fx,fy);
}
vec2 fbm2( vec2 p )
{
	if (ANIM) p += iGlobalTime;
    float fx = fbm(vec3(p,.5));
    float fy = fbm(vec3(p,.5)+vec3(1345.67,0,45.67));
    return vec2(fx,fy);
}
vec2 perturb2(vec2 p, float scaleX, float scaleI)
{
    scaleX *= 2.;
	return scaleI*scaleX*fbm2(p/scaleX); // usually, to be added to p
}

// --- Displays digit b at pos with size=scale ------------------------------
//     return code =  1:pixel on , 0: pixel off , -1: pixel out of digit bbox
int _i;
float aff(int b)
{
	vec2 uv = (FragCoord.xy-pos)/scale;       // normalized coordinates in digit bbox
#if 1
	uv += perturb2((uv+pos/scale)-vec2(0.,2.*iGlobalTime),.1,1.5);  // distort digits
#endif
	pos.x -= (1.+offset)*scale.x;
	if((abs(uv.x)<.5)&&(abs(uv.y)<.5))    // pixel is in bbox
	{
		const float dy = 2.*(1.-E);
		float ds = 1./sqrt(1.+dy*dy)*3./1.414/(1.-2.*E);
		vec2 st = ds*vec2(uv.x-dy*uv.y,-uv.x-dy*uv.y);  // in diamond frame coords
		if((abs(st.x)>1.5)||(abs(st.y)>1.5)) return 0.; // pixel is not in 3x3 diamond grid
		st += 1.5;
		int seg = int(st.x)+3*int(st.y);           // diamond cell number
		if ((seg==2)||(seg==6)) return 0.;         // pixel is in a non-segment cells
		uv = 2.*(st-floor(st))-1.;                 // pixel in diamond cell coords
		float t=PI/4.; 
#if EFFECT>0
		float T = iGlobalTime;
		T = 2.*T-4.*(FragCoord.x/iResolution.x);   // phase varies with x
		float dt = DELAY*floor(T/DELAY); // effect every DELAY seconds
  #if EFFECT==1                       // rotation effect
		if (T-dt<PI/2.) {
			t=4.*(T-dt); 
			t = PI/4.+.5*(t-sin(t));
		}
  #elif EFFECT==2                     // zoom effect
		if (T-dt<PI) {
			float tt = 2.*(T-dt); 
			tt = sin(tt)*(1.-cos(tt))/1.3; // -1..1
			rad /= 1.-.9*tt;
		}		
  #endif
#endif
		float C = cos(t), S=sin(t);
		uv = vec2(C*uv.x-S*uv.y,S*uv.x+C*uv.y); // pixel in screen-parallel cell coords
	    bool c;                                 // true if pixel is in a set segment of digit b.
#if 1
		if     (b==0) c = (seg!=4);             // is pix in a segment of digit b ?
		else if(b==1) c = (seg==1)||(seg==5);
		else if(b==2) c = (seg!=3)&&(seg!=5);
		else if(b==3) c = (seg!=3)&&(seg!=7);
		else if(b==4) c = (seg!=0)&&(seg!=7)&&(seg!=8);
		else if(b==5) c = (seg!=1)&&(seg!=7);
		else if(b==6) c = (seg!=1);
		else if(b==7) c = (seg==0)||(seg==1)||(seg==5);
		else if(b==8) c =   true;
		else if(b==9) c = (seg!=7);
#else
		c = (seg==b);                        // drawn cell b
#endif
	    // return 1 if pixel should be drawn.
#if STYLE==1
	    if (c)	return max(1.-length(uv),0.); // pixel in positive shape for segment on
		else    return    length(uv); // pixel in positive shape for segment off			
#elif STYLE==2
		if (4*(seg/4)==seg) uv.y *=rad;       // segment = vertical or horizontal ellips
		else                uv.x *=rad;
	    if (c)	return 1.-length(uv)/1.3; // pixel in a set segment	shape
#endif
        return 0.; // pixel is in digit bbox but out of a set segment
	}
	return -1.;    // pixel is out of digit bbox
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float c;
	FragCoord=fragCoord;
    
	int t = int(iGlobalTime*100.);   // decompose 100*timer in digits 
	for (int i=0; i<5; i++) {
		_i = i;
		int n = t-10*(t/10); t=t/10; // n = digit from right to left
		c = aff(n);                  // 1 if pixel is in the digit bbox AND in a set segment 
		if (c>=0.) break;             // the digit under pixel as been found
	}
	
	vec2 uv = fragCoord.xy / iResolution.xy;
	if (c>0.) {
		c = .5*(1.+cos(PI*(1.-c))); c=pow(c,.5);
		float I = 1.-.2*noise(vec3(30.*uv.x+80.643,3.*uv.y-67.123,20.*iGlobalTime));
		float r = 1.;
		float g = r*noise(vec3(30.*uv.x,10.*uv.y,.5));
		fragColor = vec4(c*r*I,c*g*I,0.,1.0);     // draw set pixels
	}
	//else if (c==0)
	//	fragColor = vec4(0.*uv,0.5-0.5*sin(iGlobalTime),1.0);  // draw digit background
	else
		fragColor = vec4(0.);     // draw background
}