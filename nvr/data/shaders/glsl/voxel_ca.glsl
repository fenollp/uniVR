// Shader downloaded from https://www.shadertoy.com/view/XdGSRh
// written by shadertoy user akohdr
//
// Name: Voxel CA
// Description: Local rule automata viewed through voxel space.  State maintained in buffer loop of tiled 2D z-slices.
//    iMouse.x rotates and iMouse.y controls view culling.  Upper iMouse.y shows underlying 2D state space.
//    
// Created by Andrew Wild - akohdr/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// The Viewer - displays a voxel volume described by 2D tiled z-slices
//

//#define SINGLE_CELL
#define EYE 90
#define RES  iResolution.xy
#define FRES vec3(33,47,89)
#define FDIM vec3(floor(RES/FRES.xy),FRES.z)

bool isVoxel(out vec4 k, const in vec4 P)
{
    vec3 H = FRES/2.;
    //if(any(greaterThan(abs(P.xyz),H))) return false; 	// bounds check, kills repetition 
    vec4 p = P + vec4(H.xyz,0);  						// recenter volume in viewport
	float z = p.z, w = FDIM.x;							// inlined prj4Dto2D()
    vec2 p2 = FRES.xy * floor(vec2(mod(z,w),z/w)) + mod(p.xy,FRES.xy);

    k = texture2D(iChannel0, p2/RES);
    return k.x + k.y + k.z>3.*iMouse.y/RES.y;	// mouse controled culling
//    return k.x + k.y + k.z>0.;	// anything but black
}

void mainImage(out vec4 k, vec2 P)
{
    float Rx = iResolution.x, Ry = iResolution.y;
    
    if((iMouse.z>0.) && (iMouse.y>250.)){
        k = texture2D(iChannel0,P/RES); return;}  // show underlying state space
    
    //float T = 9.*iMouse.x/Rx;		// mouse rotate
    //float T = iGlobalTime/8.;		// slow rotate
    //float T = 2.;					// fixed view
	float T = iMouse.z>0. ? 5.*iMouse.x/Rx : iGlobalTime/6.;  //combo
    
    vec2 h = vec2(0,.5),
         u = (P - h*Ry)/Rx - h.yx;
    vec3 v = vec3(cos(T), 1, sin(T)),
         r = mat3(u.x,    0,   .8,
                    0,  u.y,    0,
                  -.8,    0,  u.x) * v,
         o = vec3(EYE,0,-EYE)*v.zyx,
         f = floor(o),
         q = sign(r),
         d = abs(length(r)/r),
         s = d * ( q*(f-o + .5) +.5), m;

    for(int i=0; i<256; i++) {
        float a=s.x, b=s.y, c=s.z;
        s += d*(m = vec3(a<b&&a<=c, b<c&&b<=a, c<a&&c<=b));
        f += m*q;
        
        if(isVoxel(k, vec4(f, T))) {
            k += m.x>.0 ? vec4(0) : m.y>.0 ? vec4(.6) : vec4(.3); return; }//early exit
    }
    //k = vec4(0,.2,.3,1);			// background
    k = texture2D(iChannel1, P/RES/3.)/3.;
}
