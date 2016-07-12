// Shader downloaded from https://www.shadertoy.com/view/XtlSR7
// written by shadertoy user FabriceNeyret2
//
// Name: crowded cheesy place
// Description: a swiss variant of https://www.shadertoy.com/view/ltfXRM :-)
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) { float a = t*T, c=cos(a),s=sin(a); v*=mat2(c,s,-s,c); }

void mainImage( out vec4 f, vec2 w ) {
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d; p.x-=.4; // init ray 
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);      // camera rotations
    d = p*.5;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;
    
    for (float i=1.; i>0.; i-=.01)  
    {
        vec4 u = floor(p/8.), t = mod(p, 8.)-4.; // objects id + local frame
        r(t.xy,u.x); r(t.xz,u.y); r(t.yz,1.);    // objects rotations
        u = sin(78.*(u+u.yzxw));                 // randomize ids
        t -= u;                                  // jitter positions (also cause artifacts..)
        u= .5+.5*u;

        vec4 ta = abs(t);     
        float x = max(ta.x,max(ta.y,ta.z)) -2.;      // bricks

        vec4 w,v, w1,v1;
        w = floor(t-.5)+u, v =  mod(t-4.5,1.)-.5,
        w1 = sin(78.*(w+w.yzxw)), v1 = v-w1/4.;
        x = max(-length(v1.xyz) +.4, x);             // small holes
        w = floor(t/2.-.1)+u, v =  mod(t-4.2,2.)-1., 
        w1 = sin(13.*(w+w.yzxw)), v1 = v-w1/3.;
        x = max(-length(v1.xyz) +.8, x);             // medium holes
        w = floor(t/3.)+u, v =  mod(t-4.,3.)-1.5, 
        w1 = sin(57.*(w+w.yzxw)), v1 = v-w1/2.;
        x = max(-length(v1.xyz) +1.3, x);            // big holes


        u=vec4(.7,.6,.2,1)*1.2;
        f = (.2+i)*u; 
 
        if(x<.01) break;    // hit !
        p -= d*x;           // march ray
     }
}
