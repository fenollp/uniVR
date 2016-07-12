// Shader downloaded from https://www.shadertoy.com/view/Mt2SWy
// written by shadertoy user FabriceNeyret2
//
// Name: plasma snakes 4
// Description: .
#define C(t) sign(cos(t))*pow(abs(cos(t)),z)
#define S(t) C(t+1.57)

#define P(t)   vec2( 1.7*C(t)+.5*S(-2.7*t), .8*S(1.2*t)+.5*C(3.2*t) ) /1.5

#define draw(t,c)  o += 20.*smoothstep(.03*c, c-c, vec4(length(P((t))-U))) * length(P((t+.01))-P((t)))


void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
	vec2 R = iResolution.xy;  
    U = (2.*U -R ) / R.y;
    float T = iGlobalTime, 
        z = 5.+5.*cos(T*.3);
    
    for (float dt=0.; dt<5.; dt+= .03) {
        
        float t = dt+T;
        
        draw( t,       vec4(1,2,3,0));
        draw( t-1234., vec4(3,2,1,0));        
        draw( t+1234., vec4(2,3,1,0));        
    }
}