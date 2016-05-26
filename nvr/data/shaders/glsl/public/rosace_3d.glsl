// Shader downloaded from https://www.shadertoy.com/view/ldcSzB
// written by shadertoy user FabriceNeyret2
//
// Name: rosace 3d
// Description: variant of https://www.shadertoy.com/view/ls3XWM  https://www.shadertoy.com/view/ld3SRB#
// inspired from  aiekick/Shane textured variant of https://www.shadertoy.com/view/ls3XWM
//                                      see https://www.shadertoy.com/view/ld3SRB#

void mainImage( out vec4 O, vec2 U ){

	vec2 R = iResolution.xy; R = 4.*floor(R/4.);
    U = (U+U-R)/R.y;                                                 // normalized screen
    float s=floor(++U.x); U.x = mod(U.x+1.+.15*sign(s-.5), 2.) - 1.; // 2 normalized areas
    float r=length(U), a = atan(U.y, U.x), A, B, d, t=iGlobalTime;   // polar coordinates

    O -= O;  
   
    for (int i=0; i<3; i++ ) { 
        A = B = 5./3.*a;  if(s>0.) B+=t; else A+=t; // fractional => 3 turns to close loop via 5 wings.
        d = smoothstep(1., .9, 8.*abs(r-.2*sin(A)-.5));                  // ribbon wings
        vec4 T = 1.3*texture2D(iChannel0, vec2(B/3.14159, r-.2*sin(A))); // to attach texture replace B by A
        O = max(O, (1.+cos(A)*.7)/1.7 * d*T);       // 1+cos(A) = depth-shading
        a += 6.28319;                               // next turn
    }
}