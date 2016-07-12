// Shader downloaded from https://www.shadertoy.com/view/ltfSWr
// written by shadertoy user FabriceNeyret2
//
// Name: crowded coral
// Description: .


#define T .3*iGlobalTime
#define r(v,t) { float a = (t)*T, c=cos(a),s=sin(a); v*=mat2(c,s,-s,c); }
#define SQRT3_2  1.26
#define SQRT2_3  1.732
#define smin(a,b) (1./(1./(a)+1./(b)))

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const mat3 m = mat3( 0.00,  0.80,  0.60,
                       -0.80,  0.36, -0.48,
                     -0.60, -0.48,  0.64 );

float hash( float n ) {
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x ) { // in [0,1]
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.-2.*f);

    float n = p.x + p.y*57. + 113.*p.z;

    float res = mix(mix(mix( hash(n+  0.), hash(n+  1.),f.x),
                        mix( hash(n+ 57.), hash(n+ 58.),f.x),f.y),
                    mix(mix( hash(n+113.), hash(n+114.),f.x),
                        mix( hash(n+170.), hash(n+171.),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p ) { // in [0,1]
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of: Created by inigo quilez --------------------

// --- more noise

#define snoise(x) (2.*noise(x)-1.)

float sfbm( vec3 p ) { // in [-1,1]
    float f;
    f  = 0.5000*snoise( p ); p = m*p*2.02;
    f += 0.2500*snoise( p ); p = m*p*2.03;
    f += 0.1250*snoise( p ); p = m*p*2.01;
    f += 0.0625*snoise( p );
    return f;
}

#define sfbm3(p) vec3(sfbm(p), sfbm(p-127.67), sfbm(p+291.67))

// --- using the base ray-marcher of Trisomie21: https://www.shadertoy.com/view/4tfGRB#

vec4 bg = vec4(0,0,.3,0); // vec4(0,0,.4,0);

void mainImage( out vec4 f, vec2 w ) {
    vec4 p = vec4(w,0,1)/iResolution.yyxy-.5, d,c; p.x-=.4; // init ray
     r(p.xz,.13); r(p.yz,.2); r(p.xy,.1);   // camera rotations
    d = p;                                 // ray dir = ray0-vec3(0)
    p.z = 5.*T;
    vec2 mouse = iMouse.xy/iResolution.xy;
    float closest = 999.0;
    f = bg;
    float x1,x2,x3,l,x=1e9;
   
    for (float i=1.; i>0.; i-=.01)  {
       
         vec4 u = floor(p/8.), t = mod(p, 8.)-4., ta; // objects id + local frame
        // vec4 u = floor(p/vec4(8,8,1,1)+3.5),  t = p, ta,v;
      
        ta = abs(t);
        r(t.xy,u.x); r(t.xz,u.y); // r(t.yz,.1);    // objects rotations
        u = sin(78.*(u+u.yzxw));                    // randomize ids
        t -= 4.*u;                                  // jitter positions
        c = p/p*1.2;
        t.xyz += 1.*sfbm3(t.xyz/3.+vec3(-.9*T,0,0));
 
        l = length(mod(p.xyz, 8.)-4.)-2.9-u.z;
        t = abs(mod(t,.5)-.5/2.)-.01;
        x1 = max (t.x,t.y); x2 = max (t.y,t.z); x3 = max (t.x,t.z);
        x = min(x1,min(x2,x3));
        x = max(x,l);
         if (x<.01) c = mix(c,u,.1);
      
        if(x<.01) // hit !
            { f = mix(bg,c,i*i); break;  }  // color texture + black fog
       
        p += d*x;           // march ray
     }
     // f += vec4(1,0,0,0) * exp(-closest)*(.5+.5*cos(.5*T)); // thanks kuvkar !
}
