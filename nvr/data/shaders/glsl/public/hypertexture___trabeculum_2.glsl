// Shader downloaded from https://www.shadertoy.com/view/MlB3Wt
// written by shadertoy user FabriceNeyret2
//
// Name: hypertexture - trabeculum 2
// Description: Trabeculum pattern. (camera follow mouse).
//    
//    ( a variant from https://www.shadertoy.com/view/ltj3Dc )
// a variant from https://www.shadertoy.com/view/ltj3Dc

#define SHADED 0
#define FOG 0
#define NOISE 3 // Perlin, Worley, Trabeculum
#define VARIANT 2

const vec3 skyColor = 0.*vec3(.7,.8,1.); const float skyTrsp = .5;
const vec3 sunColor = vec3(1.,.7,.1)*10.;   
const vec3 lightDir = vec3(.94,.24,.24); // normalize(vec3(.8,.2,-.2));
const vec3 ambient  = vec3(.2,0.,0.), 
           diffuse  = vec3(.8);

#define PI 3.14159

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

// more 3D noise
vec3 hash13( float n ) {
    return fract(sin(n+vec3(0.,12.345,124))*43758.5453);
}
float hash31( vec3 n ) {
    return hash(n.x+10.*n.y+100.*n.z);
}
vec3 hash33( vec3 n ) {
    return hash13(n.x+10.*n.y+100.*n.z);
}

vec4 worley( vec3 p ) {
    vec4 d = vec4(1e15);
    vec3 ip = floor(p);
    for (float i=-1.; i<2.; i++)
   	 	for (float j=-1.; j<2.; j++)
            for (float k=-1.; k<2.; k++) {
                vec3 p0 = ip+vec3(i,j,k),
                      c = hash33(p0)+p0-p;
                float d0 = dot(c,c);
                if      (d0<d.x) { d.yzw=d.xyz; d.x=d0; }
                else if (d0<d.y) { d.zw =d.yz ; d.y=d0; }
                else if (d0<d.z) { d.w  =d.z  ; d.z=d0; }
                else if (d0<d.w) {              d.w=d0; }   
            }
    return sqrt(d);
}


float grad=.2/2., scale = 5., thresh=.5; // default value possibly overloaded below.

// my noise
float tweaknoise( vec3 p , bool step) {
    float d1 = smoothstep(grad/2.,-grad/2.,length(p)-.5),
          d2 = smoothstep(grad/1.,-grad/1.,abs(p.z)-.5),
          d=d1;
#if NOISE==1 // 3D Perlin noise
    float v = fbm(scale*p);
#elif NOISE==2 // Worley noise
    float v = (.9-scale*worley(scale*p).x);
#elif NOISE>=3 // trabeculum 3D
  #if VARIANT==0
    d = (1.-d1)*d2; 
  #elif VARIANT==2
    d=d2;
  #endif
    if (d<0.5) return 0.;
    grad=.8, scale = 10., thresh=.5+.5*(cos(.5*iGlobalTime)+.36*cos(.5*3.*iGlobalTime))/1.36;
    vec4 w=scale*worley(scale*p-vec3(0.,0.,3.*iGlobalTime)); 
    float v=1.-1./(1./(w.z-w.x)+1./(w.a-w.x)); // formula (c) Fabrice NEYRET - BSD3:mention author.
#endif
    
    return (true)? smoothstep(thresh-grad/2.,thresh+grad/2.,v*d) : v*d;
}

// Cheap computation of normals+Lambert using directional derivative (see https://www.shadertoy.com/view/Xl23Wy )
// still, we need an estimate of slope amplitude to avoid artifacts (see grad+scale).
float shadedNormal( vec3 p, float v ) {
    float epsL = 0.01;
#if 1// centered directional derivative
    float dx = (tweaknoise(p+epsL*lightDir,false)-tweaknoise(p-epsL*lightDir,false))/(2.*epsL);
#else // cheap directional derivative
    float dx = (tweaknoise(p+epsL*lightDir,false)-v)/epsL;
#endif
    return clamp(-dx*grad/scale/v, 0.,1.); // Lambert shading
    
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // if (max(fragCoord.x,fragCoord.y)/iResolution.y<.05) 
    // { fragColor = vec4(ambient,1.); return; }
    
    vec2 mouse=iMouse.xy/iResolution.xy;
    if (mouse.x+mouse.y==0.) mouse.xy=vec2(0.5);

    //camera
    float theta = (mouse.x*2. - 1.)*PI;
    float phi = (mouse.y - .5)*PI;
#if 1 // camera shake 
    float t=3.*iGlobalTime,B=.07; theta += B*cos(t); phi += B*sin(t);
#endif
    vec3 cameraPos =vec3(sin(theta)*cos(phi),sin(phi),cos(theta)*cos(phi));   
    vec3 cameraTarget = vec3(0.);
    vec3 ww = normalize( cameraPos - cameraTarget );
    vec3 uu = normalize(cross( vec3(0.,1.,0.), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec2 q = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5));
    vec3 rayDir = normalize( q.x*uu + q.y*vv -1.5*ww );
  
    // ray-trace volume
    vec3 col=vec3(0.);
 	float transp=1., epsC=.01/2.;
    float l = .5;
    vec3 p=cameraPos+l*rayDir, p_=p;
    
    for (int i=0; i<200; i++) { 
        float Aloc = tweaknoise(p,true); // density field
        if (Aloc>0.01) {
            
#if FOG 
	      	float fog = pow(skyTrsp,length(p_-p)); p_=p;
            col += transp*skyColor*(1.-fog);
    	    transp *= fog; 
            if (transp<.001) break;
#endif            

#if SHADED          
            vec3 c = ambient+diffuse*shadedNormal(p,Aloc);
#else
            float a = 2.*PI*float(i)/200.; vec3 c = .5+.5*cos(a+vec3(0.,2.*PI/3.,-2.*PI/3.)+iGlobalTime);
#endif
 	        col += transp*c*Aloc;
            //if (c.r>1.) { fragColor = vec4(0.,0.,1.,1.); return; }
            col = clamp(col,0.,1.); // anomaly :-(
    	    transp *= 1.-Aloc;
	        if (transp<.001) break;
        }
 
        p += epsC*rayDir;
    }
    
   fragColor = vec4(col+ transp*skyColor, 1.);
}