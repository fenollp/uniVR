// Shader downloaded from https://www.shadertoy.com/view/4sXGzX
// written by shadertoy user FabriceNeyret2
//
// Name: pulsing universe - test
// Description: transformations are done on 3 layers regenerating quickly so the texture does not accumulate stretching.
// advected texture: stationary deformations
// Fabrice NEYRET  18/07/2013

#define a 1. // angular velocity
#define D 6. // texture regeneration delay

#define Pi 3.1415927
#define cos01(t) (.5-.5*cos(t))
float time = iGlobalTime+0.3/.02;
vec2 FragCoord;

vec3 display_layer(float t)
{
	vec2 uv = (FragCoord.xy / iResolution.y-vec2(.9,.5))*2.;

	// global fade-in and out of effects.
	float T = cos01(2.*Pi*.02*time);
	float phaseT = (mod(.02*time,2.)<1.)? 0. : Pi;
		
	// weight of this layer: appears and disappear seemlessly
	float k = cos01(2.*Pi*t/D);

	// radial effect on angular velocity
	float r = length(uv);
	//r = 1./r;
    r = .1+.4*cos01(r);
	if (phaseT>0.)
		r += T*(30.*exp(-400.*r*r)-.4*cos01(r));
	
	// zoom effect on angular velocity
	float z = 1.-T*cos01(phaseT+Pi*t/D);
	
	// transformation of the texture
    float c = cos(a*t*r), s = sin(a*t*r);
	mat2 M = mat2( c, -s, s, c);
	uv = z*M*uv;
	
	return k*texture2D(iChannel0,uv).rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 col;
    float t= time;
	FragCoord=fragCoord;
    
	t = mod(t,D/3.);

	col  = display_layer(t);
    col += display_layer(t+D/3.);
    col += display_layer(t+2.*D/3.);
	
	
	fragColor = vec4(col,1.0);
}