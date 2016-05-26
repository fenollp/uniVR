// Shader downloaded from https://www.shadertoy.com/view/lsV3Dz
// written by shadertoy user FabriceNeyret2
//
// Name: window manager
// Description: Workflow for a basic window manager. Move windows, change their format (move slowly ! :-) )
//    NB: interactive borders start a bit inside the windows.
vec2 R = iResolution.xy;
#define tex(x,y) texture2D(iChannel0,(vec2(x,y)+.5)/R)
#define B 5./R                                               // border size

#define activeWindow() tex(0,0).y                            // wich window is active ?
vec4 drawWindow( vec2 U, int c );

vec4 WM(vec2 U) {                    // -------------- display windows ----------------
    for (int i=1; i<=16; i++) 
        if (i<=int(tex(0,0).x)) {
            vec4 W = tex(i,0);
            vec2 In = step( abs(U-W.xy-W.zw/2.), W.zw/2.);  
            if (In.x*In.y>0.) {                              // pixel in window #i 
                U = (U-W.xy)/W.zw;
                int c = int(tex(i,1).x);                     // channel attached to window
                return drawWindow(  U,  c ); 
            }
            In = step( abs(U-W.xy-W.zw/2.), W.zw/2.+B);
            if (In.x*In.y>0.)                                // pixel in window #i border
                return int(activeWindow())==i ? vec4(1.) : vec4(.5,.5,.5,1);  
        }
    return vec4(0);
}

vec4 drawWindow( vec2 U, int c ) // -------------- your window content here ------------
{
    if      (c==1) return texture2D(iChannel1,U);
    else if (c==2) return texture2D(iChannel2,U);
    else if (c==3) return texture2D(iChannel3,U);    
    else return vec4(0);
}

void mainImage( out vec4 O,  vec2 U )
{ 
	O = WM(U/R);                         // display windows
    O = mix (vec4(.1,.1,.5,1), O, O.a);  // blend background
}