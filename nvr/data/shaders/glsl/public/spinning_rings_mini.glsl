// Shader downloaded from https://www.shadertoy.com/view/XsGGRw
// written by shadertoy user squid
//
// Name: Spinning Rings Mini
// Description: More spinning rings!
//Code initially from FabriceNeyret2 (https://www.shadertoy.com/view/ltBSRy), 
// who took it from Trisomie21: https://www.shadertoy.com/view/4tfGRB#

//You would think that these shorter shaders would be faster...

#define T (iGlobalTime*.06)
#define r(t) mat2( C = cos(t*T), S = sin(t*T), -S, C )
#define Q  P.xz*=F;P.yz*=F; x = min(x, length( vec2( length(P.xz) - (R-=.1), P.y ) ) - .03);

void mainImage( out vec4 f, vec2 w ) {
    float C,S,R,x=1.; f=vec4(0.);
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d=p, P;
    d.x -= .3; p.z -= 1.5;          
    mat2 F = r(6.);
    for (float i = 1.; i>0.; i-=.03) 
    {
        P=p;R=1.;
        float z = 0.;
        
        Q Q Q Q Q Q
                    
        if(x<.02) {
            f.x=i+.3;
            f.y=i*i; 
            return;
        } 
        
        p -= d*x*1.3;
     }
 }
