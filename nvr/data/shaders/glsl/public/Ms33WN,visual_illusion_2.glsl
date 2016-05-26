// Shader downloaded from https://www.shadertoy.com/view/Ms33WN
// written by shadertoy user 834144373
//
// Name: Visual illusion 2
// Description: Visual illusion
//    original shader by my [url]http://www.glslsandbox.com/e#29392.0[/url]
//     Loot at this for a 30 seconds,and then see other things,you will feel the illusion.:)
//-------------------------------------------------------------------------------------
//Loot at this for a 30 seconds,and then see other things,you will feel the illusion.:)
//-------------------------------------------------------------------------------------
//
//  Maybe I should call it "Eye's Effect Shader "
//	because you will find your eyes can write shader after you look at this

//uncomment it to see everything small
#define To_See_Everything_is_Big

//speed
#define speed 0.25

void mainImage(out vec4 o,in vec2 u) {
	vec2 uv = ( 2.*u.xy - iResolution.xy)/iResolution.y;
	
	float r; 
	
	float rr = length(uv);

    #ifdef To_See_Everything_is_Big
    	#define t iGlobalTime*speed
    #else
    	#define t -iGlobalTime*speed
    #endif	
    r = (length(uv)+t+atan(uv.x,uv.y)*.2);
	r = sin(r*80.);
	
	r = smoothstep(-.4,.4,r);
		
	o = vec4( r,r,r, 1.0 );
}
