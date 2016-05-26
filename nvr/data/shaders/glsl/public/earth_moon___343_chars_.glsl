// Shader downloaded from https://www.shadertoy.com/view/XdtSzl
// written by shadertoy user FabriceNeyret2
//
// Name: Earth+Moon  (343 chars)
// Description: .
#define P(T,V,C0,C1,v) ( W = asin(V), W.x = acos((V).x/cos(W.y))-iGlobalTime*v, mix(C0,C1,step(texture2D(T,.5+.5*W).x,.5+.5*(V).x))*vec4(dot(V,V)<1.))


void mainImage( out vec4 O, vec2 U )
{
    U /= iResolution.y; vec2 W;
    O =             P(iChannel1, .8*(U-vec2(1.4,-.38)), vec4(0,0,.8,1) ,vec4(1),        .5);
    O += (1.-O.w)*  P(iChannel0, 4.*(U-vec2(.4,.6))   , vec4(.2,.2,0,1),vec4(1,1,.9,1), .2);
 
}