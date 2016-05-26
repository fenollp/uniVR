// Shader downloaded from https://www.shadertoy.com/view/ltfSDl
// written by shadertoy user FabriceNeyret2
//
// Name: motion illusion 3
// Description: does the ball quit the center ? :-)
//    
//    (for the Shepard scale, see also here: https://www.shadertoy.com/view/XdlXWX )
void mainImage( out vec4 o, vec2 p )
{
    o -= o;
	p /= iResolution.xy;
    float s = 0.,a,t,S,C;
    for (float i=-3.; i<= 3.; i++) {
        s += a = .5+.5*cos(t= fract(iGlobalTime)-i);  
        t *= .6*smoothstep(0.,1.,length(p-.5));     
	    o += a*texture2D(iChannel0,mat2(C=cos(t),S=sin(t),-S,C)*(p-.5)+.1*iGlobalTime);
    } 
    o /= s;
    o = 2.*o-.5;
}