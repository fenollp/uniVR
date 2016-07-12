// Shader downloaded from https://www.shadertoy.com/view/XtBSWy
// written by shadertoy user gtoledo3
//
// Name: cellular daydream
// Description: Combining cellular noise with various uv warp effects, zoom/density levels, and color mapping, for creative effect.
//"Cellular Daydream", George Toledo. 2015. 

float time=iGlobalTime*.1;
vec2 offset=vec2(.5);

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
//end worley

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	
	vec2 position = fragCoord.xy / iResolution.x - offset;

	position = position * (.1+.5*(sin(time*.01)*2.2));//position and zoom offset fx

	//various uv distortion, zoom levels, offsets, cellular FX->pattern
	vec2 cec  =cellular(.35+vec2(0.,time*.2)+position*(9.+sin(time*.01)))+sin(time+position.x*3.)*.3;
	vec2 cec2 =cellular(2.+position*4.)+cos(position.y*12.)*.3;
	vec2 cec3 =cellular(7.+vec2(0.,time*.4)+sin(position*14.))*.5;
	vec2 cec4 =cellular(9.+position*12.+cos(position.x*4.)*.5);
	vec2 cec5 =cellular(12.+position*28.);
	vec2 cec6 =cellular(3.+vec2(0.,time*.4)+position*34.)+(cos(3.5+position.x*32.)*.3)+(cos(5.*time+position.y*9.)*.1);
	vec2 cec7 =cellular(vec2(time*2.4,0.)+(position+(cos(position.x*3.)*.1))*96.+cos(position.x*3.)*14.)+cos(time+position.x*12.)*.3;

	//min between different patterns
    cec=min(cec,cec2);
	cec=min(cec,cec3);
	cec=min(cec,cec4);
	cec=min(cec,cec5);
	cec=min(cec,cec6);
	cec=min(cec,cec7);
	//rand idea I found at heroku one time, probably changed some
	float rand = mod(fract(sin(dot(fragCoord.xy / iResolution.xy, vec2(12.9898,1980.223+time))) * 43758.5453), .05);
	//combining x and y lanes with a slip timing and different instensities, to create a variety of formations
	float l=pow(1.-sin(cec.y),.5+(sin(time*.0011)*.3));
	float l2=pow(1.-sin(cec.x),1.5+(sin(time*.001)*.3));
	l=min(l,l2);
    //vignette
	float v=length(fragCoord.xy / iResolution.xy-.5);
    v=smoothstep(v,.8,.7);
	fragColor=vec4(hsv((time*.01)+.6-sin(l*1.8)*2.9,l*.65,l-.2),1.);
	fragColor.rgb +=vec3(rand);
    fragColor.rgb -=vec3(1.-v);
}

