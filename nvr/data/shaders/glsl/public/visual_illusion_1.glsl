// Shader downloaded from https://www.shadertoy.com/view/ls33WN
// written by shadertoy user 834144373
//
// Name: Visual illusion 1
// Description: Visual illusion.
//    original shader by my [url]http://www.glslsandbox.com/e#29390.2[/url]
//Visual illusion.glsl
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373 (恬纳微晰) 2015/12/8
//Tags: 2D,visual illusion,effect
//-----------------------------------------------------------------------------------------

#define t iGlobalTime/15.
#define q 0.77

void mainImage(out vec4 o,in vec2 u) {
	vec2 uv = ( 2.*u.xy - iResolution.xy)/iResolution.y;
	
	float r; 
	
	float rr = length(uv);
	
	r = length(uv)-t*sign(rr-q);
	
	r = sin(r*80.);
	
	r = smoothstep(-0.4,0.4,r);
		
	o = vec4( r,r,r, 1.0 );
}

