// Shader downloaded from https://www.shadertoy.com/view/XdfXWN
// written by shadertoy user FabriceNeyret2
//
// Name: Mandelbrot - one more :-) 
// Description: ( try mouse ).
// inspired from https://www.shadertoy.com/view/XdfSWN
#define N 100.

void mainImage( out vec4 o, vec2 u ) {
	float t = iGlobalTime/2., 
		 st = exp(-6.*(1.-cos(.1*t))), c=cos(t),s=sin(t); mat2 M=mat2(c,-s,s,c);
	vec2 R=iResolution.xy, z0 = st*M*2.*(u/R.y-vec2(1.1,.5))-vec2(.4615,-.622), z=z0, 
		m = (length(iMouse.xy)==0.)? vec2(0) : st*2.*(iMouse.xy/R.y-vec2(1.1,.5));

	for (float i=0.; i<N; i++) {
		if (dot(z,z)>4.) { o = vec4(1.-i/N); return;} // z diverged
		z -= m;
		z = z0+m + mat2(z,-z.y,z.x)*z; // vec2(z.x*z.x - z.y*z.y, 2.*z.x*z.y); // z = z0+z^2
	}
	o = vec4(0); // needed ?
}