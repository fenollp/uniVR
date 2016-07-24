// Shader downloaded from https://www.shadertoy.com/view/Xdc3Wn
// written by shadertoy user FabriceNeyret2
//
// Name: SunflowerTransform 3
// Description: another variant from jt's https://www.shadertoy.com/view/Mdd3R7
//    ( you can try various looks by uncommenting )
// another variant from jt's https://www.shadertoy.com/view/Mdd3R7
    
#define mirror(v) abs(2. * fract(v / 2.) - 1.)
float t = iGlobalTime, a=(sqrt(5.)-1.)*2.;
vec4 circ(vec2 v)
{
    vec2 w = fract(v)-.5;
    float r= .5+.5*sin(3.14*(10.*length(w)-2.*t));
    
    v.y += fract(sqrt(v.x/a)-.5+.02*t); return r*vec4(.5+.5*sin(.5*v-t),0,1); // look 1
    //return r*vec4(1.-w,0,1);                                                // look 2
    //return  mix(vec4(1,.5,.5,1),vec4(.5,1,1,1),r);                          // look 3
}

void mainImage( out vec4 O, vec2 I )
{
	vec2 R = iResolution.xy; 
    I = 8.* (I+I-R)/R.y;

    I = vec2(0, length(I)) + atan(I.y, I.x) / 6.283 + .02*t;
    I.x = ceil(I.y) - I.x;
    I.x *= I.x * a;

    O = circ(I);
}
