// Shader downloaded from https://www.shadertoy.com/view/XtlXRB
// written by shadertoy user FabriceNeyret2
//
// Name: crowded gyros - 425 chars
// Description:  compact simplified version of https://www.shadertoy.com/view/MllXz7
// compact simplified version of https://www.shadertoy.com/view/MllXz7 (773 chars)
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define r(t) *=mat2(C=cos(t*T),S=sin(t*T),-S,C),

void mainImage( out vec4 f, vec2 w ) {
    f-=f;
    float T=iGlobalTime, C,S, x;
    vec4 p = f-.5, d,u,t,a; 
    p.xy += w/iResolution.y, p.x-=.4; 
    p.xz r(.13)   p.yz r(.2)  
    d = p;  p.z += 5.*T;
      
    for (float i=1.; i>0.; i-=.01) {
        
        u = sin(78.+ceil(p/8.)), t = mod(p,8.)-4.; 
        x=1e9;
        
        for (float j=2.3; j>1.; j-= .3)
            t.xy r(u.x)   t.xz r(u.y)
            a = abs(t),
            x = min(x, max(abs(length(t.xyz)-j*1.26),  max(a.x,max(a.y,a.z))-j)); 
 
        if(x <.01) {  f = vec4(i*i*1.2); break;  } 
        p -= d*x;           
     }
}
