// Shader downloaded from https://www.shadertoy.com/view/4sXXR7
// written by shadertoy user FabriceNeyret2
//
// Name: Color illusion in spirals
// Description: There is no blue spiral. only green/pink (large spirals).
//    Works with any colors in the 3 defines.
// inspired from http://www.moillusions.com/color-optical-illusion/

#define LARGE_SPIRAL_COL1 vec3(0.,1.,.5)
#define LARGE_SPIRAL_COL2 vec3(1.,0.,1.)
#define SMALL_SPIRAL_COL  vec3(1.,.7,0.)
	
#define PI 3.14159265359
bool keyToggle(int ascii) 
{ return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.* (fragCoord.xy / iResolution.y - vec2(.8,.5));
	vec2 mouse = iMouse.xy / iResolution.xy;

	if (iMouse.z<=0.) mouse.x = (1.+sin(.6*iGlobalTime))/2.;
	
	float r = length(uv); float a = atan(uv.y,uv.x); // to polar
	float s1 = a - mouse.x*40.* 2.*PI*r,
		  s2 = 6.*a + 2.*2.*PI*log(r),
		  s3 = 6.*a + 2.*2.*PI*log(r);
	float c1 = smoothstep(-.25,.25,sin(s1)),
		  c2 = smoothstep(-.01,.01,sin(s2)),
		  c3 = smoothstep( .67,.666,sin(s3/2.-3.*PI/4.));

	vec3 col  = mix( SMALL_SPIRAL_COL,  LARGE_SPIRAL_COL2,1.-c3);
	vec3 col2 = mix( LARGE_SPIRAL_COL2, LARGE_SPIRAL_COL1, c2 );
	c1 = mix(c1,1.-c1,c3);
	col = mix(col,col2,c1);
	fragColor = vec4(col,1.);
}