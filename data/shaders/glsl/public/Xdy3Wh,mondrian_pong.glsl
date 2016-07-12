// Shader downloaded from https://www.shadertoy.com/view/Xdy3Wh
// written by shadertoy user FabriceNeyret2
//
// Name: Mondrian pong
// Description:  reproducing http://33.media.tumblr.com/tumblr_mafojfoHoJ1rvbw2yo1_400.gif 
//    :-)
// reproducing http://33.media.tumblr.com/tumblr_mafojfoHoJ1rvbw2yo1_400.gif

void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy, L;
	U = 100.* (U+U-R)/R.y;
    
    float B = 1.,                   // border size
          t = iGlobalTime;
    vec2 P  = mod(t/vec2(1,2),2.); P = 2.*min(P,2.-P)-1.; // ball trajectory
    vec2 P2 = 50.*P,               // ball
         L2 = vec2(15,12),
         L0 = vec2(15,45),         // left pad
         P0 = vec2(-80,P2.y*.7), 
         L1 = vec2(15,45),         // right pad
         P1 = vec2( 80,-P2.y*.7);
     
    
    O-=O;
#define box(P,S,C) L = abs(U-P)/S; if (max(L.x,L.y)<1.)  { O = C; return; }
    box( P0, L0, vec4(1,0,0,1) );
    box( P1, L1, vec4(0,0,1,1) );
    box( P2, L2, vec4(1,1,0,1) );
    
#define lines(P,S)  L = abs(U-P-(S))/B; if (min(L.x,L.y)<1.)   return; 
    lines( P0, L0+B); lines(P0,-L0-B); 
    lines( P1, L1+B); lines(P1,-L1-B); 
    lines( P2, L2+B); lines(P2,-L2-B); 
    O++;
}