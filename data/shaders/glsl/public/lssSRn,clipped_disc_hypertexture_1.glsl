// Shader downloaded from https://www.shadertoy.com/view/lssSRn
// written by shadertoy user FabriceNeyret2
//
// Name: clipped disc hypertexture 1
// Description: hypertexture (here, sphere clipped by plane) with well controlled thickness, i.e., noise saturating the &quot;skin&quot; range.
//    mouse.x tune noise layer thickness
//    mouse.y tune noise bluriness
//    See #define for more tunings
#define GAIN 1.6 // >1 is unsafe, but up to 2 still looks ok (noise don t sature dynamics)
#define NOISE 1 // 1: linear  2: blobby (abs)  3:  hairy (1-abs)

// --- scene    ( screen = [-1.8, 1.8] x [-1, 1] )

vec2 sphere1Pos = vec2(0.,0.);
float sphere1Rad = .7;         // sphere radius

float planePos = .1;

vec2 sphere2Pos = vec2(1.,0.);
float sphere2Rad = .2;         

// cloud appearance (superseeded by mouse tuning)

float H = .2;                 // skin layer thickness ( % of normalized sphere)
float sharp = 0.3;            // cloud sharness (0= ultra sharp ).



#define ANIM 1         // 1/0
#if ANIM
   float t = iGlobalTime;
#else
  float t = 0.; 
#endif

#define PI 3.14159

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )  // base rand in [0,1]; 
{
    return fract(sin(n-765.36334)*43758.5453);
    //return -1.+2.*fract(sin(n-765.36334)*43758.5453);
}

float noise( in vec3 x ) // base noise in [0,1]; 
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
#if NOISE==1
	return res;
#elif NOISE==2
	return abs(2.*res-1.);
#elif NOISE==3
	return 1.-abs(2.*res-1.);
#endif
}

float fbm( vec3 p ) // turbulent (=fractal) noise in [0,1]; 
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of: Created by inigo quilez --------------------



// smooth distance to sphere = [-1,1] around radius +- thickness H

float sphere(vec2 uv, vec2 spherePos, float sphereRad)
{
	vec2 p = (uv-spherePos)/sphereRad; // pos in sphere normalized coordinates
	float d = (1.-length(p))/H;  
	return clamp(d,-1.,1.);
}
		
// smooth distance to plane = [-1,1] around plane +- thickness H

float plane(vec2 uv, float planePos, float planeRad) // planeRad to share normalization with spheres
{
	vec2 p = uv-vec2(planePos,0.); // pos in sphere normalized coordinates
	float d = -p.x/(H*planeRad);  
	return clamp(d,-1.,1.);
}
	
// smooth intersect operator

float inter(float d0, float d1) {
	d0 = (1.+d0)/2.;    	 //   [-1,1] -> [0,1], mul,  [0,1] -> [-1,1]
	d1 = (1.+d1)/2.;
	return 2.*d0*d1 -1.;
}

// smooth union operator

float add(float d0, float d1) {
	d0 = (1.+d0)/2.;     	//   [-1,1] -> [0,1], add,  [0,1] -> [-1,1]
	d1 = (1.+d1)/2.;
	return 2.*(d0+d1-d0*d1) -1.;
}

// jitter the distance around 0  and smoothclamp

float perturb(vec2 p, float d, float H) {
    //float fillfactor=0.; d = (d+1.)*fillfactor-1.;
	if (d<=-1.) return -1.;  			// exterior
	if (d>= 1.) return 1.;   			// interior (1 when H% inside radius )
	
	float n = 2.*fbm(vec3(p/H,t)) -1.;  // perturbation in [-1,1]
	return  2.*(d + GAIN*n);   			// still in [-1,1] :-)
}

// convert [-1,1] distances into densities

float dist2dens(float d) {  	// transition around zero. Tunable sharpness
	return smoothstep(-sharp,sharp,d);
}


// user-define shape
	
float shape(vec2 uv,float n) {
	
	float v1 = sphere(uv, sphere1Pos, sphere1Rad),
		  v2 = plane (uv, planePos,   sphere1Rad), // share normalization radius
		  v3 = sphere(uv, sphere2Pos, sphere2Rad);
	float v;

#define globalNoise false
	
	if (globalNoise || (n==0.)) {
		v = add( inter(v1,v2), v3 );               // we combine smooth distances *then* perturbate
		if (n>0.) v = perturb(uv, v,H*sphere1Rad);
	}
	else {
		v = perturb(uv, inter(v1,v2), H*sphere1Rad); // we perturbate (with different coefs) *then* combine
		v = add( v, perturb(uv, v3 , H*sphere2Rad));
	}
	
	return v;
}

// main loop

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.* (fragCoord.xy / iResolution.y - vec2(.8,.5) );
	if (iMouse.z>0.) {       				   // mouse tuning
		vec2 m = iMouse.xy / iResolution.xy;
		H = m.x+1e-5 ; sharp = m.y+1e-5; 
	}

	float v = dist2dens( shape(uv,1.) ); 
	vec3 col = vec3(v);
	
	if (uv.y<0.) {                   	 // bottom half scren: display bounds
		
		sharp = 1e-5; // no noise for bounds
		float d = shape(uv,0.), dv = fwidth(d);
		
		v = dist2dens(d-0.99+dv)-dist2dens(d-0.99); // inner bound : draw on top
		col = mix(col, vec3(v,0.,0.),v);	
		
		v = dist2dens(d+.5*dv)-dist2dens(d-.5*dv);  // mid-bound: draw on top
		col = mix(col, vec3(0.,v,0.),v);
		
		v = dist2dens(d+.99)-dist2dens(d+0.99-dv);  // exterior bound : draw below
		float alpha = max(col.r,col.g);
		col = mix(vec3(0.,0.,v),col, alpha);	
		alpha = max(col.b,alpha);
		
		v = dist2dens(sphere(uv, sphere1Pos, sphere1Rad)+.99); // sphere without plane clipping
		col = mix(v*vec3(0.,0.,.3),col, alpha);	
	}
	
    fragColor = vec4(col,0.); 
}
