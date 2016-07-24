// Shader downloaded from https://www.shadertoy.com/view/ldd3zr
// written by shadertoy user FabriceNeyret2
//
// Name: one cube challenge - v1  (279)
// Description: challenge: code golf (here) or propose alternate algorithm (with close result) separately (then, copy this rule and  accept code-golfing).   The winner is the smaller :-)    ( but must adapt to window resolution )
// 279 by coyote
void mainImage( out vec4 f, vec2 w ) {
    f -= f;
    vec4 p = vec4(w,0,0)/iResolution.y - .5, d, t, M, m;
    p.x -= .4; // init ray
    d = p;     // ray dir = ray0-vec3(0)
    p.z -= 4.; // cam pos
   
    for (int i=0; i<99; i++)
        t = p, // local frame
        t.xz *= mat2( w = sin(iDate.w+vec2(1.6,0)), -w.y,w.x ), // rotate
    
        m = min(M = max( t = abs(t), t.yzxw), M.yzxw), // dist to cube lines
        //f.w = max( max(t.x,M.y)-1., .99-min(m.x,m.y) ),
        f.w = max( max(t.x,M.y)-1.2, 1.15-min(m.x,m.y) ),

        f.w < .01 ? f++   // hit
          : p -= d*f.w;   // march ray
}
/**/



/* // 297

// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

void mainImage( out vec4 f, vec2 w ) {
    f -= f;  
    vec4 p = vec4(w,0,1)/iResolution.y-.5, d, t,M,m; p.x-=.4; // init ray 
    d = p;                                             // ray dir = ray0-vec3(0)
    p.z -= 4.;                                         // cam pos
    vec2 T = sin(iDate.w+vec2(1.6,0));
   
    for (float i=1.; i>0.; i-=.01)  
    {
        t = p;  // t = mod(p, 8.)-4.;                  // local frame
        t.xz *= mat2( T, -T.y,T.x );                   // rotate
    
        m = min(M = max( t = abs(t), t.yzxw), M.yzxw); // dist to cube lines
        float x = max( max(t.x,M.y)-1.2, 1.15-min(m.x,m.y) );
        
        if(x<.01)  f++;                                // hit
        // if(x<.01) { f +=i*i; break; }

        p -= d*x;   // march ray
     }
 }
/**/