// Shader downloaded from https://www.shadertoy.com/view/MlXXDf
// written by shadertoy user FabriceNeyret2
//
// Name: adder
// Description: Simulates a N bits adder. Top: the 2 numbers to add (tuned by mouse.xy).
//    Try 11111111 + 1 :-)  
//    Each adder is made of 2 and/xor gates: A,B -&gt; AND,XOR
// Simulation of a N bits adder. 

#define N 8                   // number of bits

bool a0[N],b0[N],             // bits of the two numbers to be added
      s[N+1],                 // bits of the result
      a[2*N],b[2*N],c[2*N+1], // input of binary half-adders
      X[2*N],A[2*N];          // output of binary half-adders 


// --- utilities

#define rnd(x) fract(4e4*sin((x)*7654.23+17.34))

vec2 mymin(vec2 l,float l2,bool p) { return l.x < l2 ? l : vec2(l2,p); }

// --- draw line (indeed, distance to line. -> l = min(l, line() ). )

float line(vec2 uv, vec2 p0, vec2 p1) {
    uv -= p0; p1 -= p0;
    float lp = length(p1), luv = length(uv), l = dot(uv,p1/lp);
    if (l<0. || l>lp) return 1e8;

    return length(uv - l*(p1/lp));
}

void mainImage( out vec4 fragColor, vec2 uv ) {    
    float t = iGlobalTime*1., T = float(N+4),
          nt= floor(t/T); t = mod(t,T); 
    vec2 R = iResolution.xy, 
         m = iMouse.xy/R; 
    uv /= R;
    
	// --- init
    
    // all registers at false
    for (int i=0; i<N; i++) 
        a0[i]=b0[i]=s[i]=   a[i]=b[i]=c[i]=X[i]=A[i]=  a[i+N]=b[i+N]=c[i+N]=X[i+N]=A[i+N]=  false;
    s[N]=false;
 
    // the two numbers to be added (from mouse.xy or rnd)

    if (m.x+m.y<1e-5)   m.x = rnd(nt), m.y = rnd(nt+.5);
                    //  m.x = 0.96413, m.y = 0.71234;

    for (int i=N-1; i>=0; i--) { // a0,b0 = float2bin(inputs)
        float b; // vec2 b=floor(m*=2); m -= b; 
        m *= 2.;
        a0[i] = bool(b=floor(m.x)); m.x -=b;
        b0[i] = bool(b=floor(m.y)); m.y -=b;
    }
    

    
    // --- simulation steps (finite state automata)
    
    for (float it=2.; it<40.; it++) {
        if (it >= t) break;
        
	    // process connections
        for (int i=0; i<N; i++) {
             a[2*i]   = a0[i];  b[2*i]   = b0[i];  // input(even adder) = entry
             a[2*i+1] = X[2*i]; b[2*i+1] = c[2*i]; // input(odd adder) = XOR(even),carry
             c[2*i+2] = A[2*i+1]||A[2*i];          // carry(i+1) = OR(AND(even),AND(odd))
             c[2*i+1] = A[2*i+1];                  // (for display wire)
             s[i]     = X[2*i+1];                  // XOR(odd) -> result 
           }
       s[N] = c[2*N]; // last carry provide an extra bit to the sum.
        
        // process gates xor/and
        for (int i=0; i<2*N; i++)  
           { X[i] = a[i]^^b[i]; A[i] = a[i]&&b[i]; }
    }

    
    // --- display
    
    uv *= float(N)+2.2;
    int  ix = int(uv.x),  iy = int(uv.y);
    float x = fract(uv.x), y = fract(uv.y);
    float v=0.;

#define col(b) ( b ? 1. : .2 ) // registers aspect 

    // display registers (adders and general inputs and outputs)
     for (int i=0; i<N+1; i++)
         if (N+1-ix==i) {
    		if (iy==N+1 && i<N) // top row: input numbers
                v = y>.6       ? (x>.1 && x<.6 ? col(a0[i]): 0.) 
                  : y>.1&&y<.5 ? (x>.4 && x<.9 ? col(b0[i]): 0.)
                  : 0. ;

    	    else if (iy==0) // bottom row: output numbers
                v = y>.25 && y<.75 && x<.9 ? col(s[i]): 0.;
                                 
           else if (iy==N-i) // registers a,b,A,X of all half-adders
               if (y>.5) { x=2.*x; y = 2.*y-1.;
               v =  y>.5&&y<.9 ? ( x>.2&&x<.45 ? col(a[2*i  ]) : x>.55&&x<.8 ? col(b[2*i  ]) : 0. )
                  : y>.0&&y<.4 ? ( x>.2&&x<.45 ? col(A[2*i  ]) : x>.55&&x<.8 ? col(X[2*i  ]) : 0. )
                  : 0.;
                      }
             else {        x = 2.*x-1.; y = 2.*y;
               v =  y>.5&&y<.9 ? ( x>.2&&x<.45 ? col(a[2*i+1]) : x>.55&&x<.8 ? col(b[2*i+1]) : 0. )
                  : y>.0&&y<.4 ? ( x>.2&&x<.45 ? col(A[2*i+1]) : x>.55&&x<.8 ? col(X[2*i+1]) : 0. )
                  : 0.;
                  }        
         }
    
    // display connections

    vec2 l=vec2(1e8,0.); float y0;
 
    for (int i=0; i<N; i++) {
        x = float(N+1-i), y = float(N-i), y0=float(N+1); bool c2i=c[2*i+2]&&!c[2*i+1];
        l = mymin(l,line(uv, vec2(x+.25, y0+.7), vec2(x+.15, y+.9)   ), a[2*i]);  // a0 -> a2i
        l = mymin(l,line(uv, vec2(x+.65, y0+.2), vec2(x+.35, y+.9)   ), b[2*i]);  // b0 -> b2i
        l = mymin(l,line(uv, vec2(x+.5, .75  ),  vec2(x+.85, y+0.)   ), s[i]  );  // A2i+1-> si
        l = mymin(l,line(uv, vec2(x+.35, y+.6),  vec2(x+.65, y+.4)   ), a[2*i+1]);// X2i -> a2i+1
        l = mymin(l,line(uv, vec2(x+.15, y+.5),  vec2(x+.15, y+.7-1.)), c2i);     // carry1
        l = mymin(l,line(uv, vec2(x+.65, y   ),  vec2(x+.15, y+.7-1.)), c[2*i+1]);// carry2
        l = mymin(l,line(uv, vec2(x+.15, y+.7-1.),vec2(x+.8-1., y+.45-1.)),c[2*i+2]);// carryT
   }
    
    // combine registers and connections
	fragColor = mix(vec4(v),vec4(0,.75*l.y,1,1),smoothstep(20.,5.,l.x*R.x));
}