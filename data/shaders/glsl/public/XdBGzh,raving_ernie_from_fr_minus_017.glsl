// Shader downloaded from https://www.shadertoy.com/view/XdBGzh
// written by shadertoy user BeRo
//
// Name: Raving ernie from fr-minus-017
// Description: The raving ernie guy from fr-minus-017: coderp0rn by BeRo from farbrausch&lt;br/&gt;&lt;br/&gt;Reflection commented out for WebGL instruction count limit of ANGLE&lt;br/&gt;The head of the ernie model simplifed for WebGL instruction count limit of ANGLE&lt;br/&gt;
// The raving ernie guy from fr-minus-017: coderp0rn by BeRo from farbrausch
// A bit stripped-down version for WebGL without camera envelope uniforms etc.
// (so hardcoded camera here)
// Reflection commented out for WebGL instruction count limit of ANGLE
// The head of the ernie model simplifed for WebGL instruction count limit of ANGLE
// Changelog:
// 2013/11/02 iq's changes applied and removed head code as commented out code readded

#define time (iGlobalTime*2.0)
#define tczu (iGlobalTime*8.0)

const float e1=6.0; // raving speed

const int maxSteps=64;
const int shadowSteps=32;
const float maxDistance=64.0;
const float PI=3.14159265358979323846264;

vec3 safenormalize(vec3 n){ // div-by-zero-safe-replacement for normalize (anti-black-pixel-workaround)
 	float l=length(n);
	return (abs(l)>1e-10)?(n/l):n;	
}

float _union(float a,float b){
  return min(a,b);
}

float _union(float a,float b,inout float m,float nm){
  m=(b<a)?nm:m;
  return min(a, b);		
}

float intersect(float a,float b){
  return max(a,b);
}

float difference(float a,float b){
  return max(a,-b);
}                                                                

float hash(float n){
  return fract(sin(n)*43758.5453123);
}

vec3 rotateX(vec3 p,float a){
  vec2 cs=vec2(cos(a),sin(a));
  return vec3(p.x,(cs.x*p.y)-(cs.y*p.z),(cs.y*p.y)+(cs.x*p.z));
}

vec3 rotateY(vec3 p,float a){
  vec2 cs=vec2(cos(a),sin(a));
  return vec3((cs.x*p.x)+(cs.y*p.z),p.y,(cs.x*p.z)-(cs.y*p.x));
}

vec3 rotateZ(vec3 p,float a){
  vec2 cs=vec2(cos(a),sin(a));
  return vec3((cs.x*p.x)+(cs.y*p.y),(cs.x*p.y)-(cs.y*p.x),p.z);
}

float sdPlane(vec3 p,vec4 n){
  return dot(p,n.xyz)+n.w;
}

float plane(vec3 p,vec3 n,vec3 pointOnPlane){	
  return dot(p,n)-dot(pointOnPlane,n);
}

float edge(vec3 p,vec2 a,vec2 b){
  vec2 e=b-a;
  vec3 n=normalize(vec3(e.y,-e.x,0.0));
  return plane(p,n,vec3(a,0.0));
//return intersect(plane(p,n,vec3(a,0.0)),plane(p,-n,vec3(a,0.0))-0.1);
}

float sdBox(vec3 p,vec3 b){
  vec3 di=abs(p)-b;
  float mc=max(di.x,max(di.y,di.z));
  return min(mc,length(max(di,0.0)));
}

float sdCylinder(vec3 p,vec3 c){
  return length(p.xz-c.xy)-c.z;
}

float sphere(vec3 p,float r){
  return length(p)-r;
}

float box(vec3 p,vec3 bmin,vec3 bmax){
  return sdBox(p-((bmin+bmax)*0.5),(bmax-bmin)*0.5);
}

vec3 closestPtPointSegment(vec3 c,vec3 a,vec3 b,out float t){
  vec3 ab=b-a;
  t=clamp(dot(c-a,ab)/dot(ab,ab),0.0,1.0);
  return a+(t*ab);
}

float capsule(vec3 p,vec3 a,vec3 b,float r){
  float t;
  vec3 c=closestPtPointSegment(p,a,b,t);
  return length(c-p)-r;
}

float cylinder(vec3 p,vec3 a,vec3 b,float r){
  vec3 ab=b-a;
  vec3 c=a+((dot(p-a,ab)/dot(ab,ab)))*ab;
  float d=length(c-p)-r;
  vec3 n=normalize(ab);
  return intersect(intersect(d,plane(p,n,b)),plane(p,-n,a));
}

float sdCone(vec3 p,vec2 c){
  float q=length(p.xy);
  return dot(c,vec2(q,p.z));
}

float sdTorus(vec3 p, vec2 t){
  vec2 q=vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float torus(vec3 p,float r,float r2){
  return sdTorus(p,vec2(r,r2));	
}

float cone(vec3 p,vec3 a,float baseR,vec3 b,float capR){
  vec3 ab=b-a;
  float t=dot(p-a,ab)/dot(ab,ab);
  //t = clamp(t, 0.0, 1.0);
  vec3 c=a+(t*ab);	
  float r=mix(baseR,capR,t);
  float d=(length(c-p)-r)*0.5;
  vec3 n=normalize(ab);
  return intersect(intersect(d,plane(p,n,b)),plane(p,-n,a));
}

vec2 sdSegment(vec3 a,vec3 b,vec3 p){
  vec3 pa=p-a;
  vec3 ba=b-a;
  float h=clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
  return vec2(length(pa-(ba*h)),h);
}

float bein(vec3 p,float b,inout float m){
  float d;
  m=1.0;
  d=sdSegment(vec3(-0.5,b,0.0),vec3(-(0.625-(b*0.5)),0.0,0.25),p).x-0.25;
  d=_union(d,sdSegment(vec3(-0.5,b,0.0),vec3(-0.4,1.0+b,b),p).x-0.1,m,2.0);
  d=_union(d,sdSegment(vec3(-0.4,1.0+b,b),vec3(-0.3,2.0+b,0.0),p).x-0.2,m,3.0);
  return d;
}

float oberkoerper(vec3 p,float b,inout float m){
  float d;
  m=3.0;
  d=sdSegment(vec3(0.0,2.0+b,0.0),vec3(0.0,2.25+b,-b*0.5),p).x-0.45;
  d=_union(d,sdSegment(vec3(0.0,2.25+b,-b*0.5),vec3(0.0,3.25+b,0.0),p).x-0.5,m,4.0);
  return d;
}

float arm(vec3 p,float b,inout float m){
  float d;
  m=4.0;
  vec3 l=vec3(-(0.75+(b*0.25)),2.75+b,0.0);
  vec3 l2=vec3(-(0.75+(b*0.95)),3.25+b-(b*0.25),1.0);
  vec3 l3=vec3(-(0.75+(b*0.95)),3.25+b-(b*0.25),1.25);
  d=sdSegment(vec3(-0.375,3.25+b,0.0),l,p).x-0.2;
  d=_union(d,sdSegment(l,l2,p).x-0.1,m,2.0);
  d=_union(d,sdSegment(l2,l3,p).x-0.2,m,2.0);
  return d;
}

float kopf(vec3 p,float b,inout float m){
  float d;
  float tcz=tczu*e1;
  vec3 bv=vec3(0.0,4.0+b,0.0);
  
  m=2.0;
  d=sdSegment(vec3(0.0,3.25+b,0.0),bv,p).x-0.2;

  p-=bv;
  p=rotateY(p,(b*0.25)+((sin(tcz/32.0*PI)*1.0*PI)*0.1));
  p=rotateZ(p,(b*0.125)+((sin(tcz/64.0*PI)*1.0*PI)*0.1));
  p=rotateX(p,(b*0.75)+((sin(tcz/8.0*PI)*1.0*PI)*0.1));
  p+=bv;

  d=_union(d,sphere(p-vec3(0.0,4.25+b,0.0),0.5));
  /*d=_union(d,sphere(p-vec3(0.0,4.75+b,0.0),0.25),m,1.0);
  
  d=_union(d,sphere(p-vec3(-0.45,4.25+b,0.0),0.175),m,2.0);
  d=_union(d,sphere(p-vec3(0.45,4.25+b,0.0),0.175),m,2.0);

  d=_union(d,sphere(p-vec3(0.0,4.25+b,0.5),0.125),m,2.0);

  d=_union(d,sdSegment(vec3(-0.125,4.0+b,0.5),vec3(0.125,4.0+b,0.5),p).x-0.075,m,5.0);
  d=_union(d,sdSegment(vec3(-0.125,4.0+b,0.585),vec3(0.125,4.0+b,0.585),p).x-0.025,m,1.0);

  d=_union(d,sphere(p-vec3(0.125,4.4+b,0.5),0.125),m,4.0);
  d=_union(d,sphere(p-vec3(-0.125,4.4+b,0.5),0.125),m,4.0);

  d=_union(d,sphere(p-vec3(0.125,4.4+b,0.6),0.075),m,1.0);
  d=_union(d,sphere(p-vec3(-0.125,4.4+b,0.6),0.075),m,1.0);
  
  d=_union(d,sphere(p-vec3(-0.25,4.75+b,0.0),0.25),m,1.0);
  d=_union(d,sphere(p-vec3(0.25,4.75+b,0.0),0.25),m,1.0);
  d=_union(d,sphere(p-vec3(-0.25,4.75+b,-0.25),0.25),m,1.0);
  d=_union(d,sphere(p-vec3(0.25,4.75+b,-0.25),0.25),m,1.0);
  d=_union(d,sphere(p-vec3(-0.25,4.75+b,0.25),0.25),m,1.0);
  d=_union(d,sphere(p-vec3(0.25,4.75+b,0.25),0.25),m,1.0);*/
  return d;
}


vec4 scene(vec3 p){
  float tcz=tczu*e1;
  float d=1e+8,d1=1e-14,d2=1e-14;
  float b=tcz/64.0,t=(1.0+pow(sin(b*4.0*PI),2.0))*0.5*0.25,s=(sin(time*8.0*PI)*0.5*t),m=0.0,m1=0.0,m2=0.0;

  p+=vec3(0.0,1.5,0.0);                

  vec3 q = vec3( -abs(p.x), p.yz );

  d1=sdPlane(p,vec4(0.0,1.0,0.0,0.0)); 
  d1=_union(d1,sdPlane(p+vec3(0.0,0.0,10.0),vec4(0.0,0.0,1.0,0.0)),m1,1.0); 
  d1=_union(d1,sdPlane(p+vec3(0.0,0.0,-10.0),vec4(0.0,0.0,-1.0,0.0)),m1,1.0); 
  d1=_union(d1,sdPlane(q+vec3(10.0,0.0,0.0),vec4(1.0,0.0,0.0,0.0)),m1,1.0); 
  d1=_union(d1,sdPlane(p+vec3(0.0,-10.0,0.0),vec4(0.0,-1.0,0.0,0.0)),m1,1.0);
  
  float beinY=((sin((tcz/8.0)*PI)*0.5)+0.5)*0.5;

  m=1.0;

  float bd=0.0;

  d=bein(q,beinY,m);

  d2=oberkoerper(p,beinY,m2);
  d=_union(d,d2,m,m2);

  d2=arm(q,beinY,m2);
  d=_union(d,d2,m,m2);

  d2=kopf(p,beinY,m2);
  d=_union(d,d2,m,m2);

  d=_union(d,d1,m,m1);  

  return vec4(d,m,0.0,0.0);
}

vec3 sceneNormal(vec3 pos){
  float eps=1e-5,d=scene(pos).x;
  return safenormalize(vec3(scene(vec3(pos.x+eps,pos.y,pos.z)).x-d,
                            scene(vec3(pos.x,pos.y+eps,pos.z)).x-d,
														scene(vec3(pos.x,pos.y,pos.z+eps)).x-d));
}

float ambientOcclusion(vec3 p,vec3 n){
  const int steps=3;
  const float delta=0.5;
  float a=0.0,weight=1.0;
  for(int i=1;i<=steps;i++){
    float d=(float(i)/float(steps))*delta; 
    a+=weight*(d-scene(p+(n*d)).x);
    weight*=0.5;
  }
  return clamp(1.0-a,0.0,1.0);
}

float softShadow(vec3 ro,vec3 rd,float mint,float maxt,float k){
  float dt=(maxt-mint)/float(shadowSteps),t=mint+(hash((ro.z*574854.0)+(ro.y*517.0)+ro.x)*mint*0.25),r=1.0;
  for(int i=0;i<shadowSteps;i++){
    float h=scene(ro+(rd*t)).x;
    if(h<(t*0.003)){
      return 0.0;	
    } 
    r=min(r,(k*h)/t);
    t+=dt;
  }
  return clamp(r,0.0,1.0);
}                

vec3 lightShade(vec3 pos,vec3 n,vec3 eyePos,vec3 mc,vec3 lc,vec3 lp,float shininess){
  vec3 l=lp-pos;
  float ld=length(l);
  if(abs(ld)>1e-10){ 
    l/=ld;
  } 
  vec3 v=safenormalize(eyePos-pos),h=safenormalize(v+l);
  float d=dot(n,l);
  float dnh=dot(n,h);
  return vec3((((max(0.0,d)*0.5)+0.5)*mix(0.5,1.0,softShadow(pos,l,0.1,ld,10.0)))*mc*lc)+vec3(max(0.0,(dnh>0.0)?pow(dnh,shininess):0.0)*float((d>0.0)&&(shininess<32768.0)));
}

vec3 sky(vec3 rd){
  return mix(vec3(0.2,0.3,0.0),vec3(0.3,0.6,1.0),(rd.y*0.5)+0.5);
}

vec3 shade(vec3 pos,vec3 n,vec3 eyePos,float m){
  float s=128.0;
  s=mix(s,65535.0,clamp(m,0.0,1.0));
  vec3 color=vec3(0.25);
  color=mix(color,vec3(0.125),clamp(m,0.0,1.0));
  color=mix(color,vec3(0.75,0.6,0.0625),clamp(m-1.0,0.0,1.0));
  color=mix(color,vec3(0.125,0.125,0.75),clamp(m-2.0,0.0,1.0));
  color=mix(color,vec3(1.0,1.0,1.0),clamp(m-3.0,0.0,1.0));
  color=mix(color,vec3(1.0,0.25,0.125),clamp(m-4.0,0.0,1.0));
  float ao=ambientOcclusion(pos,n);
  vec3 c=ao*((sky(n)*0.125)+(color*0.125));
  float tcz=tczu*0.5;
  float r=mod(tcz*(1.0/2.0),3.0);
  if(r<1.0){
    c+=lightShade(pos,n,eyePos,color,vec3(1.0,0.25,0.25),vec3(cos(time*4.0*PI)*5.0,1.0,sin(time*4.0*PI)*5.0),s)*((sin((tcz/8.0)*PI*2.0)*0.5)+0.5);
  }else if(r<2.0){
    c+=lightShade(pos,n,eyePos,color,vec3(0.25,1.0,0.25),vec3(cos(time*2.0*PI)*5.0,1.0,sin(time*2.0*PI)*5.0),s)*((sin(time*PI*2.0)*0.5)+0.5);
  }else{
   c+=lightShade(pos,n,eyePos,color,vec3(0.25,0.25,1.0),vec3(cos(time*1.0*PI)*5.0,1.0,sin(time*1.0*PI)*5.0),s)*((sin(time*PI*1.0)*0.5)+0.5);
  }
  return c;
}

vec4 trace(vec3 ro,vec3 rd){
  vec3 hp=ro,p=ro;	 
  float m=-1.0;
  for(int i=0;i<maxSteps;i++){
    vec2 v=scene(p).xy;
	if(v.x<0.001){
      hp=p;
	  m=v.y;
    }
	p+=rd*v.x;
  }
  return vec4(hp,m);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 pixel=-1.0+(2.0*(fragCoord.xy/iResolution.xy));
  float asp=iResolution.x/iResolution.y,m=0.0,roty=0.0,rotx=0.0;
  vec3 rd=vec3(0.0),ro=vec3(0.0),c=vec3(0.0);
  rd=normalize(vec3(asp*pixel.x,pixel.y,-2.0));
  ro=vec3(0.0,1.5,8.0);
  roty=(sin(time*PI*0.125)*0.5);
  rotx=(cos(time*PI*0.5)*0.25)-0.25;
  rd=rotateY(rotateX(rd,rotx),roty);
  ro=rotateY(rotateX(ro,rotx),roty);
  vec4 ph=trace(ro,rd);
  vec3 pos=ph.xyz;
  m=ph.w;	
  if(m>=0.0){
    vec3 n=sceneNormal(pos);   
    c+=shade(pos,n,ro,m);
   /*/
  // Reflection commented out for WebGL
    if(m==0.0){
      vec3 v=safenormalize(ro-pos);
      ro=pos+(n*0.01); 
      rd=reflect(-v,n);
      ph=trace(ro,rd);
      pos=ph.xyz;
      m=ph.w;	
      if(m>=0.0){
        c+=shade(pos,sceneNormal(pos),ro,m)*vec3(0.1+(0.4*pow(max(0.0,1.0-dot(n,v)),5.0)));
      }
    }/**/
  }
  fragColor=vec4(c,1.0);
} 	
