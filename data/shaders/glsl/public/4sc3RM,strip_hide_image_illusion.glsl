// Shader downloaded from https://www.shadertoy.com/view/4sc3RM
// written by shadertoy user FabriceNeyret2
//
// Name: strip hide image illusion
// Description: pause the video for stronger effect.
//    The image is masked by the strip high-freq... but any blurring (motion, distance, unfocusing) fades the mask.
#define L 8.   // interline distance
#define A .25  // amplification factor

void mainImage( out vec4 o,  vec2 uv )
{
    uv /= L;
 // float t = -10.*iMouse.x/iResolution.x;          // strips move with mouse   
    float t = .5*iGlobalTime; t= 30.*(t+sin(t));    // strips move with time 
    t=fract(t); 
    float  x = floor(uv.x+.5+t)-t;

    #define T texture2D(iChannel0,L*vec2(x,uv.y)/iResolution.xy)

 // o += 1.-cos(6.28*(uv.x-x)*(1.+A*(2.*T-1.))) -o;
    o += cos( 6.28*(uv.x-x) * (1.-A*(2.*T-1.)) ) -o;    // modulates line thickness
 // o += cos( 6.28*(uv.x-x) + A*4.*(2.*T-1.) ) -o;      // modulates line offset

}