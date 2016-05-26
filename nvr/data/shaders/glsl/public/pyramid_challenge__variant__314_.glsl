// Shader downloaded from https://www.shadertoy.com/view/ls3SD8
// written by shadertoy user FabriceNeyret2
//
// Name: pyramid challenge -variant (314)
// Description: variant of https://www.shadertoy.com/view/Md3XW8 following  https://www.shadertoy.com/view/Mdc3zH 
// variant of simple pyramid https://www.shadertoy.com/view/Md3XW8 
// adapted from the cube version : https://www.shadertoy.com/view/Xs33RH
//                 and its variant https://www.shadertoy.com/view/Mdc3zH

                                              // draw segment [a,b]
#define D(m) 3e-3/length( m.x*v - u+a )
#define L  ; m.x = dot(u-a,v=b-a)/dot(v,v); o.z += D(m); o += D(clamp(m,0.,1.));
#define P  ; b=c= vec2(r.x,-1)/(4.+r.y) L b=vec2(0,.4) L  a=c; r*= -mat2(.5,.87,-.87,.5);


void mainImage(out vec4 o, vec2 v)
{
	vec2 a = vec2(1,-1), b,c=iResolution.xy, m,
         u = (v+v-c)/c.y,
         r = sin(iDate.w-.8*a); r += a*r.yx  
    P  o-=o        // just to initialize a
	P P P          // 3*3 segments

}