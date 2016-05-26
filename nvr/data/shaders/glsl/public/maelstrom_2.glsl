// Shader downloaded from https://www.shadertoy.com/view/XtfSzn
// written by shadertoy user FabriceNeyret2
//
// Name: maelstrom 2
// Description: .

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

vec2 sfbm2( vec3 p ) {
    return 2.*vec2(fbm(p),fbm(p-327.67))-1.;
}

    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    vec2 mouse = iMouse.xy / iResolution.xy;
    if (iMouse.z<0.) 
         mouse = vec2(.9,.5)*vec2(cos(1.*t)+.5*sin(2.2*t),sin(1.1*t)+.5*cos(1.9*t))/1.5;   
    else 
            mouse = 2.*mouse-1.;
	vec2 uv = 2.*(fragCoord.xy / iResolution.y-vec2(.9,.5));
    float a = .5*t, c=cos(a), s=sin(a); uv *= mat2(c,-s,s,c);
    
    vec4 col=vec4(0.);
    vec3 paint = vec3(1.,.3,.1); // vec3(.3,.9,.7);
    
    for(float z=0.; z<1.; z+= 1./60.) {
        vec3 p = vec3(4.2*uv,3.*z-t);
        vec2 duv = vec2(.8,.5)*sfbm2(p) - 3.*z*mouse;
    	float d = abs(length(uv+duv)-2.1*(1.-z)),
              a = smoothstep(.2,.19,d); 
        d = a;//-.3*smoothstep(.18,.17,d)+.3*smoothstep(.02,.01,d);
        //float b = 2.*fbm(p)-1.; paint = vec3(.7+.3*b,.3+.3*b,.1);
        float b = fbm(.5*p); paint = 1.-vec3(0.,.7*b,b);
        col += (1.-col.a)*vec4(d*paint*exp(-3.*z),a);
        if (col.a>=.9) break;
    }
	fragColor = col;
}