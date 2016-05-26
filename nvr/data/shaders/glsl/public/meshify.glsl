// Shader downloaded from https://www.shadertoy.com/view/XdcGzM
// written by shadertoy user FabriceNeyret2
//
// Name: meshify
// Description: a variant of https://www.shadertoy.com/view/Xd3GzM
#define L 8.  // interline distance
#define A 4.  // amplification factor
#define P 6.  // thickness

void mainImage( out vec4 o,  vec2 uv )
{
    o -= o;
    uv /= L;
    vec2  p = floor(uv+.5);

    #define T(x,y) texture2D(iChannel0,L*vec2(x,y)/iResolution.xy).g   // add .g or nothing 

    #define M(c,T) o += pow(.5+.5*cos( 6.28*(uv-p).c + A*(2.*T-1.) ),P)

    M( y, T( uv.x, p.y ) );   // modulates  y offset
    M( x, T( p.x, uv.y ) );   // modulates  y offset
    
}