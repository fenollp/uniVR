// Shader downloaded from https://www.shadertoy.com/view/MtBSDV
// written by shadertoy user FabriceNeyret2
//
// Name: quadtree 5
// Description: variant of https://www.shadertoy.com/view/ltBSDV#
void mainImage( out vec4 o,  vec2 U )
{
    float r=.1, t=iGlobalTime, H = iResolution.y,n=0.;
    U /=  H;                              // object : disc(P,r)
    vec2 P = .5+.5*vec2(cos(t),sin(t*.7)), fU;  
    U*=.5; P*=.5;                         // unzoom for the whole domain falls within [0,1]^n
    
    //o.b = .25;                            // backgroud = cold blue
    
    for (int i=0; i<7; i++) {             // to the infinity, and beyond ! :-)
        fU = min(U,1.-U); if (min(fU.x,fU.y) < 3.*r/H) { o--; break; } // cell border
    	if (length(P-.5) - r > .7) break; // cell is out of the shape

                // --- iterate to child cell
        fU = step(.5,U);                  // select child
        U = 2.*U - fU;                    // go to new local frame
        P = 2.*P - fU;  r *= 2.;
        
        o =   n==0. ?  texture2D(iChannel0 ,U) 
            : n==1. ?  texture2D(iChannel1 ,U) 
            :          texture2D(iChannel2 ,U);
        n = mod(++n,3.);
    }
               
	//o.gb *= smoothstep(.9,1.,length(P-U)/r); // draw object
}