// Shader downloaded from https://www.shadertoy.com/view/Md3XW8
// written by shadertoy user FabriceNeyret2
//
// Name: one pyramid challenge   (277)
// Description: paradoxically, seems that one needs more chars to draw a pyramid than a cube. or not ? :-)
//     from cube version : https://www.shadertoy.com/view/Xs33RH
//    
// adapted from the cube version : https://www.shadertoy.com/view/Xs33RH

                                              // draw segment [a,b]
#define L  ; o+= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a );
#define P  ; b=c= vec2(r.x,-1)/(4.+r.y) L b=vec2(0,.4) L  a=c; r*= -mat2(.5,.87,-.87,.5);


void mainImage(out vec4 o, vec2 v)
{
	vec2 a = vec2(1,-1), b,c=iResolution.xy, 
         u = (v+v-c)/c.y,
         r = sin(iDate.w-.8*a); r += a*r.yx  
    P  o-=o        // just to initialize a
	P P P          // 3*3 segments

}