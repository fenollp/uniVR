// Shader downloaded from https://www.shadertoy.com/view/MtSSDG
// written by shadertoy user FabriceNeyret2
//
// Name: inverse trochoids
// Description: Trochoid wave curve is parametric (x(),y()), while in a shader we need a &quot;procedural&quot; form y(x).
//    NB: yMouse tunes the amplitude.
// Trochoid : ( x(), y() ) = ( x0+A.cos(x0-t) , A.sin(x0-t) )
// problem: we want y(x).

float A,  t=iGlobalTime; 
vec2 R = iResolution.xy;

#define C(x)   A*cos(x-t)    // indeed, x-t should be k.(x-c.t)
#define S(x)   A*sin(x-t)
#define X0(x,xx)  x-C(xx)

float trochoid(float x, float t) {
// solve x = x0 + A.cos(x0-t) for x0
//  as  x = x_i+1 + A.cos(x_i-t) ; x_0 = x
// then apply y = A.sin(x0-t)
// see more here: https://www.desmos.com/calculator/r0uowdkejy
    return S(X0(x,X0(x,X0(x,X0(x,X0(x,x))))));
}

#define plot(Y) o += smoothstep(40./R.y, 0., abs(Y-uv.y))
// #define plot(Y) o +=exp(-max(0.,Y-uv.y))

void mainImage( out vec4 o, vec2 uv )
{
    o = vec4(0.0);
    uv = 10.* (2.*uv-R)/R.y; 
    A = iMouse.y<=0. ? sin(t) : iMouse.y/R.y;
    
    
	plot(  trochoid(uv.x, t) + 4.); // positive trochoid (gravity wave) 
	plot( -trochoid(uv.x, t) - 4.); // negative trochoid (capillary wave)
    
    // approximations based on jt idea : 
    // plot( -2.* exp( - abs(sin(0.5 *( uv.x - t - 1.57))))   - 4.5);
    // plot( - exp( sin(uv.x -  t ) )      -6.);
 
    o.b += .2;
}