// Shader downloaded from https://www.shadertoy.com/view/Xl2XDW
// written by shadertoy user FabriceNeyret2
//
// Name: rainbow disk - 2
// Description: a variant of https://www.shadertoy.com/view/Xt2XDW
float C,S, t=(iGlobalTime-11.)/1e3;
#define rot(a) mat2(C=cos(a),S=-sin(a),-S,C)

void mainImage( out vec4 o, in vec2 u )
{
    o = vec4(0.0);
    vec2 R = iResolution.xy, p;
	u = 16.3*(u+u-R)/iResolution.y;
    
// #define B(k) ceil( (p=cos(u*=rot(t))).x * p.y )  * (.5+.5*cos(k))
   #define B(k) ceil( (p=cos(u*=rot(t))).x )  * (.5+.5*cos(k))
    
    for (float a=0.; a<6.3; a+=.1)
        o += vec4(B(a),B(a+2.1),B(a-2.1),1) / 31.;

}