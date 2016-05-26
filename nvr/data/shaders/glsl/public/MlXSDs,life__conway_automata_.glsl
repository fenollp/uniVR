// Shader downloaded from https://www.shadertoy.com/view/MlXSDs
// written by shadertoy user FabriceNeyret2
//
// Name: Life (Conway automata)
// Description: Conway game of life.
//    Sorry it gets ultra-slow with time: as long as we won't be allowed to save frame state in shadertoy, all simulations have to re-play at every time+pixel the whole duration since t=0;.
#define N 10
bool T0[N*N],T1[N*N];	// state of the grid cell (odd/even time steps)

#define m(i) (i<0 ? i+N : i>=N ? i-N : i) // to manage bounds through cyclicity
#define  T(h,i,j)        ( h==0 ? T0[m(j)*N+m(i)] :      T1[m(j)*N+m(i)] )
//#define  T(h,i,j)      ( h==0 ? T0[(j)*N+i]     :      T1[(j)*N+i]     )
#define setT(h,i,j,v)  if (h==0)  T0[(j)*N+i] = v ; else T1[(j)*N+i] = v;
#define iT(h,i,j)        int(T(h,i,j))

#define rnd(x) fract(4e4*sin(x*1654.7+4.17))

void mainImage( out vec4 o, vec2 p )
{
    vec2 R = iResolution.xy;
	p = (p-(R-R.y)/2.) / R.y;
    if (p.x<0. || p.x >=1.) { o += .2; return; };
    p *= float(N);
    int P = int(p.y)*N+int(p.x);
    
    int T = int(mod(iGlobalTime,20.));
    if (T<1) return;
    
    // --- initialization
	for (int i=0; i<N*N; i++)
    	T0[i] = rnd(float(i))<.15;
    
    // --- simulation steps
    int h=0;
    for (int t=4; t<20; t++) {
        if (t>T) break; // replay steps up to current time
        for (int j=0; j<N; j++) {
            int S[N]; // optimization: precompute vertical sums
            for (int i=0; i<N; i++) 
                S[i] = iT(h,i,j-1) + iT(h,i,j) + iT(h,i,j+1);
    	    for (int i=0; i<N; i++) {
                // compute neighborhod population
                int c = S[m(i-1)] + S[i] + S[m(i+1)] - iT(h,i,j);
        	    // int c =   iT(h,i-1,j-1) + iT(h,i,j-1) + iT(h,i+1,j-1)
            	//         + iT(h,i-1,j  )               + iT(h,i+1,j  )
                //	       + iT(h,i-1,j+1) + iT(h,i,j+1) + iT(h,i+1,j+1);
                // 3 neighbors -> life. 2 neighbors -> stable. otherwise -> death.
	            setT(1-h,i,j, c==2 ? T(h,i,j) : c==3); 
         }  }
        h = 1-h;
    }
    
    // --- display
	for (int j=0; j<N; j++)
        for (int i=0; i<N; i++)
            if (j*N+i==P) o = vec4( T(h,i,j) );
   
}