// Shader downloaded from https://www.shadertoy.com/view/Xsy3Rw
// written by shadertoy user FabriceNeyret2
//
// Name: othello / reversi - computers
// Description: computer against computer. Not pretending to play well ! :-)
#define DEBUG 0

#define text(U)  texture2D(iChannel0, (U)/iResolution.xy)

void mainImage( out vec4 O, vec2 U )
{       
    O-=O;
#if DEBUG
    O = text(.1*U)/2.;  // debug display
    if (length(O.rg)>=1.) return; 
#endif
    
	vec2 R = iResolution.xy;
    U = (U+U-R)/R.y;
    O += smoothstep(.4,.35,length(4.*U-vec2(-5.5,0)))*(text(vec2(.5,9.5)).x*2.-3.); // actor
    if (abs(U.x)>1.) { O+=.5; return; }                 // out of board    
    
    vec2 P = floor(4.+4.*U);                            // curr cell
    if (P==text(vec2(.5,8.5)).rg) 
         O.r++;                                         // mark play position
    else O.g=.5;                                        // default cell color
    
    float v = text(P+.5).x;                                     // pawn value
    U = fract(U*4.+.05);                                        // cell coordinates
    if (v>0.) O += smoothstep(.4,.35,length(U-.55))*(v+v-3.);   // draw pawn
    if (min(U.x,U.y)<.07) O-=O;                                 // lines between cells
}