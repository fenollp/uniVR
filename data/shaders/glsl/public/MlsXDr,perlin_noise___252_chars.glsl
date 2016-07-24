// Shader downloaded from https://www.shadertoy.com/view/MlsXDr
// written by shadertoy user FabriceNeyret2
//
// Name: perlin noise - 252 chars
// Description: quadrilin perlin noise :252 chars 
//    cubic perlin noise : 269 chars    &lt;-  Yes, the full equivalent of iq turbulent perlin noise. :-)
//    quadrilin perlin noise + transform : 273 chars
//    
// quadrilin: 252 cubic:269   + 21 for noise transform

#define h(n) fract(sin(n+vec2(0,157))*57.) 
#define N m=fract(u*s); l=dot(u*s-m,vec2(1,157));s+=s; m*=m*(3.-m-m); r= mix(h(l),h(++l),m.x); f+= mix(r.x,r.y,m.y)/s;
//#define N m=fract(u); l=dot(u-m,vec2(1,157)); u*=mat2( 4,-3,3,4)*.4;s+=s; m*=m*(3.-m-m); r= mix(h(l),h(++l),m.x); f+= mix(r.x,r.y,m.y)/s;

void mainImage( out vec4 f, vec2 u ) {
    u = 8.*u/iResolution.y-vec2(7,4);   
    vec2 m,r; float l,s=1.;
    N N N N 
        
// --- comment all below for brute noise, or chose your noise transform :
    f = sin(f*20.+iDate.w);
    //f = sin(f+f+iDate.w+u.xyyy);  // try u.xyyy *  .1 to 1.
    //f = sin(f*u.xyyy*4.+iDate.w);
}


// -------------------------------------------------------------------------------

/* // 255
vec2 m,r;
float l;

#define h(n) fract(sin(n+vec2(0,157))*57.) 


#define N m=fract(u); l=dot(u-m,vec2(1,157)); u+=u; m*=m*(3.-m-m); r= mix(h(l),h(++l),m.x); f+= mix(r.x,r.y,m.y)

void mainImage( inout vec4 f, vec2 u ) {
    u = 8.*u/iResolution.y-vec2(7,4);    
    N/2.; N/4.; N/8.; N/16.; // fbm   
}
*/




/* // 280
vec2 p,m,r;

float N() {
    m = fract(p);
    float l = dot(p-m,vec2(1,157));  // why p-(p=fract(p)) not working ?
 // p *= mat2( 8, -6, 6, 8 )*.2; // if you really want bands rotation
    p +=p;
    m *= m*(3.-m-m);  // -14 chars without cubic interpolation
#define h(n) fract(sin(n+vec2(0,157))*57.) 
    r = mix( h(l), h(++l),m.x);
    return mix(r.x,r.y,m.y);
}

void mainImage( inout vec4 f, vec2 u ) {
    u = 2.*u/iResolution.y-vec2(1.8,1);  
   
    p = 4.*u ;
    f += .5*( N() + N()/2. + N()/4. + N()/8. ); // 2*fbm
   
}
*/