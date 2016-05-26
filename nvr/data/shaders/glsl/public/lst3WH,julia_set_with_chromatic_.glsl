// Shader downloaded from https://www.shadertoy.com/view/lst3WH
// written by shadertoy user FabriceNeyret2
//
// Name: Julia Set with chromatic 
// Description: variant from  kylefeng28's https://www.shadertoy.com/view/ldt3W8
//    Because I love chromatic abheration :-D
// variant from  kylefeng28's https://www.shadertoy.com/view/ldt3W8

#define N 100.
float t = iGlobalTime-8.7;

float J(vec2 z, vec2 c ) {
    for (float i = 0.; i < N; i++) {
        z = mat2(z,-z.y,z.x)*z + c;
        if ( length(z) > 2.)  return i/N;       
    }
	return 1.;
}

void mainImage(out vec4 o, vec2 z) {
    vec2 R = iResolution.xy;
    z = (z+z-R)/R.y;

    vec2 c, E= 0.01*vec2(1,1);
    c.x = -.4 + .1 * cos(t *.5);
    c.y =  .6 + .1 * sin(t + .5);
   
    o = vec4(J(z,c), J(z,c+E), J(z,c+2.*E), 1 );

}