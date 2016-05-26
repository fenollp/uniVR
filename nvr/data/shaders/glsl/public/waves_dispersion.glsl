// Shader downloaded from https://www.shadertoy.com/view/MtBSDG
// written by shadertoy user FabriceNeyret2
//
// Name: waves dispersion
// Description: Different wavelengths travels at different speed: this is dispersion.
//    Here, a 1D ripple made of capillary waves (i.e. raindrop fall, not asteroid ;-) ).
//    Top: sum.   Bottom: decomposition .
// different wavelengths travels at different speed: this is dispersion
// there are 2 main cases: gravity waves + capillary waves
// (+ mix case + shallow water + mix case + soliton + ... ok, forget theses :-p )
// Physics of dispersion here: https://en.wikipedia.org/wiki/Capillary_wave

// in 2D, add 1/r modulation. Or better: use Bessels instead of sines.

float A=.8,X,y,Y=0.,  t=mod(iGlobalTime,10.); 
vec2 R = iResolution.xy;

#define W(x,k,c) A*sin(k*(X=x-c*t))*exp(-X*X)

#define plot(Y) o += smoothstep(40./R.y, 0., abs(Y-uv.y))
// #define plot(Y) o +=exp(-max(0.,Y-uv.y))

void mainImage( out vec4 o, vec2 uv )
{
    o = vec4(0.0);
    uv = 10.* (2.*uv-R)/R.y; 
    
    for (float k=1.; k<10.; k++) {
        Y += y = W(abs(uv.x), k, sqrt(k))/k;   // dispertion for capillary waves
     // Y += y = W(abs(uv.x), k, 1./sqrt(k))/k;// dispertion for gravity waves
	    plot( y - 3.  ); 
    }

    plot( Y + 3. );
    
    o.b += .2;
}