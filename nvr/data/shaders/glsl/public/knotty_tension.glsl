// Shader downloaded from https://www.shadertoy.com/view/4dyGzt
// written by shadertoy user konidia
//
// Name: Knotty Tension
// Description: It gets better and better, 
//    
//    and I abused #define...
#define cl color

#define t iGlobalTime

#define r 15.8 * fract(sin(t)*0.04)

#define wp vec2 u, float g, float h, float p

#define steps(q,s) return step( s(u.x*g) * h + p, u.y ) - step( s(u.x*g) * h + p+q, u.y );

#define wsin(pos) w1( vec2(u.y+t/3., u.x), r, 0.04, pos)
#define wcos(pos) w2( vec2(u.x+t/3., u.y), r, 0.04, pos)

#define c(v) cl[0].v + cl[1].v

#define w(a) a(0.5), a(0.4), a(0.6)  


float w1(wp) {
	steps(0.01, sin)
}

float w2(wp) {
    steps(0.01,cos)
}

void mainImage( out vec4 O, in vec2 U )
{
	vec2 u = U.xy / iResolution.xy;
    
    mat3 cl;
    cl[0].xyz = vec3( w(wsin) );
    cl[1].xyz = vec3( w(wcos) );
    
    
	O = vec4(c(x), c(y), c(z),1.0);
}