// Shader downloaded from https://www.shadertoy.com/view/XsSGzG
// written by shadertoy user iapafoto
//
// Name: 40th Anniversary
// Description: Utah teapot / 1974 => 2014<br/>[mouse drag available]
/* Created by Sebastien Durand - 2014 */                 #define G(a,b) for(int i=0;i<a;i+=b)
/*     License  Creative Commons      */                     #define U(a,b) (a.x*b.y-b.x*a.y)
/*     Attribution-NonCommercial      */                                  #define N normalize
/*   ShareAlike 3.0 Unported License. */                                      #define F float
                                                                               #define W vec3
                                                                               #define V vec2
                                       V R=V(-1.16
                                        ,.63),Q=V 
			                             (1,.72)
			              ;W L=N(W(Q,1)),Y=W(0,.4,0),E=Y*.001,
                       P,O;V A[15];V T[4];F K;F B(V m,V n,V o){V                     q=P.xy;
                      m-=q;n-=q;o-=q;F x=U(m,o),y=2.*U(n,m),z=2.*U                (o,n);V
      i=o-m,j=o-n,k=n-m,s=2.*(x*i+y*j+z*k),r=m+(y*z-x*x)*V(s.y,-s.x)            /dot(s,s
    );K=clamp((U(r,i)+2.*U(k,r))/(x+x+y+z),0.,1.);r=m+K*(k+k+K*(j-k))          ;return         
  sqrt(           dot(r,r)+P.z*P.z);}F M(W p){P=p+O;F a=9.,r=length(P),        b=min( 
 min(B           (V(-.6,.78),V(-1.16,.84),R),B(R,V(-1.2,.42),V(-.72,.24       )))-.06
 ,max(           P.y-.9,min(abs(B(V(1.16,.96),V(1.04,.9),Q)-.07)-.01,B(Q,    V( .92,
 .48),          V(.72,.42))*(1.-.75*K)-.08)));P=W(r*sin(acos(P.y/r)),P.y,  0);G(13,
  2)a=         min(a,(B(A[i],A[i+1],A[i+2])-.02)*.8);return a<b?a:b;}void mainImage
  (out        vec4 o,vec2 x){T[0]=V(201616.,40100.);T[1]=V(151620.2,313016.1);T[2
   ]=V(       214.14,353432.3);T[3]=V(5.04,4040.39);G(15,1)A[i]=V(4,3)*fract(T[i/
    4]/pow   (100.,F(i-4*(i/4))));V r=iResolution.xy,m=iMouse.xy/r,p=(2.*x-r)/r
      .y; F s=.3,h,t=3.*(iGlobalTime+m.x);O=3.*W(cos(t),.7-m.y,sin(t)); W c=W(
        .8-s*length(p)),w=N(Y-O),u=N(cross(w,Y)),d=N(p.x*u+p.y*cross(u,w)+w+w
          );t=0.;G(99,1)if((t+=h=.6*M(d*t))>5.)break;if(h<E.y){O+=t*d;w=N(W
           (M(E.yxx),M(E),M(E.xxy))-M(W(0)));G(18,1)s=min(s,M(L*(h+=.02))/
              h);c=mix(c,mix(Y*(s>0.?3.*s+2.:2.),W(pow(max(dot(reflect(L
                  ,w), d),0.), 99.)), .3), dot(w,-d)); } o.grb = c ;}