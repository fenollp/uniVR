// Shader downloaded from https://www.shadertoy.com/view/4tfGRl
// written by shadertoy user eiffie
//
// Name: Stairway to Heaven Curve
// Description: One can only guess the hidden meaning of this symbol. (Must be satanic.)
//Stairway to Heaven Curve by eiffie

#define rpm1 1.0
#define rpm2 -0.666
#define radius1 0.666
#define radius2 0.666
#define len1 2.0
#define len2 2.0

#define PI 3.14159

#define time iGlobalTime
#define size iResolution
#define tex iChannel0

vec3 P1,P2,P3;
vec2 polarToCart(float a, float r){return r*vec2(cos(a),sin(a));}
vec2 TT1(float t){return vec2(-1.0,0.0)+polarToCart(t/10.0*rpm1*2.0*PI,radius1);}
vec2 TT2(float t){return vec2(1.0,0.0)+polarToCart(t/10.0*rpm2*2.0*PI,radius2);}
vec2 jsolve( vec2 a, vec2 b, float l1, float l2 ){//joint solver by iq
	vec2 p=b-a,q=p*0.5;//( 0.5 + 0.5*(l1*l1-l2*l2)/dot(p,p) );//put this back if arms are dif lens
	return a+q+sqrt(max(0.0,l1*l1 - dot(q,q)))*normalize(vec2(-p.y,p.x));
}

vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
float Tube(vec3 pa, vec3 ba){float h=dot(pa,ba)/dot(ba,ba);return length(pa-ba*clamp(h,0.0,1.0));}
int id=0;
float prop;
float DE(in vec3 p0){
	vec3 p=p0;
	float a1=Tube(p-P1,P3-P1);
	float a2=Tube(p-P2-vec3(0.0,0.05,0.0),P3-P2);
	float arms=min(a1,a2)-0.03;
	float pen=max(abs(p.y)-0.2,min(length(p.xz-P1.xz),min(length(p.xz-P2.xz),length(p.xz-P3.xz)))-0.02);
	p.x=abs(p.x)-1.0;
	float r=length(p.xz);
	float plate=max(r-0.9,abs(p.y)-0.04);
	p.y-=0.05;
	pen=min(pen,length(p)-0.025);
	float flr=p0.y+0.05;
	if(id<0){
		if(pen<plate && pen<arms && pen<flr)id=1;
		else if(plate<arms && plate<flr){id=2;prop=r;}
		else if(arms<flr)id=3;
		else id=4;
	}
	return min(min(pen,flr),min(plate,arms));
}

float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
float rndStart(vec2 px){
	return 0.5+0.5*rnd(px+vec2(time*217.0));
}
vec3 Sky(vec3 rd){//what sky??
	return vec3(0.7,0.8,1.0)*(0.5+0.5*rd.y);
}
vec2 F(float t){
	vec2 p1=TT1(t),p2=TT2(t);
	return jsolve(p1,p2,len1,len2);
}
vec2 DF(vec2 p, float t){
	float d1=length(p-F(t)), dt=log(d1+1.0), d2=length(p-F(t+dt));
	dt/=max(d1-d2,0.14*dt);
	return vec2(min(d1,d2),0.75*log(d1*dt+1.0));
}

vec3 PhonographIt(vec2 p, float et, float px){
	float t=0.0,d=100.0;
	for(int i=0;i<32;i++){
		vec2 v=DF(p,t);
		t+=v.y;
		if(t>et)break;
		d=min(d,v.x);
	}
	d=smoothstep(0.0,4.0*px,d);
	float f=max(abs(p.x)-1.75,abs(p.y-1.75)-1.0);
	return mix(vec3(sqrt(d),d*d,d),texture2D(tex,p*0.2).rgb,smoothstep(0.0,px,f));
}
float shadao(vec3 ro, vec3 rd, float px, vec2 fragCoord){//pretty much IQ's SoftShadow
	float res=1.0,d,t=2.0*px*rndStart(fragCoord);
	for(int i=0;i<12;i++){
		d=max(px,DE(ro+rd*t)*1.5);
		t+=d;
		res=min(res,d/t+t*0.5);
	}
	return res;
}

vec3 L;
vec3 Color(vec3 ro, vec3 rd, float t, float px, vec3 col, vec2 fragCoord){
	ro+=rd*t;
	id=-1;float d=DE(ro);
	vec2 e=vec2(px*t,0.0);
	vec3 dn=vec3(DE(ro-e.xyy),DE(ro-e.yxy),DE(ro-e.yyx));
	vec3 dp=vec3(DE(ro+e.xyy),DE(ro+e.yxy),DE(ro+e.yyx));
	vec3 N=(dp-dn)/(length(dp-vec3(d))+length(vec3(d)-dn));
	vec3 R=reflect(rd,N);
	vec3 lc=vec3(1.0,0.9,0.8),sc,rc=Sky(R);
	if(id==1){sc=vec3(0.4);
	}else if(id==2){
		sc=mix(vec3(0.9,0.3,0.2),vec3(0.1),smoothstep(0.29,0.31,prop));
		if(prop>0.3)N.x+=sin((prop+sin(-2.0+prop))*60.0)*0.5;
	}else if(id==3)sc=vec3(0.8,0.7,0.5);
	else sc=col;
	float h=0.2*dot(N,R);
	sc*=vec3(0.8+h,1.0,0.8-h);
	float sh=clamp(shadao(ro,L,px*t,fragCoord)+0.2,0.0,1.0);
	sh=sh*(0.5+0.5*dot(N,L)+abs(rd.y)*0.2);
	vec3 scol=sh*lc*(sc+rc*pow(max(0.0,dot(R,L)),4.0));
	col=mix(scol,col,clamp(d/(px*t),0.0,1.0));
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
void init(float t){
	vec2 p1=TT1(t),p2=TT2(t),p3=jsolve(p1,p2,len1,len2);
	P1=vec3(p1.x,0.1,p1.y);
	P2=vec3(p2.x,0.1,p2.y);
	P3=vec3(p3.x,0.1,p3.y);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float px=1.0/size.y;
	L=normalize(vec3(0.4,0.8,-0.6));
	init(time);
	float tim=time*0.5;
	vec3 ro=vec3(cos(tim*0.3)*3.0,2.5+sin(tim*0.4)*0.25,-2.0);
	vec3 rd=lookat(vec3(0.0,0.0,0.666)-ro)*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,3.0));
	//ro=eye;rd=normalize(dir);
	float t=DE(ro)*rndStart(fragCoord),d=0.0,od=10.0;
	vec3 col=Sky(rd);
	float tG=-(0.05+ro.y)/rd.y,tMAX=10.0;
	if(tG>0.0){tMAX=min(tMAX,tG+0.1);col=PhonographIt(ro.xz+rd.xz*tG,time,px*tG);}
	vec3 edge=vec3(-1.0);
	bool bGrab=false;

	for(int i=0;i<64;i++){
		t+=d;
		d=DE(ro+rd*t);
		if(d>od){
			if(bGrab && od<px*t && edge.x<0.0){
				edge=vec3(edge.yz,t-od);
				bGrab=false;
			}
		}else bGrab=true;
		od=d;
		if(t>tMAX || d<0.0001)break;
	}
	if(d<px*t && t<1000.0){
		if(edge.x>0.0)edge=edge.yzx;
		edge=vec3(edge.yz,t);
	}
	for(int i=0;i<3;i++){
		if(edge.z>0.0)col=Color(ro,rd,edge.z,px,col,fragCoord);
		edge=edge.zxy;
	}
	fragColor = vec4(1.5*col,1.0);
}
