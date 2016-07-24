// Shader downloaded from https://www.shadertoy.com/view/MdsXDr
// written by shadertoy user FabriceNeyret2
//
// Name: motion illusion 2
// Description: mouse.y to tune B/W thickness, or T for time varying.
// some examples here : http://www.psy.ritsumei.ac.jp/~akitaoka/uzu8e.html

#define N 36. // squares on a circle

float  R1=.7;        // square side relative to its cell.

#define PI 3.1415927
float  t=iGlobalTime;
vec4 FragColor;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float rnd(float i) { return fract(sin(i*1323.23)*1e5); } 
								  
void rabbit(vec2 uv) {
	float r;
	t = floor(3.*t);
	vec2 pos = vec2(1.3,1.)*(2.*vec2(rnd(t),rnd(t-543.34))-1.);
	uv = uv-pos;
	r = smoothstep(1.,.97,10.*length(uv));
	r += smoothstep(1.,.97,10.*4.*length(uv+vec2(.1,.0)));	
	r += smoothstep(1.,.97,10.*1.5*length(uv-vec2(.05,.1)));	
	uv.x *= 6.; 
	r += smoothstep(1.,.97,10.*length(uv-vec2(.2,.2)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.4,.18)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.2,-.03)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.4,-.03)));
	FragColor += vec4(2.*r);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.85,.5));

	if (iMouse.z<=0.) {
		R1 = (keyToggle(32)) ? .8+.2*sin(t/5.) : .9;
	} else {
		R1 = iMouse.y/iResolution.y;
	}
	
	float r = length(uv), a = atan(uv.y,uv.x); // to polar
	
	// cells in polar
	r = 3.+log(r)*N/6. +.5; // r*N+.5;
	a = N*a/(2.*PI)+.5;
	float ix = floor(r),
		  iy = floor(a),
	      y = fract(r),     		// 0..1
	      x = 2.*(fract(a)-.5);  	// -1..1


	vec3 col = (mod(ix+iy,2.)<1.) ? vec3(0.,0.,(y<R1)?1.-.8*y/R1:0.) 
								  : (y<R1)?.5*vec3(vec2(.8+.2*y/R1),0.):vec3(.9);

	FragColor = vec4(col,1.);
	rabbit(uv);
    fragColor=FragColor;
}