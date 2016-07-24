// Shader downloaded from https://www.shadertoy.com/view/4lsXzM
// written by shadertoy user FabriceNeyret2
//
// Name: crowded psychedelic place
// Description: a psychedelic variant of https://www.shadertoy.com/view/ltfXRM :-)
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) { float a = t*T, c=cos(a),s=sin(a); v*=mat2(c,s,-s,c); }

void mainImage( out vec4 f, vec2 w ) {
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d,c; p.x-=.4; // init ray 
     r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z += 5.*T;
    
    for (float i=1.; i>0.; i-=.01)  
    {
        vec4 u = floor(p/8.), t = mod(p, 8.)-4.; // objects id + local frame
         r(t.xy,u.x); r(t.xz,u.y); r(t.yz,1.);    // objects rotations
        u = sin(78.*(u+u.yzxw));                 // randomize ids
        t -= u;                                  // jitter positions
        u = .5+.5*u;
        
        t = abs(t);     // here for relief X symmetry
        //c = textureCube(iChannel0, t.zxy-3.);  // c for color, c.x for displacement
        c = p/p;                            // just the canonical shape           
        // c = mix(p/p,c,.5+.5*sin(T)); 

        // t = abs(t);  // here for no relief symmetry
        // float x = min(t.y, length(t.xz) -1.5 + 1.*c.x); // pilars
        float x1 = length(t.xyz) -3.6 + c.x;           // spheres
        float x2 = max(t.x,max(t.y,t.z)) -3. + c.x;      // bricks
        float x = max(-x1,x2);
        // float x = ( u.x>.6? length(t.xyz)-.5 :max(t.x,max(t.y,t.z)) ) -2. + c.x; // sphs+bricks
 
        // f = p/p*p.w*.01;                // show depth
        // f = p/p*x*100.;                 // show dist
        f = c*mix(1.,i*i*4.,.5+.5*sin(T));      // color texture + black fog (try c alone !)
        // f *= (.5+.5*u)*vec4(1,1,.005,1);     // gradient block coloring (set off random id)
        f *= u*.5;                              // random block coloring

        if(x<.01) break;    // hit !
        p -= d*x;           // march ray
     }
}
