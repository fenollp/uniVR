// Shader downloaded from https://www.shadertoy.com/view/ldcSD8
// written by shadertoy user FabriceNeyret2
//
// Name: hexa prism (288 chars)
// Description: variant from the pyramide https://www.shadertoy.com/view/Md3XW8 
//     and cube version : https://www.shadertoy.com/view/Xs33RH
// adapted from the pyramide https://www.shadertoy.com/view/Md3XW8 
// and cube version : https://www.shadertoy.com/view/Xs33RH

                                              // draw segment [a,b]
#define L  *I; o-= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a );
#define P  ; b=c= vec2(r.x,-1)/(4.+r.y) L b=a L  a=c;  a=c L a=c; r*= mat2(.5,.87,-.87,.5);


void mainImage(out vec4 o, vec2 v)
{
	vec2  I=vec2(1,-1), a, b,c=iResolution.xy, 
         u = (v+v-c)/c.y,
         r = sin(iDate.w-.8*I); r += I*r.yx  
    P  o-=o++        // just to initialize a
	P P P P P P          // 3*3 segments  
}