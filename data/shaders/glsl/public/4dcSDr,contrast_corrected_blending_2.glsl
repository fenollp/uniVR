// Shader downloaded from https://www.shadertoy.com/view/4dcSDr
// written by shadertoy user FabriceNeyret2
//
// Name: contrast-corrected blending 2
// Description: blending sprites can be seemless if correcting the variance, for contrast preserving.
//    left: linear blend   right : variance normalized
//    --- version with INT loop !  Original with float: https://www.shadertoy.com/view/lsKGz3
// NB: trick published in https://hal.inria.fr/inria-00536064v2

                                          // try textures random, checker, etc
#define T(U) texture2D(iChannel0,2.*U)*1.3      // *1.3 only for dark texture
#define mean texture2D(iChannel0,2.*U,10.)*1.3
                                       // variants:
// #define mean vec4(65,54,46,1)/255.     // mean for Britney video
// #define T(U) vec4(.5+.5*sin(120.*U.x)) // Gabor noise. mean = .5
// #define T(U) K(U)                      // simple blob. mean = .5
// #define mean .5

#define K(U) smoothstep(.2, .0, length(U))      // smooth kernel
#define rnd(i) fract(1e4*sin(i+vec2(0,73.17)))  // texture


void mainImage( out vec4 O,  vec2 U )
{
    O-=O;
    vec2 R = iResolution.xy, r=R/R.y;
    if (abs(U.x-R.x/2.)<2.) return;
    U /= R.y;
    float s=0., s2=0., v;
    for (int i=0; i<150; i++)
    {
        vec2 V = U-rnd(vec2(i))*r + .1*cos(vec2(i)+iDate.w+vec2(0,1.6)); // sprite position
        v = K(V); s += v; s2 += v*v;                          // kernel and momentums
        O += v*T(V);
    }
    // normalization
    if     (U.x<r.x/2.)
            O /= s;                          // linear blend
    else    O = mean + (O-s*mean)/sqrt(s2);  // variance preserving blend
}
