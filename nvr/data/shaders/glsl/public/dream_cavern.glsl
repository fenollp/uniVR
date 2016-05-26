// Shader downloaded from https://www.shadertoy.com/view/Xt2SRG
// written by shadertoy user gtoledo3
//
// Name: dream cavern
// Description: Dream cavern derived from julia fractal.
const float depthCull=.1;
const float zoom=3.5;
const float bailout=10.;
const vec2 offset=vec2(.3,.45);
const int iterations=9;
float time=iGlobalTime;

//"dream cavern", by George Toledo. 2015.

vec3 hsv(const in float h, const in float s, const in float v) {
	return mix(vec3(1.0),clamp((abs(fract(h+vec3(3.,2.,1.)/3.0)*6.-3.)-1.),0.,1.0),s)*v;
}


// Cellular noise ("Worley noise") in 2D in GLSL.
// Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
// This code is released under the conditions of the MIT license.
// See LICENSE file for details, located in ZIP file here:
// http://webstaff.itn.liu.se/~stegu/GLSL-cellular/

// Permutation polynomial: (34x^2 + x) mod 289
vec3 permute(vec3 x) {
  return mod((34.0 * x + 1.0) * x, 289.0);
}

// Cellular noise, returning F1 and F2 in a vec2.
// Standard 3x3 search window for good F1 and F2 values
vec2 cellular(vec2 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 3/7
#define jitter 1.0 // Less gives more regular pattern
	vec2 Pi = mod(floor(P), 289.0);
 	vec2 Pf = fract(P);
	vec3 oi = vec3(-1.0, 0.0, 1.0);
	vec3 of = vec3(-0.5, 0.5, 1.5);
	vec3 px = permute(Pi.x + oi);
	vec3 p = permute(px.x + Pi.y + oi); // p11, p12, p13
	vec3 ox = fract(p*K) - Ko;
	vec3 oy = mod(floor(p*K),7.0)*K - Ko;
	vec3 dx = Pf.x + 0.5 + jitter*ox;
	vec3 dy = Pf.y - of + jitter*oy;
	vec3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
	p = permute(px.y + Pi.y + oi); // p21, p22, p23
	ox = fract(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 0.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	vec3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
	p = permute(px.z + Pi.y + oi); // p31, p32, p33
	ox = fract(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 1.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	vec3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
	// Sort out the two smallest distances (F1, F2)
	vec3 d1a = min(d1, d2);
	d2 = max(d1, d2); // Swap to keep candidates for F2
	d2 = min(d2, d3); // neither F1 nor F2 are now in d3
	d1 = min(d1a, d2); // F1 is now in d1
	d2 = max(d1a, d2); // Swap to keep candidates for F2
	d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
	d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
	d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
	d1.y = min(d1.y, d1.z); // nor in  d1.z
	d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
	return sqrt(d1.xy);
}

vec2 cmult(vec2 a, vec2 b)
{
	vec2 p;
	p[0]=a[0]*b[0]-a[1]*b[1];
	p[1]=a[0]*b[1]+a[1]*b[0];
	return p;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 offset=vec2(offset.x+sin(time*.1)*.05,offset.y+cos(time*.1)*.05);
	vec2 position = gl_FragCoord.xy/iResolution.xy - offset;
	
	position = position * (zoom-.7);

	vec2 perturb=vec2(-.7+(sin(time*.11)*.1)+(sin(time*.2)*.4),0.45+cos(time*.03)*.05)+(sin(time*.12)*.3);
	vec2 c, c0, d;
	float v;
	
	c = vec2(position);
	c0 = perturb;
	c +=(cellular( c*4.))*.025;
	vec2 f = position.xy;
	for(int i=0; i<iterations; i++) {
		d = cmult(c, c);
		c = d + c0;
		v = abs((c.x*c.x) + sin(.1*time+c.y*c.y)) / sqrt(.1*time+c.x*c.x );
			
			

		if (v > bailout) break;
	}
	vec2 c1 =c+cellular( .1*time+c*3.);
	vec2 c2=cellular(-.1*vec2(sin(.4*time + c.y*.2),sin(.02*time + c.x*.5)));
	vec2 c3=cellular( c*.01);

	
	float rand = mod(fract(sin(dot(2.5*gl_FragCoord.xy/iResolution.xy, vec2(12.9898,100.233))) * 43758.5453), .4);
	
	float col=(pow(v,-.23)*pow(sin(c2.x),.99));
	float col2=(pow(sin(c1.y)+1.75,.99));
	
    if(v>10.){

	fragColor = vec4(hsv(.8+sin(c3.r+col)*.3,.5-c3.r,.1+col*.75),1.);
	}

	else 
    
    fragColor=vec4(hsv(.8+sin(col2)*.3,.5-col+sin(time*.4)*.3,col2*.3),1.);
}


