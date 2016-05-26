// Shader downloaded from https://www.shadertoy.com/view/4dsXR4
// written by shadertoy user FabriceNeyret2
//
// Name: fibospirals
// Description: Mouse.x to change the stippling.
//    
#define PI 3.14159265359
bool keyToggle(int ascii) 
{ return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.* (fragCoord.xy / iResolution.y - vec2(.8,.5));
	vec2 mouse = iMouse.xy / iResolution.xy;
	float n = mouse.x;
	if (iMouse.z<=0.) n = .5; // sin(.01*iGlobalTime);
	
	float r = length(uv); float a = atan(uv.y,uv.x); // to polar
	
	float k = 1.* iResolution.y/1.5;
	float s = a -  k * r,   l,t;  
#if 0
		uv = 1./1.5*(fragCoord.xy-iResolution.xy/2.);
		r = length(uv)/4.; a = atan(uv.y,uv.x); 
		s = r - a/(2.*PI);
	    t = floor(s)+a/(2.*PI); // turns
	    l = PI*t*t+ 10.*iGlobalTime;// int (a/2PI da)
		s *= 2.*PI;
#else	
		s = a -  k * r;
		t = floor(s/(2.*PI)) * (2.*PI); 
		l = .1*(a+k*t)*t + 10.*iGlobalTime;
#endif
	float c = smoothstep(-1.,1.,sin(s))*smoothstep(-1.,1.,sin(10.*n*l));
	
	vec3 col;
	if (keyToggle(67))
		col = vec3(sin(c));
	else
		col = vec3(sin(c),sin(1.2*c),sin(1.4*c));
	
	fragColor = vec4(col,1.);
}