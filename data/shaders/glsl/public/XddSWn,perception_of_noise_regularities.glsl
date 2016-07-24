// Shader downloaded from https://www.shadertoy.com/view/XddSWn
// written by shadertoy user FabriceNeyret2
//
// Name: perception of noise regularities
// Description: Human perceptive system can detect symmetry (and tiling) in noise.
// try commenting lines 8 and/or 9 and/or 7, or changing N

#define N 2. // scale of periodicity
#define ZOOM 1.

void mainImage( out vec4 O, vec2 U )
{   
    U -= 128.;
    
    U = mod(U,256.*N);           // noise periodicity
    U.x = min(U.x,256.*N-U.x);   // noise symmetry in x
    U.y = min(U.y,256.*N-U.y);   // noise symmetry in y
  //U = min(U,256.*N-U);

    U = .5 + (U-.5)/ZOOM;
    
	O = texture2D(iChannel0,U/256.);
  //O = fract(iGlobalTime+O);    // animated noise
}