// Shader downloaded from https://www.shadertoy.com/view/lsfSRn
// written by shadertoy user FabriceNeyret2
//
// Name: POV3 
// Description: try pressing pause/play to understand what you've seen... or not :-D
//    
//    mouse.y to tune texture scale. 
// inspired from 
// - POV & POV2 : // Persistance of vison   https://www.shadertoy.com/view/XssGRX
// - http://www.squidi.net/three/entry.php?id=56
// - http://zarfoubo.blogspot.fr/2014/03/lart-des-animgifs.html , section "stereovision galliform"
// - texture advection: videos *_pigm.wmv in paper https://hal.archives-ouvertes.fr/hal-00171411

#define FLOW true

#define Pi 3.1415927
vec2 m; // mouse

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float hash2(vec2 uv)
{
#if 0
	return hash(uv.x+1234.56*uv.y);
#else
	//return texture2D(iChannel0,2.*uv).r;
	return texture2D(iChannel0,m.y*uv*iResolution.y/iChannelResolution[0].xy).r;
#endif
}

bool keyToggle(int ascii) 
{
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float t = iGlobalTime; // - ( (keyToggle(32)) ? iDate.a : 0.) ;
		   

bool drawCircle(inout float v,vec2 uv, vec2 pt, vec2 ofs, float r, int mode)
{
	// vec2 newUV = vec2(.8,.5)+.5*pt - uv;
	vec2 newUV = .5*pt - uv;
		
	float d = length(newUV)/r;
	if (FLOW) 
		if (d<1.) { v = hash2(newUV-ofs); return true; }
	    else        return false;

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
	m = iMouse.xy/ iResolution.y;
	if ((length(m)==0.) || (iMouse.z<0.)) m = vec2(.9,.9);

	vec2 uv = fragCoord.xy / iResolution.y - vec2(.8,.5);
	float v = hash2(uv);
	mat2 R = rot(Pi/16.*sin(.1*t));

	bool sun = drawCircle(v,rot(t)*uv, vec2(0.), t*vec2(0.), .3+.01*sin(50.*t)+.02*sin(5.*t), 1);

	if ((!sun)||sin(t)>0.) 
		drawCircle(v,uv, R*R*orbit(1.3,.2, 1.,0.), t*vec2(.3,0.), .1/(1.-.5*sin(t)), 0);

	if ((!sun)||sin(3.2*t)>0.) 
		drawCircle(v,uv, R*orbit(.6,.1, 3.2,0.), t*vec2(.1,0.), .05/(1.-.25*sin(3.2*t)), 0);

	if ((!sun)||sin(.9*t)>0.) 
		drawCircle(v,uv, orbit(3.,.6, .9,0.), t*vec2(0.,0.), .2/(1.-.5*sin(.9*t)), 0);

	for(int i=0; i<10; i++)
	{
		float phi = float(i)*2.*Pi/10.;
		if ((!sun)||sin(.3*t-phi)>0.) 
		  drawCircle(v,uv, R*orbit(2.,.5, .3,phi), vec2(0.,0.), .01/(1.-.25*sin(.3*t-phi)), 0);
	}
	
	//drawCircle(v,uv, vec2(cos(1.789*t),sin(0.5678*t)), .2+.1*sin(.1*t),0);
	vec3 col = vec3(v); 
	fragColor = vec4(col,1.0);
}
