// Shader downloaded from https://www.shadertoy.com/view/XdsSR7
// written by shadertoy user FabriceNeyret2
//
// Name: Wheel of illusion
// Description: .
#define N 6.
#define DA .05
#define DR .3

#define PI 3.14159265359
float t = iGlobalTime;
vec4 FragColor;

bool wheel(vec2 uv, float dir) {
	float r0 = length(uv),  a = dir*atan(uv.y,uv.x); // to polar
	if (r0>1.) return false;
	
	r0 = 1.-log(r0);
	//r0 -= .5*a/(2.*PI);
	float r = N*r0/2.; 		a = floor(r/r0+.5)*a + floor(r+.5)*PI/2.; 
	r = mod(r+.5,1.)-.5; 	
	float a1 =  mod(   a*6./(2.*PI)+.5, 1.)-.5;
	float a2 =  mod(.5+a*6./(2.*PI)+.5, 1.)-.5;

	float k = 1./(1.+DR);


	float d1 = smoothstep(1.,.92,2.*(1.+DA)*length(vec2(k*r, a1)));
	float d2 = smoothstep(1.,.92,2.*(1.+DA)*length(vec2(k*r, a2)));
	d2 *= smoothstep( .5, .5*.92,abs(r));

	vec3 col2 = (a1>0.) ? vec3(1.,0.,0.) : vec3(0.,1.,0.);

	vec3 col;
	col = mix(vec3(d1), col2, d1*d2);
	col = mix(vec3(1.), col,  0.*d1+d2);
	
	FragColor = vec4(col,1.);
	return true;
}

float rnd(float i) { return fract(sin(i*1323.23)*1e5); } 

void rabbit(vec2 uv) {
	float r;
#if 1
	t = floor(3.*t);
	vec2 pos = vec2(1.7,1.)*(2.*vec2(rnd(t),rnd(t-543.34))-1.);
#else
	vec2 pos = .7*vec2(2.*cos(t),sin(t));
#endif
	
	uv = uv-pos;
	r = smoothstep(1.,.97,10.*length(uv));
	r += smoothstep(1.,.97,10.*4. *length(uv+vec2(.1,.0)));	
	r += smoothstep(1.,.97,10.*1.5*length(uv-vec2(.05,.1)));	
	uv.x *= 6.; 
	r += smoothstep(1.,.97,10.*length(uv-vec2(.2,.2)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.4,.18)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.2,-.03)));
	r += smoothstep(1.,.97,10.*length(uv-vec2(.4,-.03)));
	FragColor -= vec4(2.*r);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y-vec2(.85,.5));
	
	FragColor = vec4(1.);
	
	float s = 1.;
	for (float i = -1.5; i<2.; i++ ) { 
		wheel(3.*(uv-vec2( i+.5, 0.)), s);
		wheel(3.*(uv-vec2( i+.5, 1.)),-s);
		wheel(3.*(uv-vec2( i+.5,-1.)),-s);
 		wheel(2.*(uv-vec2( i,    .5)), s);
		wheel(2.*(uv-vec2( i,   -.5)),-s);
		s = -s;
	}

	rabbit(uv);	
    fragColor=FragColor;
}