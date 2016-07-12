// Shader downloaded from https://www.shadertoy.com/view/XsdXRM
// written by shadertoy user FabriceNeyret2
//
// Name: permutation map
// Description: how to decode  the permutation map into unique indices from 0 to 63 ?
//    Above, the binary decomposition help understanding its organisation.
//     *63/256: missing: 1, 63  twice: 11, 21
//    NOW WORKING ! (after regeneration of the permutation texture).
// cf https://en.wikipedia.org/wiki/Ordered_dithering

bool D(vec2 p, float n) {                         // display digit
    int i=int(p.y), b=int(exp2(floor(30.-p.x-n*3.)));
    i = ( p.x<0.||p.x>3.? 0:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: 0 )/b;
 	return i-i/2*2==1;
}

void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy;  U /= R;
	O = texture2D(iChannel0, U);
#if 0 // testing 3 bits
    vec4 O2 = texture2D(iChannel0, U+.5);  
    O =  floor(O*63.+.5); O  = floor(O/8.)/8.; 
  //O = .5+.5*cos(6.28*O.x+vec4(0,-2.1,2.1,0));  return;
    O2 = floor(O2*63.+.5);O2 = floor(O2/8.)/8.;
    O = vec4(length(O-O2) < 1e-3); return;
#endif
    
  //float C = O.x*63.  +1e-5;                   // conversion permutation texture -> index
    float C = floor(O.x*63.+.5)+1.;                   
  //float C = floor(O.x*63.*2.)/2.; C = (C==11.5)? 1.: (C==21.5)? 63.: floor(C); O = vec4(C/63.);

	U = fract(U*8.);
   
    if ( D(U*16.-vec2(4,9), floor(C/10.) )    )      {O++; return; }   // digits
    if ( D(U*16.-vec2(8,9), mod(floor(C),10.)))      {O++; return; }
  //if ( D(U*16.-vec2(12,9), mod(floor(C*10.),10.))) {O++; return; }
    
    if (fract(U.x+.01)<.02 || fract(U.y+.02)<.04) { O++; return; }  // lines & frames 
    if (fract(8.*U.x)<.1) { O=vec4(.5); return; }
    if (U.y<.25) return;
    
    O = .5+.5*cos(6.28*O.x+vec4(0,-2.1,2.1,0));   // rainbow mapping
    
    C /= 256.;
    if (abs(U.y-.5)<.25) {                        // binary decomposition
        for (int i=0; i<8; i++) {
            C = 2.*fract(C);
            if (i==int(8.*U.x))  O *= vec4(floor(C)==0.);
        }
    }
}