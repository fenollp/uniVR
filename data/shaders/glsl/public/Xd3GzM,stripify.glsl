// Shader downloaded from https://www.shadertoy.com/view/Xd3GzM
// written by shadertoy user FabriceNeyret2
//
// Name: stripify
// Description: try on various images or videos :-)
#define L 8.  // interline distance
#define A 2.  // amplification factor

void mainImage( out vec4 o,  vec2 uv )
{
    uv /= L;
 // float t = -10.*iMouse.y/iResolution.y;  // strips move with mouse   
    float t = 1.*iGlobalTime;               // strips move with time  
    t=fract(t); 
    float  y = floor(uv.y+.5+t)-t;

    #define T texture2D(iChannel0,L*vec2(uv.x,y)/iResolution.xy)   // add .g or nothing 

 // o += 1.-cos(6.28*(uv.y-y)*(1.+A*(2.*T-1.))) -o;
 // o += cos( 6.28*(uv.y-y) * (1.-A*(2.*T-1.)) ) -o; // modulates line thickness
    o += cos( 6.28*(uv.y-y) + A*(2.*T-1.) ) -o;      // modulates line offset
    
    if ( L*uv.x < .5*iResolution.x ) o += o.g - o;
        
}