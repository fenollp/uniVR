// Shader downloaded from https://www.shadertoy.com/view/4dXGDn
// written by shadertoy user movAX13h
//
// Name: Invaders
// Description: random space invaders for everyone ;)
/*
Invaders fragment shader by movAX13h, April 2013

NOTE: This was the first shader on Shadertoy using encoded bitmaps
      (that's why I keep it public)

  - adjust space coords (5x5 grid)
  - calc pseudorandom number n (sync to music) 
  - calc segment to get k (x+y*3) and mirror x
  - calc bit of n at position k; if set, paint invader color

  [NOTE] binary AND operator (&) is not available in GLSL ES
         thus using: (n/2^k)%2, assuming n and k integer
         which in GLSL is: mod(n/(pow(2.0,k)),2.0)
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = mod(fragCoord.xy/iResolution.y*5.0, iResolution.xy);
	p.x = abs(floor(p.x - 2.25*iResolution.x/iResolution.y));
	p.y = -floor(p.y - 5.0);
	
	vec3 c = vec3(0.0, 0.0, 0.1 + 0.1*length(vec2(p.x, p.y - 3.0)) + 0.1*sin(iGlobalTime));
	
	if (p.x <= 2.0) 
	{
		c.z *= 0.5;
		float n = floor(32768.0*fract(sin(floor(iChannelTime[0]*1.89-0.08))*43758.5453));
		if (int(mod(n/(pow(2.0,float(p.x + p.y*3.0))),2.0)) == 1) c = vec3(1.0);
	}
	fragColor = vec4(c, 1.0);
}