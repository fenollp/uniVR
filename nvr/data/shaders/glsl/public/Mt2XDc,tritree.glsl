// Shader downloaded from https://www.shadertoy.com/view/Mt2XDc
// written by shadertoy user FabriceNeyret2
//
// Name: tritree
// Description: the tri-tree variant of quad-tree https://www.shadertoy.com/view/lljSDy
//    indeed, this is another kind of 4trees ;-)
//    (NB: subdivision if the object intersect the node bounding sphere).
void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
    float r=.2, z=4., t=iGlobalTime, H = iResolution.y, uz;
    U /=  H;                              // object : disc(P,r)
    vec2 P = .5+.5*vec2(cos(t),sin(t*.7)), C=vec2(-.7,0), fU;  
    U =(U-C)/z; P=(P-C)/z; r/= z;         // unzoom for the whole domain falls within [0,1]^n
    
    mat2 M = mat2(1,0,.5,.87), IM = mat2(1,0,-.577,1.155);
    U = IM*U;         // goto triangular coordinates (there, regular orthonormal grid + diag )
    
    o.b = .25;                            // backgroud = cold blue

    for (int i=0; i<7; i++) {             // to the infinity, and beyond ! :-)
        fU = min(U,1.-U); uz = 1.-U.x-U.y;
        if (min(min(fU.x,fU.y),abs(uz)) < z*r/H) { o--; break; } // cell border
    	if (length(P-M*vec2(.5-sign(uz)/6.)) - r > .6) break;    // cell is out of the shape

                // --- iterate to child cell
        fU = step(.5,U);                  // select grid-child
        U = 2.*U - fU;                    // go to new local frame
        P = 2.*P - M*fU;  r *= 2.;
        
        o += .13;                         // getting closer, getting hotter
    }
               
	o.gb *= smoothstep(.9,1.,length(P-M*U)/r); // draw object
}