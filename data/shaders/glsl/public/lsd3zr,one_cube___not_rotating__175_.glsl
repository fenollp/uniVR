// Shader downloaded from https://www.shadertoy.com/view/lsd3zr
// written by shadertoy user FabriceNeyret2
//
// Name: one cube - not rotating (175)
// Description: ok this is cheating, since not rotating.  Just to see how many chars it takes to draw a cube :-)
// 175 by jt
#define L    +u ; v = 1.- v*v; f += .02/min(v.x,v.y);
#define S(c) v = c.5 L    v = vec2(u.x c-2.,c 1.-u.x) L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    vec2 v = iResolution.xy;
    u = (u+u-v)/v.y/.5;
    S() S(-)
}
/**/



/* // 177 by 834144373
#define L    ; v = 1.- v*v; f += .02/min(v.x,v.y);
#define S(c) v = u +c.5 L    v = u+vec2(u.x c-2.,c 1.-u.x) L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    vec2 v = iResolution.xy;
    u = (u+u-v)/v.y/.5;
    S() S(-)
}
/**/



/* // 178 by jt
#define L    ; v = 1.- v*v; f += .02/min(v.x,v.y);
#define S(c) v = u+.5*c L    v = u+vec2(u.x-c-c,c-u.x) L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    vec2 v = iResolution.xy;
    u = (u+u-v)/v.y/.5;
    S(1.) S(-1.)
}
/**/



/* // 180 by 834144373

#define L    v = 1.- v*v; f += 2e-2/min(v.x,v.y);
#define S(c) v = u+.5*c; L    v = u+vec2(u.x-c-c,c-u.x); L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    vec2 v = iResolution.xy;
    u = (u+u-v)/v.y/.5;
    S(1.) S(-1.)
}
/**/



/* // 181
   #define L    v = 1.- v*v; f += 2e-2/min(v.x,v.y);
// #define S(c) v = u+.5*c; L    v = (u-vec2(c,0))*mat2(2,0,-1,1); L
// #define S(c) v = u+.5*c; L    v = (u.x-c)*vec2(2,-1);v.y+=u.y; L
// #define S(c) v = u+.5*c; L    v = vec2(2.*(u.x-c),c-u.x+u.y); L
   #define S(c) v = u+.5*c; L    v = u+vec2(u.x-c-c,c-u.x); L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
     u = 4.*u/iResolution.y -vec2(3.6,2);    
    vec2 v;
    S(1.) S(-1.)
}
/**/



/*  // 190 - 191     
#define L    v = .5- abs(v); f += 1e-2/min(v.x,v.y);
#define S(c) v = u+.5*c; L    v = (u-vec2(c,0))*mat2(2,0,-1,1); L

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    u = 2.*u/iResolution.y -1.;  u.x -= .8;  // -1 char by 834144373
//  u = 2.*u/iResolution.y -vec2(1.8,1);    
    vec2 v;
    S(.5) S(-.5)

}
/**/



/*  // 208
#define L    v = .5- abs(v); f += 1e-2/min(v.x,v.y);

void mainImage( out vec4 f, vec2 u ) {
    f-=f;
    u = 2.*u/iResolution.y -vec2(1.8,1);    
    vec2 v;

         v = u+.25; L
         v = u-.25; L
         v = (u-vec2(.5,0))*mat2(2,0,-1,1); L
         v = (u+vec2(.5,0))*mat2(2,0,-1,1); L  
}
/**/
 
