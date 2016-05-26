// Shader downloaded from https://www.shadertoy.com/view/ls2GWc
// written by shadertoy user FabriceNeyret2
//
// Name: disparity4
// Description: C: toggles greyscale vs colors
//    G: toggles grid vs dots
//    D: toggles deformations vs displacement
//    S: toggles stereo (horiz displ only) vs radial disp
//    M: mark central dots
//    SPACE: toggles mouse tune center or color
//    #define NB : number of dots vertically
float t = iGlobalTime;
const float PI=3.1415927;

#define NB 40.    // 25.
#define radius .3 // .4   max: 0.5

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

// === draw a circle (p,r) ===

float circle(vec2 p, float r) {
	
	if (keyToggle(71)) { p = p/r - 1.; r = p.x*p.y;	} 
	else			     r = length(p)/r - 1.;

	return step(0.,r);
	// return smoothstep(-.03,.03,r);
}

// === defines distortion ===

#define POLYNOMIAL 1
#if POLYNOMIAL
//const float P0=0.,P01=1.,P02=-1.; // P=x-x² (0,0) / (.5,1/4) \ (1,0)
	const float P0=0.,P01=-0.5,P02=0.5;
	const float R=.5;	// resize the curve to [0,R]
	float F(float x) { return P0 + (P01/R)*x + (P02/(R*R))*x*x; }
#else
	const float R=PI/4.;
	float F(float x) { return .25*sin(-4.*x); }
#endif

// === scalar direct and reverse transforms ===

float f(float x) {
	float sx= sign(x), ax = abs(x); // We force odd symmetry => P0=0
	if (ax > R) return x;
	float dx = F(ax);
	return x + sx*dx; 
}

float invf(float x) {
	float sx= sign(x), ax = abs(x); // We force odd symmetry => P0=0
	if (ax > R) return x;

#if POLYNOMIAL
	// resize the curve to [0,R]
# if 0
	float B =.5*(1.+(P01/R))*(R*R/P02); // a=1, b/2, c
	float C =  (P0-ax)   *(R*R/P02);
	return sx*(-B + sign(B)*sqrt(B*B-C));  // -b' +- sqrt(b'2-c)
# else
	float B = .5*(1.+ (P01/R))*(R*R/P02) + ax; // a=1, -b/2, c
	float C = (P0 +ax*(P01/R))*(R*R/P02) + ax*ax;
	float dx = B - sign(B)*sqrt(B*B-C);  // -b' +- sqrt(b'2-c)
	return x - sx*dx;
# endif
#endif
}

// === vectorial direct and reverse transforms ===

vec2 disp(vec2 p, vec2 c) { // distorsion centre c size r
	float l=length(p-c);
	if (keyToggle(83)) // horizontal displacement only 
		return c + (p-c)/l*vec2(f(l),l);
	else
		return c + (p-c)/l*f(l); // radial displacement
}
vec2 invdisp(vec2 p, vec2 c) { // inverse distorsion
	float l=length(p-c);
	if (keyToggle(83))   // horizontal displacement only 
		return c + (p-c)/l*vec2(invf(l),l);
	else
		return c + (p-c)/l*invf(l); // radial displacement
}

/// === draw a distorted pattern ===

float stiples(vec2 p, vec2 center, float n) {
	vec2 c, p2 = disp(p,center); 
	n *= .5;               // because domain range = [-1,1]
	p2 = n*p2+.5;
	if (keyToggle(68)) { // --- distorsion mode --- 
	    p2 = fract(p2)/n; // pos relative to a tile
	    c = vec2(.5/n);     
	} else {             // --- displacement mode --- 
		c = floor(p2)/n;
		c = invdisp(c,center);
		p2 = p;
	}
//  return texture2D(iChannel0,.5*(1.+p2)).r;

	
	return circle(p2-c,radius/n);
}

// === main loop ===

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = 2.*(fragCoord.xy/iResolution.y - vec2(.9,.5));
	vec2 center = vec2(0.);
	vec4 m = iMouse/iResolution.y;
	if (!keyToggle(32)) {
		if (m.x+m.y==0.) m.xy = vec2(.9001,.5);
		center = 2.*(m.xy- vec2(.9,.5));
		m.xy = vec2(0.);
	}
	if ((m.z<0.) || (m.x+m.y==0.)) m.y=.8;
	
	float v; vec3 col;
#if 1
	v = stiples(uv,center,NB);
	bool grey=keyToggle(67);
	if (keyToggle(77) && (floor(.25*NB*disp(uv,center) +.25)/NB==vec2(0.)))
		grey = !grey;
	
	if (grey) col = vec3(v);
	else	  col = mix(vec3(1.,0.,0.),m.y*vec3(0.,1.,0.),v);
#else  // --- display control curves
	v =      f(uv.x )-uv.y; col.r = smoothstep(.03,-.03,abs(v));
	v =   invf(uv.x) -uv.y; col.g = smoothstep(.03,-.03,abs(v));
	v = f(invf(uv.x))-uv.y; col.b = smoothstep(.03,-.03,abs(v));
#endif	
	
	fragColor = vec4(col, 1.);
}