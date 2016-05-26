// Shader downloaded from https://www.shadertoy.com/view/XdXXRS
// written by shadertoy user FabriceNeyret2
//
// Name: trochoids
// Description: Gerstner swell model: surface points displace along stationary circles -&gt; trochoidal wave
//    Mouse tune wavelengh (x) and amplitude (y).
//    (NB: Computing distance to displacement is not so easy... But I hate coslty iterative scheme ! :-p )
float L = .6,  		  // wavelength
	  A = .2,         // amplitude  
	  C = 1.;         // wave celerity = omega/K = 2PI/TK, with T = period

float t = iGlobalTime;
#define PI 3.1415927

// === distance to trochoid

float trochoid(vec2 uv, float A, float L, float C) {
	float K=6.28/L; // wave number
	
	// --- 1st, intersection with uv.y (or closest)
	float y = uv.y/A;
	if (abs(y)>1.) y /= abs(y);
	
	// solve for x :  y = Asin(phi) with phi = K(x-Ct)
	float phi = asin(y),
			x = phi/K+C*t,
		   x1 = x+A*cos(phi); // x+A*sqrt(1-y*y)
	
	// 2nd solution for asin
	phi = PI-phi;
	x = phi/K+C*t;
	float x2 =  x+A*cos(phi);
		
	// find branch closest to x,y
	x1 = uv.x-x1; 	x1 = min(mod(x1,L), mod(-x1,L));
	x2 = uv.x-x2; 	x2 = min(mod(x2,L), mod(-x2,L));
	x = min(x1,x2);
	if (x1<x2) phi = PI-phi;
	
	// --- 2nd, get the tangent line and find the closest sitance to uv
	vec2 dP = vec2( 1.-A*K*sin(phi), A*K*cos(phi) ); 
	y = A*y; // A*sin(phi)
	y = uv.y-y;
	vec2 P = vec2(x,y);
	float l = dot(P,dP)/dot(dP,dP);
	//float d = length(P-l*dP);

	// --- still ambiguous for horizontal tangent
	// accounting for curvature should fix it. 
	// here, we do half-way to avoid solving degree 3 polynomial
	vec2 d2P = -A*K*K* vec2( cos(phi), sin(phi) ); 
	float d = length(P-l*dP-l*l/10.*d2P);
	
	return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.9,.5));

	// --- tuning
	vec2 m = iMouse.xy/iResolution.xy;
	if (iMouse.z>0.) {
		L *= m.x; A *= m.y;
	}
	
	// === distance to trochoids
	float d;
	
	d =        trochoid(uv-vec2(0., .5), A,L   ,C);
	d = min(d, trochoid(uv-vec2(0., .0), A,L*2.,C));
	d = min(d, trochoid(uv-vec2(0.,-.5), A,L*4.,C));
	
	
  	float v = smoothstep(.01,0.,d);	
	
	fragColor = vec4(v);
}