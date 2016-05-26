// Shader downloaded from https://www.shadertoy.com/view/Xsy3zw
// written by shadertoy user FabriceNeyret2
//
// Name: othello / reversi - human/comput
// Description: Human/Computer, Human/Human, Computer/Computer ( flag #Human in BufA)    .  You are white.
//    NB: I don't pretend the computer plays well ! :-)
#define DEBUG 0
#define SHOW  1  // 0 1 2   1: enlight allowed places  2: show places score

vec2 R = iResolution.xy;
#define text(U)  texture2D(iChannel0, (U+.5)/R)
#define draw_pawn(D,v) O += smoothstep(.4,.35,length(D)) * (2.*(v)-3.)

void mainImage( out vec4 O, vec2 U )
{       
    O-=O;
#if DEBUG
    O = text(.1*U-.5)/2.;               //  display states for debug
    if (length(O.rg)>=1.) return; 
#endif
    
    U = (U+U-R)/R.y;
    draw_pawn(4.*U-vec2(-5.5,0), text(vec2(.5,9.5)).x); // show current player
    if (abs(U.x-1.3)<.1 && U.y>=0. && U.y<text(vec2(0,11)).x/64.) O--; // #black pawns
    if (abs(U.x-1.5)<.1 && U.y>=0. && U.y<text(vec2(0,11)).y/64.) O++; // #white pawns
    if (abs(U.x)>1.) { O+=.5; return; }                 // out of board    
    
    vec2 P = floor(4.+4.*U);                            // current cell
    U = fract(U*4.+.05);                                // cell coordinates

    if (P == text(vec2(0,8)).xy) 
         O.r++;                                         // mark play position
    else O.g=.5;                                        // default cell color
    if (SHOW>=1 && text(P+16.).x>0.) O.g+=.2;           // enlight allowed places
    if (SHOW==2 && abs(U.x-.5)<.1 && U.y<text(P+16.).x/16.) O.r++; // show place sclore
    
    float v = text(P).x;                                // pawn value
    if (v>0.) draw_pawn(U-.55, v);                      // draw pawn
    if (min(U.x,U.y)<.07) O-=O;                         // lines between cells
}