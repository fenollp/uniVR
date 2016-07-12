// Shader downloaded from https://www.shadertoy.com/view/ltBSRy
// written by shadertoy user FabriceNeyret2
//
// Name: crowded cubes 2
// Description: one more variant of https://www.shadertoy.com/view/ltfXRM 
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) v *= mat2( C = cos((t)*T), S = sin((t)*T), -S, C )

void mainImage( out vec4 f, vec2 w ) {
    float C,S,r,x;
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d; p.x-=.4; // init ray 
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;                           // travelling 
   
    for (float i=1.; i>0.; i-=.01) 
    {
        vec4 u = floor(p/8.), t = mod(p, 8.)-4., M,R; // objects id + local frame
        // r(t.xy,u.x); r(t.xz,u.y); r(t.yz,1.);      // objects rotations
        u = sin(78.*(u+u.yzxw));                      // randomize ids
   
        r = 1.2;
        t = abs(t); M=max(t,t.yzxw); 
        x = max(t.x,M.y)-r;                         // solid cube
		R = r-u/2.-M;
        if (u.x>0.) x = max(x, R.x);       // substract some bars
        if (u.y>0.) x = max(x, R.y);
        if (u.z>0.) x = max(x, R.z);
        
        if(x<.01)  // hit !
            { f = i*i*(1.+.2*t); break; }  // color + black fog 

        p -= d*x;                          // march ray
     }
 }
