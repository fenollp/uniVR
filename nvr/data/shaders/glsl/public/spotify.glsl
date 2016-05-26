// Shader downloaded from https://www.shadertoy.com/view/4s3GzM
// written by shadertoy user FabriceNeyret2
//
// Name: spotify
// Description: a variant of https://www.shadertoy.com/view/Xd3GzM
#define L 8.  // interline distance
#define A 2.  // amplification factor


void mainImage( out vec4 o,  vec2 uv )
{
    o -= o;
    uv /= L;
    vec2  p = floor(uv+.5);

    #define T(x,y) texture2D(iChannel0,L*vec2(x,y)/iResolution.xy)   // add .g or nothing 

    #define S(c,T) o += cos( 6.28*(uv-p).c + A*(2.*T-1.) ); 

    S( y, T( uv.x, p.y ) )   // modulates  y offset
    S( x, T( p.x, uv.y ) )   // modulates  y offset
    
    if ( L*uv.x < .5*iResolution.x ) o += o.g - o;
        
}