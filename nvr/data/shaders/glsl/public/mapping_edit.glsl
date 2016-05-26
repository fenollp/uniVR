// Shader downloaded from https://www.shadertoy.com/view/MddGW2
// written by shadertoy user FabriceNeyret2
//
// Name: mapping edit
// Description: drag nodes with mouse to edit the mapping.
//    Space to toggle the grid.
// inspired from https://www.shadertoy.com/view/MstGW2

#define S 80.
                                                               // draw segment [a,b]
#define L(a,b)  O.g+= 1e-1 / length( clamp( dot(U-a,v=b-a)/dot(v,v), 0.,1.) *v - U+a )
#define T(i,j) texture2D(iChannel0,(.5+S*vec2(i,j))/iResolution.xy).xy
    
float cross(vec2 a, vec2 b) { return a.x*b.y - b.x*a.y; }
#define key(k) ( texture2D(iChannel2,vec2((.5+float(k))/256.,.75)).x > 0.)


void mainImage( out vec4 O,  vec2 U )
{   
    O -= O; 
    vec2 st=vec2(-1);
    
    for (int j=0; j<5; j++) 
    {
        vec2 v, P00, P01, P10 = T(0,j), P11 = T(0,j+1);
        // L(P10,P11);
        
        for (int i=0; i<9; i++) 
        {
            P00=P10, P01=P11, P10 = T(i+1,j), P11=T(i+1,j+1);
/*          vec2 M = max(max(P00,P01),max(P10,P11)),
                 m = min(min(P00,P01),min(P10,P11)),
                 P = step(m,U)*step(U,M);
           if (P.x*P.y >= 0.) // bbox optimization   <><><>  Indeed, makes it costlier !
*/            { 
            // find u,v bilinar coordinates of current pixel within the current mesh cell
            vec2 AB = P10-P00, CD = P11-P01, AC = P01-P00, D=CD-AB;
/*          if (length(D)<1e-5) { // no u*v term: parallelogramm case
                float c = cross(AB,AC), u = cross(U-P00,AC)/c, v = cross(U-P00,AB)/(-c);
                if ( min(u,v)>=0. && max(u,v)<=1. ) O=texture2D(iChannel1, (vec2(u,v)+vec2(i,j))/vec2(9,5));
                continue;
            } */  // <><><> never called
            float c = cross(AC,D), a = cross(U-P00,D)/c, b = cross(-AB,D)/c, // v = a+b.u
                  A = D.x*b, B = AB.x+AC.x*b +D.x*a, C = P00.x-U.x+AC.x*a,   // P2(u) = 0
                  d = B*B - 4.*A*C;
            if (d>=0.) { // solve P2(u), then v. if (u,v) in [0,1]^2, cur pixel is in this cell
                d = sqrt(d); 
                float u;
                if (abs(A)<1e-5) u = -C/B; // P2() is a P1()
                else {                     // full P2()
                  u = (-B+d)/(2.*A);
                  if (u<0. || u>1.) u = (-B-d)/(2.*A);
                }
                if (u>=0. && u<=1.) {
                    float v = a+b*u;
                    if (v>=0. && v<=1.)
                 // O += (1.-O.a)* // if 2 patches clame the same pixel
                 //     texture2D(iChannel1, 
                        st = (
                                  (vec2(u,v)+vec2(i,j))/vec2(9,5)); //texture patch
                }
            }}
            
            if (!key(32)) {
                L(P00,P01); L(P00,P10);   // draw one vertical and one horizontal segment
                 O += smoothstep(5.,3.,length(U-T(i,j)));  // draw points
            }
        }
    }
    if (st.x>=0.) O += texture2D(iChannel1, st);
}