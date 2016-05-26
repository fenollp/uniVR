// Shader downloaded from https://www.shadertoy.com/view/MsKGz3
// written by shadertoy user FabriceNeyret2
//
// Name: Britney mosaic
// Description: application of contrast-corrected blending https://www.shadertoy.com/view/lsKGz3#
//    on Britney's video.  Mouse control video region
// cf https://www.shadertoy.com/view/lsKGz3#

// try textures random, checker, etc
#define T(U) texture2D(iChannel0,U+m)
#define mean vec4(65,54,46,1)/255. 

#define K(U) smoothstep(.2, .0, length(U))      // smooth kernel
#define rnd(i) fract(1e5*sin(i+vec2(0,73.17)))  // texture


void mainImage( out vec4 O,  vec2 U )
{
    O-=O;
    vec2 R = iResolution.xy, r=R/R.y, m=iMouse.xy/R;
    if (m==vec2(0)) m=vec2(.5);
    // if (abs(U.x-R.x/2.)<2.) return;
	U /= R.y;
    float s=0., s2=0., v;
    for (float i=0.; i<150.; i++) 
    {
        vec2 V = U-rnd(i)*r  + .1*cos(i+iDate.w+vec2(0,1.6)); // sprite position
        v = K(V); s += v; s2 += v*v;                          // kernel and momentums
	    O += v*T(V);
    }
    // normalization
    if     (false) //(U.x<r.x/2.)
            O /= s;                          // linear blend
    else    O = mean + (O-s*mean)/sqrt(s2);  // variance preserving blend
}