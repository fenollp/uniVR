// Shader downloaded from https://www.shadertoy.com/view/XsV3Dz
// written by shadertoy user FabriceNeyret2
//
// Name: the 11th character
// Description: This is the base trick of a classical illusion where offsetting the top half of an image makes one more character appears. I couldn't find the magic google expression to fish an example. Idea, somebody ?
#define N 11.  // number of final characters
#define R .3   // radius used above and below mid-height

void mainImage( out vec4 O,  vec2 U )
{
    O -= O;
	U /= iResolution.xy;
    if (U.y>.5) U.x -= (.5+.5*sin(iGlobalTime) ) / N;

    // initial bars are composed of N units, final bars are composed of N-1 units
    float n = R/(N-1.),         y = (R + n )/2., // n: units size  y: mid-bar 
          b = floor(U.x*=N);  U.x = fract(U.x);  // b: bar Id
    
	if (b>=0. && b<N-1.)  O +=   step(abs(U.y-(.5-R+y+b*n)), y) * step(abs(U.x-.5),.2); 
                            // * vec4(b/N,1.-b/N,.5,1);      
}