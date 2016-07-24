// Shader downloaded from https://www.shadertoy.com/view/4dGSDR
// written by shadertoy user FabriceNeyret2
//
// Name: efficient splat 
// Description: Splatting particles is ultra-costly since you don't know which reach the pixel (so: test all).
//    Here, I maintain the list of local particles in tiles NxN, which drastically help.
//    Note that for now I don't treat ID collisions, so some disappear. (help !)
// display: splatting the particles.
//
//   we only have to test the coordinates in the current NxN tile,
//   + neighbor tiles if the sprites are larger than 1 pixel.

#define N 8. // tile size = NxN   ( change also in BufA ).
#define r 3. // sprite radius     ( must be <= N )

void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy,
        iU = floor(U/N)*N;    // tile coordinate
    O -= O; 
#if 1   
    for (int j = -1; j <= 1; j++)
        for (int i = -1; i <= 1; i++) { // check neighbor tiles (because sprites > 1 pix)
            vec2 d = vec2(i,j);
            for (float y=0.; y<N; y++)  
                for (float x=0.; x<N; x++) { // splat all the particles found in the tile
                    vec4 T = texture2D( iChannel0,( iU + N*d + vec2(x,y)+.5 )/R );
                    if (T.xy==vec2(0)) continue;      // void cell
                    O += (1.-O.a) * step( length(T.xy*R-U) , r)    // splat a disk
                                  * max(vec4(.2+T.zw,.2-T.z,1.),0.);    // color
                }
        }
 // O += (1.-O.a)*.2;
#else                                   // --- test
    for (float y=0.; y<N; y++)  
        for (float x=0.; x<N; x++)
             O += vec4( texture2D( iChannel0,( iU + vec2(x,y)+.5 )/R ).xy != vec2(0) )*.1;
    
#endif
}