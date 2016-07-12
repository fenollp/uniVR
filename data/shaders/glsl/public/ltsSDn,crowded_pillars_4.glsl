// Shader downloaded from https://www.shadertoy.com/view/ltsSDn
// written by shadertoy user FabriceNeyret2
//
// Name: crowded pillars 4
// Description: variant of https://www.shadertoy.com/view/XtfSDn
// using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

#define T iGlobalTime
#define r(v,t) { float a = (t)*T, c=cos(a),s=sin(a); v*=mat2(c,s,-s,c); }
#define smin(a,b) (1./(1./(a)+1./(b)))

void mainImage( out vec4 f, vec2 w ) {
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d,c; p.x-=.4; // init ray 
    r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z += 50. *cos(.1*T);
    //f = vec4(0);
    
    for (float i=1.; i>0.; i-=.01)  {
        
        float R=8.+4.*cos(.05*T), x,v;
        vec4 u = floor(p/R), t = mod(p, R)-R/2.; //, ta=abs(t); // objects id + local frame
        c = textureCube(iChannel0, abs(t).zxy-3.);  // c for color, c.x for displacement
  
        // r(t.xy,u.x); r(t.xz,u.y); r(t.yz,u.z);
        // t -= 2.*u;  
        
        x = smin(length(t.xy),smin(length(t.yz),length(t.xz))) -.7 +c.x;   
        // v = c.x*.4;
        // x = max(x, -ta.x+.4-v);  x = max(x, -ta.y+.4-v);  x = max(x, -ta.z+.4-v);
        
        if(x<.01) // hit !
            { f = 2.*i*c; break;  }  // color texture + black fog 
        
        p -= d*x;           // march ray
     }
}
