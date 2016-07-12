// Shader downloaded from https://www.shadertoy.com/view/ltjXWW
// written by shadertoy user FabriceNeyret2
//
// Name: infinite fall - short
// Description: compact version of https://www.shadertoy.com/view/4sl3RX (with less goodies)
//    
//    NB: comment line #26 for simple zoom noise without bump shading.
// compact version of https://www.shadertoy.com/view/4sl3RX 
// --- infinite fall --- Fabrice NEYRET  august 2013


#define L  20.
#define R(a) mat2(C=cos(a),S=sin(a),-S,C)
float C,S,v, t = 1.5*iGlobalTime;

float N(vec2 u) { // infinite perlin noise
	mat2 M = R(1.7);
    C = S = 0.;
	for (float i=0.; i<L; i++)
	{   float k = i-t,
		      a = 1.-cos(6.28*k/L),
		      s = exp2(mod(k,L));
		C += a/s* ( 1. - abs( 2.* texture2D(iChannel0, M*u*s/1e3 ).r - 1.) ); 
		S += a/s;  M *= M;
	}
    return 1.5*C/S;
}

void mainImage( out vec4 o, vec2 u ) {
	vec2 r = iResolution.xy, e=vec2(.004,0);
 	v = N( u = (u-.5*r) / r.y * R(t) );
	o =   v*v*v/vec4(1,2,4,1) 
        * min( 1., 51.*N(u+e) + 205.*N(u+e.yx) -256.*v ) // lum
;
}