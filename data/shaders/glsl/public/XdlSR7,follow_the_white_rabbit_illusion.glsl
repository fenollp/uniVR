// Shader downloaded from https://www.shadertoy.com/view/XdlSR7
// written by shadertoy user FabriceNeyret2
//
// Name: follow the white rabbit illusion
// Description: inspired from http://www.moillusions.com/pulsating-nightmare-optical-illusion/
// inspired from http://www.moillusions.com/pulsating-nightmare-optical-illusion/

#define DIR 52./2.
#define CIRCLES 10. // 15
#define K (2.*2.*PI)
#define PEAK 2.
#define A 1.*PI/3.
#define S 8.

#define PI 3.14159265356
float t = iGlobalTime;
vec4 FragColor;

float rnd(float i) { return fract(sin(i*1323.23)*1e5); } 
								  
void rabbit(vec2 uv) {
	float r;
	t = floor(3.*t);
#if 1
	vec2 pos = vec2(1.7,1.)*(2.*vec2(rnd(t),rnd(t-543.34))-1.);
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
#else
	vec2 uv0 = uv;
	for (float i=0.; i<4.; i++) {
		vec2 uv = uv0 - vec2(1.2*cos(1.*t+i*PI/2.),.6*sin(1.*t+i*PI/2.)); 
		r0 = length(uv), a = atan(uv.y,uv.x); // to polar
		uv = r0*vec2(cos(a+2.*t),sin(a+2.*t)) ; 
		r = S*max(abs(uv.x),abs(uv.y)); ;
		r = smoothstep(1.,.97,r)-smoothstep(1.,.97,r/.9)+smoothstep(1.,.97,r/.5);
		FragColor += vec3(2.*r);
	}
#endif
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.85,.5));
	
	// --- background pattern
	
	float r0 = length(uv), a = atan(uv.y,uv.x); // to polar
	//r -= 2./abs(1.+(1.-2./PEAK)*sin((DIR)*a))/CIRCLES; // in[1.,PEAK]
	float r = r0 + 2.*r0*PEAK*abs(sin(.5*(DIR)*a))/CIRCLES; 
	r = sqrt(r);
	r = CIRCLES*2.*PI*r; 
	float dr = .5*fwidth(r);
	vec3 col = vec3( (cos(r+dr+0.*A)-cos(r-dr+0.*A))/(2.*dr), 
					 (cos(r+dr+1.*A)-cos(r-dr+1.*A))/(2.*dr), 
					 (cos(r+dr+2.*A)-cos(r-dr+2.*A))/(2.*dr) );
	col = .3+.7*col;
	FragColor = vec4(col,1.0);
	
	// --- draw moving shape
	rabbit(uv);
    fragColor=FragColor;
}