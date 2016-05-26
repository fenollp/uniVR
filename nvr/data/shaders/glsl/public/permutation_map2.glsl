// Shader downloaded from https://www.shadertoy.com/view/4dtSzM
// written by shadertoy user FabriceNeyret2
//
// Name: permutation map2
// Description: distribution of the 64 values in the permutation map :-(
//    How to use it as a permutation table, then ?
//    
//    SOLVED after regeneration of the permutation texture :-) 
// cf https://en.wikipedia.org/wiki/Ordered_dithering

void mainImage( out vec4 O,  vec2 U )
{
	O-=O; vec2 R = iResolution.xy;
    for (int j=0; j<8; j++)
        for (int i=0; i<8; i++) {
	        float T = texture2D(iChannel0,(vec2(i,j)+.5)/8.).x*R.x ;
            T = floor(T*63./R.x+.5)/64.*R.x ;
          //T = floor(T/8.)*8.;
            if (U.x-.5==floor(T)) O++;
        }
    U /= R; 
    if (U.y<.5 ) O.r = mod(floor(U*64.).x,2.)*.5;
    if (U.y<.25) O.b = mod(floor(U*8. ).x,2.)*.5;
}