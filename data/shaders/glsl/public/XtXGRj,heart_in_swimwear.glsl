// Shader downloaded from https://www.shadertoy.com/view/XtXGRj
// written by shadertoy user eiffie
//
// Name: Heart in Swimwear
// Description: Embarrassingly my heart still thinks it can fit into summer clothes after gaining winter weight.
//heart in swimwear by eiffie
//coloring idea from iq's https://www.shadertoy.com/view/XsfGRn
//gradient idea from miloyip's https://www.shadertoy.com/view/XtXGR8

#define time iGlobalTime
#define size iResolution

vec3 mcol;
bool bColoring=false;
#define pi 3.14159
float DE(in vec3 p){
	float h=p.x*p.x+p.y*p.y+2.0*p.z*p.z-1.0,pyyy=p.y*p.y*p.y;
	float v=h*h*h-(p.x*p.x-0.1*p.z*p.z)*pyyy;//the messed up bit
	vec3 g=vec3(6.0*p.x*h*h-2.0*p.x*pyyy,
		6.0*p.y*h*h-3.0*p.x*p.x*p.y*p.y-0.3*p.z*p.z*p.y*p.y,
		12.0*p.z*h*h-0.2*p.z*pyyy);
	if(bColoring){
		h-=(p.x*p.x-0.1*p.z*p.z)*pyyy;
		if(h<0.0)mcol=vec3(1.0,0.15,0.2);else mcol=vec3(1.0,0.0,1.0);
		mcol=mix(vec3(0.5,0.0,0.0),mcol,clamp(abs(h+0.04)*20.0,0.0,1.0));
	}
	return v/max(0.2,length(g));
}

float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
float rndStart(vec2 fragCoord){
	return 0.5+0.5*rnd(fragCoord.xy+vec2(time*217.0));
}
vec3 Sky(vec3 rd){//what sky??
	return vec3(0.7,0.8,1.0)*(0.5+0.5*rd.y);
}
vec3 L;
vec3 Color(vec3 ro, vec3 rd, float t, float px, vec3 col){
	ro+=rd*t;
	bColoring=true;float d=DE(ro);bColoring=false;
	vec2 e=vec2(px*t,0.0);
	vec3 dn=vec3(DE(ro-e.xyy),DE(ro-e.yxy),DE(ro-e.yyx));
	vec3 dp=vec3(DE(ro+e.xyy),DE(ro+e.yxy),DE(ro+e.yyx));
	vec3 N=(dp-dn)/(length(dp-vec3(d))+length(vec3(d)-dn));
	vec3 R=reflect(rd,N);
	vec3 lc=vec3(1.0,0.9,0.8),sc=mcol,rc=Sky(R);
	if(sc.b>0.5){
		vec3 p=ro;p.y-=0.44;
		float a = atan(p.x,p.y)/3.141593;
    		float r = length(p);
    		float h = abs(a);
    		h = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);
		sc.g=0.25+0.25*sin((h-r)*100.0);
	}
	float h=0.2*dot(N,R);
	sc*=vec3(0.8+h,1.0,0.8-h);
	float sh=1.0;//clamp(shadao(ro,L,px*t)+0.2,0.0,1.0);
	sh=sh*(0.5+0.5*dot(N,L)+abs(rd.y)*0.2);
	vec3 scol=sh*lc*(sc+rc*pow(max(0.0,dot(R,L)),4.0));
	col=mix(scol,col,clamp(d/(px*t),0.0,1.0));
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float px=1.6/size.y;
	L=normalize(vec3(0.4,0.8,-0.6));
	float tim=time*0.5;
	
	vec3 ro=vec3(cos(tim),sin(tim*0.4)*0.25,sin(tim))*5.0;
	vec3 rd=lookat(vec3(-0.1)-ro)*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,3.0));
	
	float t=DE(ro)*rndStart(fragCoord),d=0.0,dm=10.0,tm=0.0;
	vec3 col=Sky(rd);
	for(int i=0;i<64;i++){
		t+=d;
		d=DE(ro+rd*t);
		if(d<dm){dm=d;tm=t;}
		if(t>10.0 || d<0.0001)break;
	}
	col=Color(ro,rd,tm,px,col);
	fragColor = vec4(1.5*col,1.0);
}
