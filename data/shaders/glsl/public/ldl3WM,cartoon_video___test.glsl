// Shader downloaded from https://www.shadertoy.com/view/ldl3WM
// written by shadertoy user FabriceNeyret2
//
// Name: cartoon video - test
// Description: sobel  mask  times colorized smoothed saturated image
float eps = .007;
#define PI 3.1415927

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 t   = texture2D(iChannel0, uv).rgb;
	vec3 t00 = texture2D(iChannel0, uv+vec2(-eps,-eps)).rgb;
	vec3 t10 = texture2D(iChannel0, uv+vec2( eps,-eps)).rgb;
	vec3 t01 = texture2D(iChannel0, uv+vec2(-eps, eps)).rgb;
	vec3 t11 = texture2D(iChannel0, uv+vec2( eps, eps)).rgb;
	vec3 tm = (t00+t01+t10+t11)/4.;
	vec3 v=t; vec3 c;
	//t = .5+.5*sin(vec4(100.,76.43,23.75,1.)*t);
	t = t-tm;
	//t = 1.-t;
	t = t*t*t;
	//t = 1.-t;
	v=t;
	v = 10000.*t;

	float g = (tm.x-.3)*5.;
	//g = (g-.5); g = g*g*g/2.-.5; 
	vec3 col0 = vec3(0.,0.,0.);
	vec3 col1 = vec3(.2,.5,1.);
	vec3 col2 = vec3(1.,.8,.7);
	vec3 col3 = vec3(1.,1.,1.);
	if      (g > 2.) c = mix(col2,col3,g-2.);
	else if (g > 1.) c = mix(col1,col2,g-1.);
	else             c = mix(col0,col1,g);
		
	c = clamp(c,0.,1.);
	v = clamp(v,0.,1.);
	v = c*(1.-v); 
	//v = c-1.5*(1.-v); v = 1.-v;
	v = clamp(v,0.,1.);
	if (v==col0) v=col3;
	fragColor = vec4(v,1.);
}