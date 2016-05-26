// Shader downloaded from https://www.shadertoy.com/view/Xdt3D8
// written by shadertoy user FabriceNeyret2
//
// Name: hexagonal truchet ( 408 )
// Description: optimisation of hexagonal truchet
// inspired from https://www.shadertoy.com/view/4d2GzV#
// and https://www.shadertoy.com/view/4dS3Dc
// still longer than the 2D version /-) https://www.shadertoy.com/view/lst3R7

vec2 H(vec2 p) {                   // closestHexCenters(p)
	vec2  f = fract(p);  p -= f;
	float v = fract((p.x + p.y)/3.);
    return  v<.6 ?   v<.3 ?  p  :  ++p  :  p + step(f.yx,f) ; 
}

void mainImage( out vec4 o,  vec2 p ) {
	
	vec2  R = iResolution.xy, h; 
    float Z = 10./R.y;
		
    p = (p - .5*R)*Z - 9.*sin(.1*iGlobalTime+vec2(1.6,0));  // demo referential

    // NB: M^-1.H(M.p) converts back and forth to hex grid, which is mostly a tilted square grid
	h = H( p+ vec2(.58,.15)*p.y ); // closestHex( mat2(1,0, .58, 1.15)*p ); // 1/sqrt(3), 2/sqrt(3)
	p -=   h- vec2(.5, .13)*h.y;   // p -= mat2(1,0,-.5, .87) * h;          // -1/2, sqrt(3)/2
    
	float // s = sign( texture2D(iChannel0, fract(h/9.)).x -.5 ), 
          // s = sign( fract(1e5*cos(h.x+9.*h.y)) -.5 ), 
             s = sign( cos(1e5*cos(h.x+9.*h.y)) ),   // rnd (tile) = -1 or 1
        
#define L(x,y)  length( p - s*vec2(x,y) )            // dist to neighbor 1,3,5 or 2,4,6
//#define L(a)  length( p - s*sin(a+vec2(1.57,0)) )  // variant L(0), L(2.1), L(-2.1)
	      l = min(min(L(-1, 0  ),                    // closest neigthborh (even or odd set, dep. s)
					  L(.5, .87)),                   // 1/2, sqrt(3)/2
				      L(.5,-.87));

    o -=o-- -.2 / abs(l-.5);
 // o -=o- smoothstep(.1+Z, .1, abs(l-.5));              // precise anti-aliasing
 // o -=o- cos(l*25.1);                                  // nice variant 1 by Shane
 // o -=o- vec4(sqrt(2.*cos(vec3(1, 3, 3)*l*6.28)), 1.); // nice variant 2 by Shane
}
