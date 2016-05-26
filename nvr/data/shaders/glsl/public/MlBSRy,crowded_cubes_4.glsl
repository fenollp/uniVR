// Shader downloaded from https://www.shadertoy.com/view/MlBSRy
// written by shadertoy user FabriceNeyret2
//
// Name: crowded cubes 4
// Description: one more variant of https://www.shadertoy.com/view/ltfXRM &lt;br/&gt;&lt;br/&gt;How many different behavior will you count ? :-)
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) v *= mat2( C = cos((t)*T), S = sin((t)*T), -S, C )

void mainImage( out vec4 f, vec2 w ) {
    f-=f;
    float C,S,r,rt,r2,x,x1,x2,x3,n;
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d; p.x-=.4; // init ray 
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;
   
    for (float i=1.; i>0.; i-=.01)  
    {
        vec4 u = floor(p/8.), t = mod(p, 8.)-4., ta, M,m; // objects id + local frame
        //r(t.xy,u.x); r(t.xz,u.y); r(t.yz,1.);           // objects rotations
        u = fract(1234.*sin(78.*(u+u.yzxw)));             // randomize ids
   
        r = 1.2;
        ta = abs(t); M=max(ta,ta.yzxw); m=min(M,M.yzxw);
        x1 = max(ta.x,M.y)-r;
        x2 = min(m.x,m.y);
        x = max(x1,1.1-x2);                     // cube frame
        rt = cos(3.*T+10.*u.y+23.*u.z);
        r2 = r*(.5+.4*rt);
        n = fract(u.x+u.y+u.z);
        if      (n<.25) x3 = max(ta.x-r2,M.y-r); // growing plate
        else if (n< .5) x3 = max(ta.x-r,M.y-r2); // growing bar
        else if (n<.75) {                        // moving plate
       		     ta.x = abs(t.x-r*rt);  M=max(ta,ta.yzxw);      
        	     x3 = max(ta.x-r*.1,M.y-r);
               }
        else   { r(t.xy,3.); ta = abs(t); M=max(ta,ta.yzxw);
                 x3 = max(ta.x-r*.1,M.y-r);      // rotating plate
               }
        x = min(x, x3 );

        if(x<.01)  // hit !
            { f = i*i*(1.+.2*t); break; } // color texture + black fog 

        p -= d*x;           // march ray
     }
 }
