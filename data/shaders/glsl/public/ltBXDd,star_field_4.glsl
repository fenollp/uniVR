// Shader downloaded from https://www.shadertoy.com/view/ltBXDd
// written by shadertoy user FabriceNeyret2
//
// Name: star field 4
// Description: Test for shorter starfield. This one is based on texture advection + quadtree + procedural stars (indeed, it is an infinite zoom. or perspective, depending on lines #10-11).
//    I'm sure it's possible to do nicer + shorter ;-)
// Test for shorter starfield. 
// see also https://www.shadertoy.com/results?query=starfield&sort=newest
// This one is based on texture advection, quadtree and procedural stars.

float D=8., Z=3.;               // D: duration of advection layers, Z: zoom factor

#define R(U,d) fract( 1e4* sin( U*mat2(1234,-53,457,-17)+d ) )

float M(vec2 U, float t) {           // --- texture layer
// vec2 iU = ceil(U/=exp2(t-8.)),              // quadtree cell Id - infinite zoom
   vec2 iU = ceil(U/=exp2(t-8.)*D/(3.+t)),     // quadtree cell Id - with perspective
          P = .2+.6*R(iU,0.);                  // 1 star position per cell
    float r = 9.* R(iU,1.).x;                  // radius + proba of star ( = P(r<1) )
	return r > 1. ? 1. :   length( P - fract(U) ) * 8./(1.+5.*r) ;
}

void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0);
    U = U / iResolution.y - .5;

    // --- prepare the timings and weightings of the 3  texture layers

    vec3 P = vec3(-1,0,1)/3., T,
         t = fract( iGlobalTime/D + P +.5 )-.5,  // layer time
         w = .5+.5*cos(6.28*t);                  // layer weight
    t = t*D+Z;  
    
    // --- prepare the 3 texture layers

    T.x = M(U,t.x),  T.y = M(-U,t.y),  T.z = M(U.yx,t.z); // avoid using same U for all layers
    //T = sin(100.*U.x/exp2(t3))+sin(100.*U.y/exp2(t3));  // try this for obvious pattern
    T = .03/(T*T);

    // --- texture advection: cyclical weighted  sum

    o += dot(w,T);
    // o.rgb = w*T;             // try this alternative to see the 3 layers of texture advection
}