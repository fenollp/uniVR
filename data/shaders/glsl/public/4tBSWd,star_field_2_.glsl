// Shader downloaded from https://www.shadertoy.com/view/4tBSWd
// written by shadertoy user FabriceNeyret2
//
// Name: star field 2 
// Description: Test for shorter starfield. This one is based on texture advection.
//    I'm sure it's possible to do nicer + shorter ;-)
// Test for shorter starfield. 
// This one is based on texture advection and image-based stars.
// see also https://www.shadertoy.com/results?query=starfield&sort=newest


float D=8., Z=3.;               // D: duration of advection layers, Z: zoom factor

#define M(U,t) 1.3*length( texture2D(iChannel0, U/exp2(t) ) - .5 )
                                //  variant: U/exp2(t)+P.x, to randomise more the layers
    
void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
    U = U / iResolution.xy - .5;

    // --- prepare the timings and weightings of the 3  texture layers

    vec3 P = vec3(-1,0,1)/3., T,
         t = fract( iGlobalTime/D + P +.5 )-.5,  // layer time
         w = .5+.5*cos(6.28*t);                  // layer weight
    t = t*D+Z;  
    
    // --- prepare the 3 texture layers

    T.x = M(U,t.x),  T.y = M(-U,t.y),  T.z = M(U.yx,t.z); // avoid using same U for all layers
    //T = sin(100.*U.x/exp2(t3))+sin(100.*U.y/exp2(t3));  // try this for obvious pattern
    T = smoothstep(.9,1.,T);    // try without this to see base noise (and play with D)
    
    // --- texture advection: cyclical weighted  sum

    o += dot(w,T);
    // o.rgb = w*T;             // try this alternative to see the 3 layers of texture advection
}