// Shader downloaded from https://www.shadertoy.com/view/ltXSWN
// written by shadertoy user aiekick
//
// Name: [2TC15] Warp Experiment 3 (271c)
// Description: reduced version of [url=https://www.shadertoy.com/view/ltXXW4]Warp Experiment 3[/url]
//    mouse available (thanks to coyote :))
//    483 chars for the original and 250 for the shortest version (271 with mouse and mouse test)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

////////////////////////////////////////////////////////
////////// WITH MOUSE AND MOUSE TEST ///// 279 /////////
////////////////////////////////////////////////////////

// 276 chars by coyote with mouse and mouse test ^^
#define b(p) +vec4( T=.7*length(v+v-R-f.p)/R.y,T,1e-3/T/T,0)
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy;
    float T=iDate.w*.5, C=cos(T);
    f = R.y*.8*vec4(C, T=sin(T), C+C, -.5*T);
    f = b(x*0.)b(xy*.5)b(xw)b(zy) +
        step(0., f=iMouse).z * // mouse test
        	b(xy*2.+R); // mouse pos
    f = texture2D(iChannel0, f.xy) + f.z;
}

////////////////////////////////////////////////////////
////////// WITHOUT MOUSE ////// 250 ////////////////////
////////////////////////////////////////////////////////

/*
// 250 chars by coyote without mouse ^^ 274 with mouse
#define b(p) vec4( vec2(T=.7*length((v+v-R)/R.y-p)),1e-3/T/T,0)
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy;
    float T=iGlobalTime*.5, C=cos(T);
    f = .8*vec4(C, T=sin(T), C+C, -.5*T);
    f = b(0.) + b(f.xy*.5) + b(f.xw) + b(f.zy);// + b((2.*iMouse.xy-R)/R.y); // mouse
    f = texture2D(iChannel0, f.xy) + f.z;
}
*/
/*
// 258 can be 2 char shorter (see under ) but keep the calcul of v one time per pixel
//better version ( save 1 char ^^) by replacing of
// float T=iGlobalTime*.5, C=cos(T);
// f = vec4(C, T=sin(T), C+C, -.5*T);
//by
// f.z = (f.x = cos(R.x=iGlobalTime*.5))*2.;
// f.w = -.5*(f.y = sin(R.x)); 
#define b(p) vec4(R = length(v-p*.8) * vec2(.7),2e-3/dot(R,R),0)
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy;
    v = (v+v-R)/R.y;
    f.z = (f.x = cos(R.x=iGlobalTime*.5))*2.; 
	f.w = -.5*(f.y = sin(R.x)); 
    f = b(0.) + b(f.xy*.5) + b(f.xw) + b(f.zy);
    f = texture2D(iChannel0, f.xy) + f.z;
}
*/

/*
// 257 by coyote :) but less efficient for the calcul of old v
#define b(p) vec4( A = length((v+v-R)/R.y-p*.8) * vec2(.7),2e-3/dot(A,A),0)
void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy, A;
    float T=iGlobalTime*.5, C=cos(T);
    f = vec4(C, T=sin(T), C+C, -.5*T);
    f = b(0.) + b(f.xy*.5) + b(f.xw) + b(f.zy);
    f = texture2D(iChannel0, f.xy) + f.z;
}
*/
/*
// 262 by coyote :)
#define b(p) vec4(R = length(v-p) * vec2(.7),2e-3/dot(R,R),0)

void mainImage( out vec4 f, vec2 v )
{
    vec2 R = iResolution.xy;
    v = (v+v-R)/R.y;

    float T=iGlobalTime*.5, C=cos(T);
    
    f = vec4(C, T=sin(T), C+C, -.5*T);
     
    f = b(0.) + b(f.xy*.4) + b(f.xw*.8) + b(f.zy*.8);
   
    f = texture2D(iChannel0, f.xy) + f.z;
}
*/
/* 280 chars by me
#define b(p) f.z += 2e-3/dot(o = length(v-p) * vec2(.7), o); f.xy += o; 

void mainImage( out vec4 f, vec2 v )
{
    f.xy = iResolution.xy;
    v = (v+v-f.xy)/f.y;
    vec4 k = vec4(cos(f.w = iDate.w*.5),sin(f.w), 2.*cos(-f.w),.5*sin(-f.w));
    vec2 o;
    b(v-v);
    b(k.xy*.4); 
    b(k.xw*.8); 
    b(k.zy*.8); 
    f = texture2D(iChannel0, f.xy) + f.z;
}
*/

/* 294 chars ( mouse removed)
#define b(p) vec3(f.xy = length(v-p) * vec2(0.7),2e-3/dot(f.xy,f.xy));

void mainImage( out vec4 f, vec2 v )
{
    f.xy = iResolution.xy;
    v = (v+v-f.xy)/f.y;
    vec4 k = vec4(cos(f.w = iDate.w*.5),sin(f.w), 2.*cos(-f.w),.5*sin(-f.w));
     
    vec3 m = b(v-v);
    m += b(k.xy*.4);  
    m += b(k.xw*.8);  
    m += b(k.zy*.8); 
   
    f = texture2D(iChannel0, m.xy) + m.z;
}
*/ 

/* original 483 chars
vec3 mBallWarp(vec2 uv, vec2 pos, float radius)
{
   	uv = length(uv-pos) * vec2(0.7);
	return vec3(uv,radius/dot(uv,uv));
}

void mainImage( out vec4 f, in vec2 v )
{
    float 
        t = iGlobalTime*1.,
        r = 2e-3,
    	z = 1.;
    
    vec2 
        s = iResolution.xy,
        mo = (2.*iMouse.xy-s)/s.y * z;
    
    v = (v+v-s)/s.y * z;
    
	
    vec3 mb = mBallWarp(v, vec2(0.), r);  
    mb += mBallWarp(v, vec2(cos(t),sin(t))*.4, r);  
    mb += mBallWarp(v, vec2(cos(-t),0.5*sin(-t))*.8, r);  
    mb += mBallWarp(v, vec2(2.*cos(-t),sin(t))*.8, r); 
    
    if (iMouse.z > 0.)
		mb += mBallWarp(v, mo, r);  
    
    f = texture2D(iChannel0, mb.xy) + mb.z;
}
*/