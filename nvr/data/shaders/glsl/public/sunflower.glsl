// Shader downloaded from https://www.shadertoy.com/view/lsBSRd
// written by shadertoy user FabriceNeyret2
//
// Name: sunflower
// Description: NB: try to uncomment line 6 and reset time :-)
#define N 20.
float t = iGlobalTime;
void mainImage( out vec4 o, vec2 u ) {
    vec2 R=iResolution.xy;
    u = (u+u -R)/R.y;
    float r = length(u), a = atan(u.y,u.x);
    // r *= 1.-.1*(.5+.5*cos(2.*r*t));
    float i = floor(r*N);
    a *= floor(pow(128.,i/N)); 	 a += 10.*t+123.34*i;
    r +=  (.5+.5*cos(a)) / N;    r = floor(N*r)/N;
	o = (1.-r)*vec4(3,2,1,1);
}