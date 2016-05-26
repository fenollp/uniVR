// Shader downloaded from https://www.shadertoy.com/view/4ssGRX
// written by shadertoy user FabriceNeyret2
//
// Name: POV (persistance of vision)
// Description: try pause/play to understand what you've seen... or not :-D
// persistance of vision --- Fabrice NEYRET, August 2013
// see also:
// - http://www.squidi.net/three/entry.php?id=56
// - http://zarfoubo.blogspot.fr/2014/03/lart-des-animgifs.html , section "stereovision galliform"
// - texture advection: videos *_pigm.wmv in paper https://hal.archives-ouvertes.fr/hal-00171411

float t = iGlobalTime;
#define Pi 3.1415927

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float hash2(vec2 uv)
{
#if 0
	return hash(uv.x+1234.56*uv.y);
#else
	return texture2D(iChannel0,uv*iResolution.y/iChannelResolution[0].xy).r;
#endif
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
	float v = hash2(uv);

    vec2 p = uv-vec2(.8,.5);
	
	float d = sin(5.*(p.x-t+cos(1.1*t)+sin(t+3.*p.y)))*sin(5.*(p.y+sin(1.4*t)+cos(t+2.*p.x)));

	float k = (1.+.5*sin(.05*t*2.*Pi));
	d += k*sin(4.*length(p)-8.*t);

	// moving sphere
	if (length(p-vec2(.6*cos(2.*t),.2*sin(2.*t)))<.15+.1*sin(2.*t)) d = -d;

	// moving bar
	// if (p.x > .8*sin(.2*t*2.*Pi)) d = -d;


	// grid of points
	if (length(sin(20.*p)) < sin(.1*t*2.*Pi)) d = -d;
	
	if  (d>0.) v = fract(v+10.*d);

	fragColor = vec4(v);
}