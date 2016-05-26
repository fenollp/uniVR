// Shader downloaded from https://www.shadertoy.com/view/Mdd3WB
// written by shadertoy user FabriceNeyret2
//
// Name: snake3
// Description: Drive with mouse.   Clear screen with rewind icon.
//    bufA::1 #def sticky   allows to change the consistentness 
#define N 10. // N*N particles
#define R iResolution.xy
#define t iGlobalTime
#define id(v)    ( floor(v.x) + N*floor(v.y) )
#define point(P) texture2D(iChannel0,(P+.5)/R ).xy
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

void mainImage( out vec4 O, vec2 U )
{
    O -= O;
    
    for (float j=0.; j<N; j++)
        for (float i=0.; i<N; i++) {
            vec2 p = ( U - point(vec2(i,j))  )/R.y;
            float id = id(vec2(i,j)), a = id/(N*N);
            p *= rot(id+t);
            O += (1.-O.a) * smoothstep(.1,.08,length(p))
                          * mix(texture2D(iChannel1,4.*p),texture2D(iChannel2,4.*p),.5+.5*cos(6.28*16.*a));
	       // O += 1e-5/dot(p,p);
        }
}