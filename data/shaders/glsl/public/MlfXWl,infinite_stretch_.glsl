// Shader downloaded from https://www.shadertoy.com/view/MlfXWl
// written by shadertoy user FabriceNeyret2
//
// Name: infinite stretch 
// Description: ( try also the commented line).
#define rnd(p) fract(4e4*sin(17.34+dot(p,vec2(23.17,73.98))))

void mainImage( out vec4 o, vec2 p )
{
    o = vec4(0);
	p /= iResolution.xy;
    float s = 0.,a,t;
    for (float i=-3.; i< 3.; i++) {
        t= fract(iGlobalTime)-i;
        s += a = .5+.5*cos(t-0.*rnd(p));
	    o +=  a*texture2D(iChannel0,p +t*vec2(2.*p.y-1.,0));
	 // o +=  a*texture2D(iChannel0,p +t*sin(3.14*vec2(2.*p.y-1.,0)));
    } 
    o /= s;
    o = 2.*o-.5;
}