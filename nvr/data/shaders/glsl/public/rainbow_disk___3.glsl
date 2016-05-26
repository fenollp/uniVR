// Shader downloaded from https://www.shadertoy.com/view/4l2XDW
// written by shadertoy user FabriceNeyret2
//
// Name: rainbow disk - 3
// Description: a variant of https://www.shadertoy.com/view/Xl2XDW
//    You can try the various commented versions,   or suppressing  &quot;ceil&quot;
float C,S, t=(iGlobalTime+15.)/1e3;
#define rot(a) mat2(C=cos(a),S=-sin(a),-S,C)

void mainImage( out vec4 o, in vec2 u )
{
    o = vec4(0.0);
    vec2 R = iResolution.xy, p;
	u = 16.3*(u+u-R)/iResolution.y;
    
// #define B(k) ceil( (p=cos(u*=rot(t))).x * p.y )  * (.5+.5*cos(k)) / 31.
// #define B(k) ceil( (p=cos(u*=rot(t))).x )        * (.5+.5*cos(k)) / 31.
   #define B(k) ceil( (p=cos(u*=rot(t))).x )        *     cos(k)     / 4.
// #define B(k) ceil( (p=cos(u=u*rot(t)+k)).x )     *     cos(k)     / 6.
   
    for (float a=0.; a<6.3; a+=.1)
        o += vec4( B(a), B(a+2.1), B(a-2.1), 1) ;

}