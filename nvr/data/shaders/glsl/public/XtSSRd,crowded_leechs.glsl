// Shader downloaded from https://www.shadertoy.com/view/XtSSRd
// written by shadertoy user FabriceNeyret2
//
// Name: crowded leechs
// Description: one more variant of https://www.shadertoy.com/view/ltfXRM 
//    
//    ( &quot;if you can't draw a fish, draw some worms&quot; ;-) ).
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

float T=iGlobalTime+5.;
#define r(v,t) v *= mat2( C = cos((t)*T), S = sin((t)*T), -S, C )

float smin( float a, float b ) {
    return min(a,b);
/* #define N 8.
    a = pow( max(0.,a), N ); b = pow( max(0.,b), N );
    return pow( (a*b)/(a+b), 1./N );
*/
}

void mainImage( out vec4 f, vec2 w ) {
    f -= f;
    float C,S,r,r1,x,x1,i0,a;
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d,p2, u,t,t1,M,m; p.x-=.4; // init ray 
         
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;
   
    for (float i=1.; i>0.; i-=.01)  
    { x = 1e3;
     for(float j=0.; j<=1.; j++) {
        u = floor(p/8.+11.5*j);                 // objects id + local frame
        u = fract(1234.*sin(78.*(u+u.yzxw)));         // randomize ids
        
        p2 = p+11.5*j; 
         if (j==0.) p2.x -= 15.*T*(2.*u.y-1.);            // offset column
         else       p2.y -= 15.*T*(2.*u.z-1.);    
        u = floor(p2/8.); t = mod(p2, 8.)-4.;
        u = fract(1234.*sin(78.*(u+u.yzxw)*vec4(1,-12,8,-4)));
                 
        t1 = t+1.5*sin(1.*T+u*6.);  
        x1 = length(t .xyz*vec3(.25,1,1)-vec3(0,.1*sin(4.*t1.x+16.*T),0))-.5;    

        x = smin(x,x1);
        if(x<.01) break;   // hit !
      }
    
        if(x<.01) {i0=i; break; }  // hit !
    
        p -= d*x;           // march ray
     }
    if(x<.01)  // hit !
        { f = i0*i0*vec4(1.2,.4*u.x,.1,1)*(.5+.5*texture2D(iChannel0,.2*(t.xy+t.xz))); } // color texture + black fog 
}
