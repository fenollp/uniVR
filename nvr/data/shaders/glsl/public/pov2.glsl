// Shader downloaded from https://www.shadertoy.com/view/XssGRX
// written by shadertoy user FabriceNeyret2
//
// Name: POV2
// Description: try pressing pause/play to understand what you've seen... or not :-D
// Persistance of vison  --- Fabrice NEYRET  August 2013
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

bool drawCircle(inout float v,vec2 uv,  vec2 pt,float r, int mode)
{
	float d = length(vec2(.8,.5)+.5*pt - uv)/r;
    if (mode==1)
	{  if (d<1.) { v = 1.-v; return true; } }
	else
	{  if (d<1.) { v = fract(v+sin(4.*d*2.*Pi)); return true; } }
	return false;
}

vec2 orbit(float rx,float ry,  float va,float phi)
{
	return vec2(rx*cos(va*t-phi),ry*sin(va*t-phi));
}

mat2 rot(float a)
{
	return mat2(cos(a), -sin(a), sin(a), cos(a));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
	float v = hash2(uv);
	mat2 R = rot(Pi/16.*sin(.1*t));

	bool sun = drawCircle(v,uv, vec2(0.), .3+.01*sin(50.*t)+.02*sin(5.*t), 1);

	if ((!sun)||sin(t)>0.) 
		drawCircle(v,uv, R*R*orbit(1.3,.2, 1.,0.), .1/(1.-.5*sin(t)), 0);

	if ((!sun)||sin(3.2*t)>0.) 
		drawCircle(v,uv, R*orbit(.6,.1, 3.2,0.), .05/(1.-.25*sin(3.2*t)), 0);

	if ((!sun)||sin(.9*t)>0.) 
		drawCircle(v,uv, orbit(3.,.6, .9,0.), .2/(1.-.5*sin(.9*t)), 0);

	for(int i=0; i<10; i++)
	{
		float phi = float(i)*2.*Pi/10.;
		if ((!sun)||sin(.3*t-phi)>0.) 
		  drawCircle(v,uv, R*orbit(2.,.5, .3,phi), .01/(1.-.25*sin(.3*t-phi)), 0);
	}
	
	//drawCircle(v,uv, vec2(cos(1.789*t),sin(0.5678*t)), .2+.1*sin(.1*t),0);
	vec3 col = vec3(v); 
	fragColor = vec4(col,1.0);
}