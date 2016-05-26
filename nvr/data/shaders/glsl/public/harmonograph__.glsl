// Shader downloaded from https://www.shadertoy.com/view/Xls3zf
// written by shadertoy user eiffie
//
// Name: Harmonograph??
// Description: So I search harmonograph and see it described one way but then find a picture of this little cutie which seems to work differently. I wanted to see what pictures it draws. Don't ask how the paper stays horizontal. I just didn't want to calc the pen height
//Harmonograph?? by eiffie

#define time iGlobalTime
#define size iResolution
#define tex iChannel0

#define penAmpX 0.56
#define penAmpY 0.45
#define penFreq 1.0
#define penPhase 0.0
#define penDamp 0.01
#define paperAmpX -0.81
#define paperAmpY 0.45
float paperFreq=0.66;
#define paperPhase 0.3
#define paperDamp 0.01
#define TAO 6.283

vec2 penPos(float t){float a=t*penFreq*TAO+penPhase;return vec2(penAmpX*cos(a),penAmpY*sin(a)*exp(-t*penDamp));}
vec2 paperPos(float t){float a=t*paperFreq*TAO+paperPhase;return vec2(paperAmpX*cos(a),paperAmpY*sin(a)*exp(-t*paperDamp));}

vec3 pen,paper;
void init(float t){
	float c=1.0+floor(t/20.0);
	c=mod(c,5.0);
	if(c==3.0)c=-1.0;
	t=mod(t,20.0);
	paperFreq=c/3.0+0.01;
	vec2 pn=penPos(t),pp=paperPos(t);
	pen=normalize(vec3(pn.x,5.0,pn.y));
	paper=normalize(vec3(pp.x,5.0,pp.y));
}

vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
vec2 kaleido(vec2 v, float power){return rotate(v,floor(.5+atan(v.x,-v.y)*power/TAO)*TAO/power);}
vec2 Tube(vec3 pa, vec3 ba){float h=dot(pa,ba)/dot(ba,ba);return vec2(length(pa-ba*clamp(h,0.0,1.0)),h);}
float ROCyl(in vec3 z, vec3 r){return length(vec2(max(abs(z.y)-r.y,0.0),length(z.xz)-r.x))-r.z;}
int id=0;
float DE(in vec3 p0){
	vec3 p=p0;
	p.xz=kaleido(p.xz,3.0*0.79);
	p.z+=0.66;
	vec2 v=Tube(p,vec3(0.0,-2.0,-0.3));
	float dLeg=v.x-0.05+v.y*0.025;
	float dTop=(length(max(abs(p0)-vec3(0.4+p0.z*0.25,0.0,0.7),0.0))-0.05)*0.9;
	p=p0;p.z-=0.5;
    float dWt=length(p+pen*abs(penFreq));
	float dB=ROCyl(p,vec3(0.035,0.075,0.01));
	v=Tube(p-pen,-pen*2.5);
	float dPenP=v.x-0.01;
	v=Tube(p-pen*0.55+vec3(0.02,0.0,-0.5),vec3(0.0,0.0,-1.55));
	float dPenA=v.x-0.01;
	p.z+=1.0;
    dWt=min(dWt,length(p+paper*abs(paperFreq)));
	dB=min(dB,ROCyl(p,vec3(0.035,0.075,0.01)));
	v=Tube(p-pen*0.51,vec3(0.0,0.25,0.0));
	dWt=min(dWt-0.1,v.x-0.01);
	v=Tube(p-paper*0.49,-paper*2.0);
	float dPaperP=v.x-0.01;
	float dPaper=length(max(abs(p-paper*0.5)-vec3(0.2,0.005,0.2),0.0));
	float dW=min(dLeg,dTop);
	dB=min(dB,min(dPenP,min(dPaperP,dPenA)));
	if(id<0){
		if(dW<dB && dW<dPaper && dW<dWt)id=1;
		else if(dB<dPaper && dB<dWt)id=2;
		else if(dPaper<dWt)id=3;
        else id=4;
	}
	return min(dW,min(dB,min(dWt,dPaper)));
}

float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
float rndStart(vec2 px){
	return 0.5+0.5*rnd(px);
}
vec3 Sky(vec3 rd){//what sky??
	return vec3(0.7,0.8,1.0)*(0.5+0.5*rd.y);
}
vec2 F(float t){
	return penPos(t)-paperPos(t);
}
vec2 DF(vec2 p, float t){
	float d1=length(p-F(t)), dt=0.1*log(d1+1.0), d2=length(p-F(t+dt));
	dt/=max(d1-d2,dt*0.1);
	return vec2(min(d1,d2),0.1*log(d1*dt+1.0));
}
vec3 HarmonographIt(vec2 p, float et, float px){
	float t=0.0,d=100.0;
	for(int i=0;i<200;i++){
		vec2 v=DF(p,t);
		d=min(d,v.x);
		t+=v.y;
		if(t>et)break;
	}
	d=smoothstep(0.0,40.0*px,d);
	return vec3(sqrt(d),d*d,d);
}
float shadao(vec3 ro, vec3 rd, float px, float rv){//pretty much IQ's SoftShadow
	float res=1.0,d,t=2.0*px*rv;
	for(int i=0;i<12;i++){
		d=max(px,DE(ro+rd*t)*1.5);
		t+=d;
		res=min(res,d/t+t*0.5);
	}
	return res;
}

vec3 L;
vec3 Color(vec3 ro, vec3 rd, float t, float px, vec3 col, float rv){
	ro+=rd*t;
	id=-1;float d=DE(ro);
	vec2 e=vec2(px*t,0.0);
	vec3 dn=vec3(DE(ro-e.xyy),DE(ro-e.yxy),DE(ro-e.yyx));
	vec3 dp=vec3(DE(ro+e.xyy),DE(ro+e.yxy),DE(ro+e.yyx));
	vec3 N=(dp-dn)/(length(dp-vec3(d))+length(vec3(d)-dn));
	vec3 R=reflect(rd,N);
	vec3 lc=vec3(1.0,0.9,0.8),sc,rc=Sky(R);
	if(id==1){sc=texture2D(tex,ro.zx+vec2(0.5)).rgb;
	}else if(id==2){sc=vec3(0.8,0.4,0.2);
	}else if(id==3)sc=HarmonographIt((ro.xz+vec2(0.0,0.5)-paper.xz*0.5)*10.0, mod(time,20.0)-0.1,px*t);
    else sc=vec3(0.2);
	float h=0.2*dot(N,R);
	sc*=vec3(0.8+h,1.0,0.8-h);
	float sh=clamp(shadao(ro,L,px*t,rv)+0.4,0.0,1.0);
	sh=sh*(0.5+0.5*dot(N,L)+abs(rd.y)*0.2);
	vec3 scol=sh*lc*(sc+rc*pow(max(0.0,dot(R,L)),4.0));
	col=mix(scol,col,clamp(d/(px*t),0.0,1.0));
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float px=1.0/size.y;
	L=normalize(vec3(0.4,0.8,-0.6));
	init(time);
	vec3 ro=vec3(cos(time*0.45)*3.0,1.5+sin(time*0.2)*0.75,sin(time*0.5)*3.0);
	vec3 rd=lookat(vec3(0.0,0.4,-0.5)-ro)*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,3.0));
	//ro=eye;rd=normalize(dir);
    float rv=rndStart(fragCoord);
	float t=DE(ro)*rv,d=0.0,dm=10.0,tm=0.0;
	vec3 col=Sky(rd);
	for(int i=0;i<64;i++){
		t+=d;
		d=DE(ro+rd*t);
		if(d<dm){dm=d;tm=t;}
		if(t>10.0 || d<0.0001)break;
	}
	col=Color(ro,rd,tm,px,col,rv);
	fragColor = vec4(1.5*col,1.0);
}
