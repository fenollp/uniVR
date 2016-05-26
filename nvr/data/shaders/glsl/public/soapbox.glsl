// Shader downloaded from https://www.shadertoy.com/view/MdKGWW
// written by shadertoy user eiffie
//
// Name: Soapbox
// Description: Billy was sure the championship was his if he could just crack the code to the ideal wheel geometry.
//Soapbox by eiffie
//Testing the DE 2 DE collision. All buf A does is check the nearest distance between the wheels 
//and ground then try to "mush" the car to the ground.

#define PI 3.14159
#define X iGlobalTime
#define RT -iGlobalTime
#define bump 0.05

#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)

vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float DEW(in vec3 p, float A, float B, float C){//wheels
	float a=atan(p.x,-p.y);
	float b=a-mod(a+A*0.5,A)+A*0.5;
	float d=max(abs(p.z)-0.1,sin(b)*p.x-cos(b)*p.y-C+abs(a)*B);
	return d;
}

float Torus(in vec3 z, vec2 r){return length(vec2(length(z.zy)-r.x,z.x))-r.y;}
float Rect(in vec3 z, vec3 r){return max(abs(z.x)-r.x,max(abs(z.y)-r.y,abs(z.z)-r.z));}
float CapsuleY(in vec3 p, vec3 r){return length(vec3(p.x,p.y-clamp(p.y,r.x,r.y),p.z))-r.z;}

mat3 rmx;
vec2 XY;
float DE(in vec3 p0){//car
	vec2 g=sin(p0.xz+2.4*sin(p0.zx))*bump;
	float dG=p0.y+1.0+g.x+g.y;
	p0.xy+=XY;
	p0=rmx*p0;
	vec3 p=p0;
	const vec3 rc=vec3(2.0,0.5,1.0);
	float d=Rect(p,rc);
	p.y-=0.25;
	d=max(d,-Rect(p,rc-vec3(0.1,0.0,0.1)));
	p+=sin(p.yzx*2.0+2.3*sin(p.zxy*2.0+rc))*0.02;
	p.xy-=vec2(1.25,0.3);
	d=min(d,Rect(p,vec3(0.7,0.05,0.9)));
	p.xy+=vec2(0.75,0.2);
	d=min(d,Torus(p,vec2(0.5,0.05)));
	float s1=0.7,s2=-0.05,s3=0.5;
	vec3 o=vec3(-1.5,0.25,-1.25);
	if(p0.z<0.0){s1+=0.4;s2+=0.04;o.z=-o.z;if(p0.x>0.0)s3=0.25;}
	if(p0.x<0.0){s1+=0.4;s2+=0.04;o.x=-o.x;}
	p=p0+o;
	p.xy=rotate(p.xy,RT);
	d=min(d,DEW(p,s1,s2,s3));
	d=min(d,CapsuleY(p.xzy,vec3(-0.2,0.2,0.1)));
	return min(d,dG);
}

vec4 mcol=vec4(0.0);
float CE(in vec3 p0){ //same for coloring
	vec2 g=sin(p0.xz+2.4*sin(p0.zx))*bump;
	float d7=p0.y+1.0+g.x+g.y;
	vec3 p1=p0;
	p0.xy+=XY;
	p0=rmx*p0;
	mcol+=vec4(1.0);
	vec3 p=p0;
	const vec3 rc=vec3(2.0,0.5,1.0);
	float d=Rect(p,rc);
	p.y-=0.25;
	d=max(d,-Rect(p,rc-vec3(0.1,0.0,0.1)));
	p+=sin(p.yzx*2.0+2.3*sin(p.zxy*2.0+rc))*0.02;
	p.xy-=vec2(1.25,0.3);
	float d3=Rect(p,vec3(0.7,0.05,0.9));
	p.xy+=vec2(0.75,0.2);
	float d4=Torus(p,vec2(0.5,0.05));
	float s1=0.7,s2=-0.05,s3=0.5;
	vec3 o=vec3(-1.5,0.25,-1.25);
	if(p0.z<0.0){s1+=0.4;s2+=0.04;o.z=-o.z;if(p0.x>0.0)s3=0.25;}
	if(p0.x<0.0){s1+=0.4;s2+=0.04;o.x=-o.x;}
	p=p0+o;
	p.xy=rotate(p.xy,RT);
	float d5=DEW(p,s1,s2,s3);
	float d6=CapsuleY(p.xzy,vec3(-0.2,0.2,0.1));
	vec4 scol=vec4(1.0,0.0,0.0,1.0);
	if(min(d3,d5)<d){
		g=p0.xz;
		if(d5<d3){d=d5;g=p.xy;}else d=d3;
		scol=texture2D(iChannel1,g)*1.5;
        d+=scol.r*0.03;
	}
	if(d4<d || d6<d){
		d=min(d4,d6);
		scol=vec4(0.1,0.2,0.3,1.0);
	}
	if(d7<d){
		float n=texture2D(iChannel2,p1.xz).r;
		d=d7+n*0.03;
		scol=vec4(n+1.7+p1.y,0.4,-0.8-p1.y,n);
	}
	mcol+=scol;
	return d;
}

float ShadAO(in vec3 ro, in vec3 rd){
	float t=0.01,s=1.0,d,mn=t;
	for(int i=0;i<16;i++){
		d=max(DE(ro+rd*t)*1.25,mn);
		s=min(s,d/t+t);
		t+=d;
	}
	return s;
}
// Tetrahedral normal from IQ.
vec3 normal(vec3 p, float e){vec2 v=vec2(-e,e);return normalize(v.yxx*CE(p+v.yxx)+v.xxy*CE(p+v.xxy)+v.xyx*CE(p+v.xyx)+v.yyy*CE(p+v.yyy));}

vec3 scene(vec3 ro, vec3 rd, float rnd){
	float t=DE(ro)*rnd,d,px=1.0/iResolution.x;
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(t>100.0 || d<px*t)break;
	}
	vec3 col=vec3(0.9,0.95,1.4)*max(0.0,0.5+rd.y);
	if(d<15.0*px*t){
		ro+=rd*t;
		vec3 L=normalize(vec3(0.4,0.8,0.5));
		vec3 N=normal(ro,px*t);
		float dif=0.5+max(0.0,0.5*dot(N,L));
		float shad=(dif>0.0?ShadAO(ro,L):0.0);
		float spc=pow(max(0.0,dot(reflect(rd,N),L)),5.0);
		float fre=max(0.0,dot(rd,N));
		float amb=max(0.0,N.y);
		mcol/=4.0;
		vec3 scol=mcol.rgb*clamp((dif*(1.0-0.5*fre)+mcol.a*spc*fre)*shad+amb*0.1,0.0,1.0);
		col=mix(col,scol,exp(-t*0.06));
	}
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
mat3 lookup(vec3 up){
	vec3 fw=vec3(0.0,0.0,1.0),rt=vec3(1.0,0.0,0.0);
	rt=normalize(cross(fw,up));
	fw=normalize(cross(up,rt));
	return mat3(rt,up,fw);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec4 up=load(0);
	XY=vec2(X,up.w);
	rmx=lookup(up.xyz);
	float rnd=fract(sin(dot(fragCoord,vec2(13.45,75.23)))*435.13);
	float tim=iGlobalTime*0.4;
	vec3 ro=vec3(cos(tim)*6.0-X,1.0+sin(tim*0.13)*0.5,sin(tim)*4.0);
	vec3 rd=vec3((2.0*fragCoord-iResolution.xy)/iResolution.x,1.0);
	rd=normalize(lookat(vec3(-X,0.0,0.0)-ro-XY.yyy)*rd);
	fragColor=vec4(scene(ro,rd,rnd),1.0);
}