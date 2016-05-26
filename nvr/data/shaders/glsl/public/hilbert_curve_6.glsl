// Shader downloaded from https://www.shadertoy.com/view/XljXW3
// written by shadertoy user FabriceNeyret2
//
// Name: Hilbert curve 6
// Description: a variant of https://www.shadertoy.com/view/XljSW3
//    
//    Sorry for the aliasing: shadertoy can't evaluate mipmap correctly at jumps. I had to force bias at -5) 
#define plot(U,l) ( dot(U,l) > 0. ?  abs( dot(U , vec2(-l.y,l.x)) ) : 0. )
#define plotC(U,l)  abs( length(U-(l)/2.) - .5 )
#define ang(U,P) atan(U.y-P.y,U.x-P.x) / 1.57

void mainImage( out vec4 o,  vec2 U )
{
    o = vec4(0.0);
    U /= iResolution.y; U.x -= .3; U+=1e-5; // or bug at depth 2. why ?
    vec2 P = vec2(.5), I=vec2(1,0),J=vec2(0,1), fU, l=-I,r=l, k; //,N=vec2(0); 
    float s = 1.,S=1.,T=0.,n,u,v, t=iGlobalTime;  //  mat2 R = mat2(0,-1,-1,0);
    
    for (float i=0.; i<10.; i++) {
        if (i > mod(t,7.) ) break;
        fU = step(.5,U);         // select child
        bvec2 c = bvec2(fU);     
        U = 2.*U - fU;           // go to new local frame
        n = (1.-fU.x)*(1.-fU.y)+fU.x*(2.+fU.y); // local index of nodes
        T = 4.*T +  n *S +(1.-S)*1.5;           // global indexing
        u =   (n==0.) ? 1.-ang(U,vec2(0)) // put after the loop ?
            : (n==1.) ? 2.+ang(U,vec2(1))
            : (n==2.) ? 1.+ang(U,  J  )
            :           2.-ang(U,  I  ) ;
        u = u*S +(1.-S)/2.;          // local curvilinear coordinate (T+u = continuous index)
        l = c.x ? c.y ? -J : -I            // node left segment
                : c.y ?  l :  J;
        r = (c.x==c.y)?  I : c.y ?-J:J;    // node right segment
        // the heart of Hilbert curve : 
        if (c.x) { U.x = 1.-U.x;  l.x=-l.x;  r.x=-r.x;  k=l;l=r;r=k; S=-S; } // sym
        if (c.y) { U   = 1.-U.yx; l  =-l.yx; r  =-r.yx; }  // .5+(U-.5)*R    // rot+sym        
        s*=2.; 
    }
    v = length(l+r) > 0. ? plotC (U-P, l+r) : plot (U-P, l) + plot (U-P, r); // axial coordinate
    if (dot(l,r)!=0.) u= dot(U*S+(1.-S)/2.,r);                // complete curvilinear coordinate
    o += smoothstep(.33+.01*log2(s),.33-.01*log2(s),v);       // ribbon mask
  //o += smoothstep(.33+.03*log2(s),.33-.03*log2(s), length( vec2(.5*(fract(u-iGlobalTime)*2.-1.),v) ));
  //o *= texture2D(iChannel0,vec2(u-t,v),-5.); // without texture2DLod
    o *= texture2DLodEXT(iChannel0,vec2(u-t,v),log2(s*iChannelResolution[0].y/iResolution.y));
  //o *= (T+u)/s/s;  //vec4(N,s-N)/s;
  //o *= .6+.4*sin(10.*(T+u)-3.*iGlobalTime);
    
    fU = min(U,1.-U);  if (min(fU.x,fU.y) < 0.) o*=0.;        // clamp
}