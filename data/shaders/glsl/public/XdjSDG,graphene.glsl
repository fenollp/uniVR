// Shader downloaded from https://www.shadertoy.com/view/XdjSDG
// written by shadertoy user FabriceNeyret2
//
// Name: graphene
// Description: mouse controls camera.
//    If your graphics card allows, change LX,LY,LZ
// camera
vec3 pos    = vec3(0.,0.,-10.);
float zoom  = 2.;
vec3 up     = vec3(0.,1.,0.);
vec3 target = vec3(0.,0.,0.);

// lighting & materials
vec3 lum    = normalize(vec3(-.2,1.,-.5));
vec3 color  = vec3(1.,0.,0.);
vec3 amb   = .12*color;
vec3 diff  = .9*color;
vec3 spec  = vec3(1.);
float highlight = 100.;
float fog = 0.05;
vec3 fogColor = vec3(1.);

// shape
#define LX 2			// grid size
#define LY 2
#define LZ 0

#define radius 1.3      // spheroids size
#define D 3.1           // spheroids distance
#define thickness .8    // displacement amplitude
#define scale .3        // noise scale
#define chaos .75       // noise sharpness
#define NOISE_TYPE 1

// perfs/precision
#define range 20.       // max depth
#define NB 40           // for first guess
#define eps 0.001       // for dichotomy

#define time iGlobalTime

// --- noise functions inspired from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,  -0.80,  0.36, -0.48,   -0.60, -0.48,  0.64 );
float hash( float n ) {  // base rand in [0,1]; 
	return fract(sin(n-765.36334)*43758.5453);
}
float noise( in vec3 x ) { // base noise in [0,1]; 
    x += 2.*time*(1.,2.,1.);
    vec3 p = floor(x), f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
#if NOISE_TYPE==1
	return res;
#elif NOISE_TYPE==2
	return abs(2.*res-1.);
#elif NOISE_TYPE==3
	return 1.-abs(2.*res-1.);
#endif
}

float fbm( vec3 p ) { // turbulent (=fractal) noise in [-1,1]; 
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return 2.*f-1.;
}
// --- End of: Created by inigo quilez --------------------


// --- shapes construction --------------------------------------------------
// smooth sets: density = proba = 1 inside, 0 outside

float sphere(vec3 P,vec3 pos, float r) {
    float d = length(P-pos)-r;			       // signed distance to surface ( positive outside)
    return (1.-clamp(d/thickness,-1.,1.))/2.;  // density. blurry transition in a shell (thickness)
}
float inter(float d0, float d1) { return d0*d1; }     // smooth intersect operator
float add(float d0, float d1) { return d0+d1-d0*d1; } // smooth union operator

float f(vec3 P) { // signed distance to complex surface
#if 1
    float d=-1.;
    for (int k=-LZ; k<=LZ; k++)
      for (int j=-LY; j<=LY; j++)
        for (int i=-LX; i<=LX; i++) {
            float i0 = mod(float(i),2.); // hexa hole
            if (mod(float(j)-i0+1.,3.)==0.) continue;
            //vec3 pos = D*vec3(float(i),float(j),float(k)); // pos += .2*vec3(2.*noise(pos)-1.); // 4-grid
            vec3 pos = .89*D*vec3(float(i),2./sqrt(3.)*(float(j)+.5*i0),float(k));  // 6-grid
            pos.z += .2*(sin(length(pos.xy)+5.*time));
            float di = sphere(P,pos,radius); // one blob
            d = add(d,di); 					 // union of blobs
        }
    d=-d;
#else
	float d1 = .5-(length(P+vec3(.5*D,0.,0.))-radius)/thickness,
	      d2 = .5-(length(P-vec3(.5*D,0.,0.))-radius)/thickness,
           d =  .5- (d1+d2-d1*d2); d /= 2.;
    P += .3*iGlobalTime*(1.,2.,1.);
#endif
    if (abs(d)>chaos*scale) return d; // too far for noise change the sign -> saving
	return d + chaos*scale*fbm(P/scale);
}

// --- geometric functions --------------------------------------------------------------

float intersec(vec3 pos, vec3 ray, float t0) {
    float t1=t0,t2;  vec3 P1; float v1;
    // 1st, search for a point inside matter
    for (int i=0; i<=NB; i++) { 
       t0 = t1; 
       t1 = range*float(i)/float(NB); P1 = pos+t1*ray; v1 = f(P1);
       if (v1<0.) break;
    }
    // then, search the surface point by dichotomy
    vec3 P0 = pos+t0*ray; float v0 = f(P0);
    if (v0*v1>0.) return 0.;
    for(int i=0; i<NB; i++) {  // ( do-while not implemented )
    	t2 = (t0+t1)/2.; 
        vec3 P2 = pos+t2*ray; float v2 = f(P2);
    	if (v0*v2>0.) {t0=t2; v0=v2; P0=P2;} else {t1=t2; v1=v2; P1=P2; }
        if (abs(v2)<eps) return t2;
    }
    return t2;
}
vec3 get_N(vec3 P) {
    float v = f(P);
    float dfx = f(P+eps*vec3(1.,0.,0.))-v,
          dfy = f(P+eps*vec3(0.,1.,0.))-v,
          dfz = f(P+eps*vec3(0.,0.,1.))-v;
    return normalize(vec3(dfx,dfy,dfz));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) // --- scene ray-tracing -------------------------------------------------
{
    vec2 m = 2.*(iMouse.xy/iResolution.xy-vec2(.5,.5));
    if (iMouse.z <=0.) m=vec2(cos(.1*time),sin(.1*2.*time));
    vec2 angle = 3.1415*m;
    // --- set camera
    float c=cos(angle.x),s=sin(+angle.x); pos.xz = mat2(c,-s,s,c)*pos.xz;
          c=cos(angle.y),s=sin(-angle.y); pos.yz = mat2(c,-s,s,c)*pos.yz;
    mat3 cam;
    cam[0] = normalize(target-pos);
    cam[2] = normalize(up -dot(up,cam[0])*cam[0]);
    cam[1] = cross(cam[0],cam[2]);
    
	vec2 uv = 2.*(fragCoord.xy/iResolution.y-vec2(.9,.5));
    vec3 ray = normalize(cam*vec3(zoom,uv.x,uv.y)); float t=0.;
    vec3 col = vec3(0.); float trsp = 1.;
    
    // --- calc intersection and shading
    t = intersec(pos,ray,t);
    if (t>0.) {
        vec3 H = normalize(-cam[0]+lum);
        vec3 N = get_N(pos+t*ray);
        col = amb + diff*max(dot(N,lum),0.) + spec*pow(max(dot(N,H),0.),highlight);
    } else t=1e10;
    
    // --- compose final color
    trsp  = exp(-fog*t);
    col = (1.-trsp)*fogColor + trsp*col;
	fragColor = vec4(col,1.0);
}