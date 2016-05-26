// Shader downloaded from https://www.shadertoy.com/view/4tlSR7
// written by shadertoy user FabriceNeyret2
//
// Name: crowded dotty place
// Description: another variant of https://www.shadertoy.com/view/ltfXRM
//    
//    ( still some bugs...)
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) { float a = t*T, c=cos(a),s=sin(a); v*=mat2(c,s,-s,c); }

void mainImage( out vec4 f, vec2 w ) {
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d,c; p.x-=.4; // init ray 
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p*.5;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;
    
    for (float i=1.; i>0.; i-=.01)  
    {
        vec4 u = floor(p/8.), t = mod(p, 8.)-4.; // objects id + local frame
        r(t.xy,u.x); r(t.xz,u.y); r(t.yz,1.);    // objects rotations
        u = sin(78.*(u+u.yzxw));                 // randomize ids
        t -= u;                                  // jitter positions
        u= .5+.5*u;
        
        vec4 ta=abs(t);     
         float x1 = length(ta.xyz) -2.6;           // spheres
         float x2 = max(ta.x,max(ta.y,ta.z)) -2.;  // bricks
        // float x = max(-x1,x2);
        float x = ( u.x>.6) ? max(-x1,x2) : x1;
        //float x = ( u.x>.6? length(ta.xyz)-.5 :max(ta.x,max(ta.y,ta.z)) ) -2.; // sphs+bricks

        vec4 w,v,w1,v1; 
        c=p/p;
        w  = floor(t)+u, v =  mod(t,1.)-.5,       // first dots layer
        w1 = sin(78.*(w+w.yzxw)), v1 = v-w1/8.;
        if (length(w1)/1.7>.5) c = mix(u, c, smoothstep(.2,.3,length(v1.xyz) -.2));
        t+=2.*u-1.; u = sin(57.*(u+u.yzxw)); t -= u; u= .5+.5*u;
        w  = floor(t)+u, v =  mod(t,1.)-.5,       // second dots layer
        w1 = sin(43.*(w+w.yzxw)), v1 = v-w1/8.;
        if (length(w1)/1.7>.5) c = mix(u, c, smoothstep(.2,.3,length(v1.xyz) -.2));
       
        
        f = (.2+i)*c;       // color texture + black fog (try c alone !)
  
        if(x<.01) break;    // hit !
        p -= d*x;           // march ray
     }
}
