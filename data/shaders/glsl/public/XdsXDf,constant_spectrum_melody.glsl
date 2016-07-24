// Shader downloaded from https://www.shadertoy.com/view/XdsXDf
// written by shadertoy user FabriceNeyret2
//
// Name: Constant spectrum melody
// Description: This melody is just made of constant tunes interfering with each others (see fullscreen). It is paradoxical in that you perceive low frequency variation and windowed spectrum variations despite the spectrum is still and without low frequency.
#define N      10.
#define harmon 10.
#define df     0.1
#define base   55.

float message(vec2 uv) { // to alert in the icon : click too see
    uv-=vec2(1.,16.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  928473456/bit; // 00110111 01010111 01100001 01110000
    if (int(uv.y)==1) i=  626348112/bit; // 00100101 01010101 01010000 01010000
    if (int(uv.y)==0) i= 1735745872/bit; // 01100111 01110101 01100001 01010000
 	return float(i-2*(i/2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iResolution.y<200.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}

    // the real shader:
    
    vec2 uv = fragCoord.xy / iResolution.xy;

    float v = 0.; 
	for (float i = 0.; i <= N; i++) 
        for (float j=1.; j <= harmon; j++) {
            float freq = (base+i*df)*j;
            float p = (freq-uv.x*600.)/.2;
		    v += exp(-.5*p*p);
        }

    fragColor = vec4(v*smoothstep(.8,.1,uv.y));
}