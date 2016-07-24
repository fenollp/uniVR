// Shader downloaded from https://www.shadertoy.com/view/lt2SWy
// written by shadertoy user FabriceNeyret2
//
// Name: plasma snakes 3
// Description: .
#define P(t)   vec2( 1.7*cos(t)+.5*sin(-2.7*t), .8*sin(1.2*t)+.5*cos(3.2*t) ) /1.5

#define draw(t,c)  o += .1*smoothstep(.03*c, c-c, vec4(length(P((t))-U)))


void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
	vec2 R = iResolution.xy;  
    U = (2.*U -R ) / R.y;
    
    for (float dt=0.; dt<5.; dt+= .01) {
        
        float t = dt+iGlobalTime;
        
        draw( t,       vec4(1,2,3,0));
        draw( t-1234., vec4(3,2,1,0));        
        draw( t+1234., vec4(2,3,1,0));        
    }
}