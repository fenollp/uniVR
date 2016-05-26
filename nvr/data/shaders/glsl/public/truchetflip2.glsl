// Shader downloaded from https://www.shadertoy.com/view/lst3R7
// written by shadertoy user FabriceNeyret2
//
// Name: TruchetFlip2
// Description: a variant from jt's https://www.shadertoy.com/view/4st3R7
// a variant from jt's https://www.shadertoy.com/view/4st3R7
// beside code golfing, main difference is s + S

float t = iGlobalTime, s;
#define R(s) texture2D(iChannel0, s + t/1e3).x  // random generator
#define S(v) smoothstep(.45,.55, len(v))        // use either len() or length()
//#define S(v) step(.05, abs(len(v)-.5))        

float len(vec2 v) {                             // roundness tuning. richer than length(v)
    float w = .2 + 1.6*abs(fract(t/16.)-.5);    // 1/w in [1/5 .. 1]
    v = pow(v, vec2(1./w));
    return pow(v.x+v.y, w);
}


void mainImage( out vec4 O,  vec2 v ) {
    vec2 w = ceil(v *= 10./iResolution.y);
    v.x *= s = sign( R(w/128.) - .5 );          // random flip (for orientation and coloring)
    s *= 2.*mod(w.x+w.y,2.)-1.;                 // checkboard flip (for coloring)

    O -= s*S(v=fract(v))*S(1.-v) + .5-.5*s + O++;  //  O = S(v)S(1-v); if (s<0) O=1-O
}