// Shader downloaded from https://www.shadertoy.com/view/XtjXW3
// written by shadertoy user FabriceNeyret2
//
// Name: Hilbert curve 5
// Description: A variant of https://www.shadertoy.com/view/XljSW3
//    Cf https://www.shadertoy.com/view/XljXW3 for its parameterisation.
#define plot(U,l) ( dot(U,l) > 0.  ? abs( dot(U , vec2(-l.y,l.x)) ) : 0. )
#define plotC(U,l)  abs( length(U-(l)/2.) - .5 )

void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
    float s = 1.;  // mat2 R = mat2(0,-1,-1,0);
    U /= iResolution.y; U.x -= .3; U+=1e-5; // or bug at depth 2. why ?
    vec2 P = vec2(.5), I=vec2(1,0),J=vec2(0,1), fU, l=-I,r=l, k;
    
    for (float i=0.; i<10.; i++) {
        if (i > mod(iGlobalTime,7.) ) break;
       //fU = min(U,1.-U); if (min(fU.x,fU.y) < 4./H) { o.r++; break; } // cell border

        fU = step(.5,U);         // select child
        bvec2 c = bvec2(fU);     
        U = 2.*U - fU;           // go to new local frame
        l = c.x ? c.y ? -J : -I            // node left segment
                : c.y ?  l :  J;
        r = (c.x==c.y)?  I : c.y ?-J:J;    // node right segment
        // the heart of Hilbert curve : 
        if (c.x) { U.x = 1.-U.x;  l.x=-l.x;  r.x=-r.x;  k=l;l=r;r=k; }      // sym
        if (c.y) { U   = 1.-U.yx; l  =-l.yx; r  =-r.yx; }  // .5+(U-.5)*R   // rot+sym
        s++;
    }

    o += length(l+r) > 0. ?   plotC (U-P, l+r) :  plot (U-P, l) + plot (U-P, r); 
    o = smoothstep(.33+.01*s,.33-.01*s,o);
    
    fU = min(U,1.-U);            // clamp or color
    o *= min(fU.x,fU.y)<0. ? o-o : vec4(.3,1,.1,1);
}