// Shader downloaded from https://www.shadertoy.com/view/ldfSWr
// written by shadertoy user FabriceNeyret2
//
// Name: dipole
// Description: interferences from a dipole (mouse + it's center-symmetric)
float t = iGlobalTime;
#define S .4
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y-vec2(.85,.5));
	vec2 mouse = 2.*(iMouse.xy / iResolution.y-vec2(.85,.5));
	if (iMouse.z<=0.) {
		float d = .5+.5*sin(.2*S*t);
		mouse.x = (.8*cos(S*t)     +.5*sin(2.754*S*t))*d;
		mouse.y = (.5*cos(.913*S*t)+.4*sin(3.784*S*t))*d;
	}
	float v1 = sin(.5*iResolution.y*length(uv+mouse)-30.*t),
		  v2 = sin(.5*iResolution.y*length(uv-mouse)-30.*t);
	fragColor = clamp(vec4(0.,.8*(v1+v2)/2.,0.,1.),0.,1.) + clamp(vec4(-(v1+v2)/2.,0.,0.,1.),0.,1.);
}