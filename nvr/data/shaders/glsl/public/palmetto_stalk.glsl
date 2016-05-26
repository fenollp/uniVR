// Shader downloaded from https://www.shadertoy.com/view/MlXGDn
// written by shadertoy user eiffie
//
// Name: Palmetto Stalk
// Description: Jack and the Palmetto Stalk by eiffie ... are these supposed to make sense? 
//Jack and the Palmetto Stalk by eiffie

#define time iGlobalTime
#define size iResolution
#define tex iChannel0

#define TAO 6.283185
float px;
vec4 prp=vec4(0.0);
float DE(in vec3 p){
	p.x+=sin(p.y)*0.25;
	float r=length(p.xz),y=p.y;
	if(r>1.75)return r-1.4;
	float trunk=r-0.1;
	p.y+=r*r*0.25;
	float a=atan(p.z,p.x);
	p.y=mod(p.y+a/TAO,0.5)-0.25;
	float a2=mod(a+y*0.1,TAO/8.0)-TAO/16.0;
	p.xz=vec2(cos(a2),sin(a2))*r;
	float stem=length(vec3(p.x-clamp(p.x,-1.0,1.0),p.y,p.z))-0.005;
	p.x-=1.0;
	float r2=length(p.xz);
	float a1=atan(p.z,p.x);
	a2=mod(a1,0.2)-0.1;
	p.xz=vec2(cos(a2),sin(a2))*r2;
	p.x=clamp(p.x-0.4+a1*a1*0.02,0.0,0.4);
	p.yz=vec2(abs(p.z)-p.y,abs(p.z))*0.7;
	p=abs(p);
	float frond=max(p.x,max(p.y,p.z-0.025+r2*0.075+a1*a1*0.0025));
	if(prp.x<0.0)prp=vec4(r,a,a1,stem);
	return min(min(stem,frond),trunk)*0.75;
}
float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
vec3 noyz(vec3 c){return vec3(rnd(c.yz),rnd(c.zx),rnd(c.xy));}
float rndStart(vec2 fragCoord){
	return 0.5+0.5*rnd(fragCoord.xy);
}
vec3 Sky(vec3 rd){
	return vec3(0.5+0.5*rd.y);
}
vec3 Color(vec3 ro, vec3 rd, float t, vec3 col){
	ro+=rd*t;
	prp.x=-1.0;
	float d=DE(ro);
	vec2 e=vec2(px*t,0.0);
	vec3 L=normalize(vec3(0.5,0.8,-0.4));
	vec3 dn=vec3(DE(ro-e.xyy),DE(ro-e.yxy),DE(ro-e.yyx));
	vec3 dp=vec3(DE(ro+e.xyy),DE(ro+e.yxy),DE(ro+e.yyx));
	vec3 N=(dp-dn)/(length(dp-vec3(d))+length(vec3(d)-dn));
	vec3 R=reflect(rd,N);
	vec3 lc=vec3(1.0,0.9,0.8),sc=vec3(0.5,0.9,0.4),rc=Sky(R);
	if(prp.x<0.11)sc=200.0*vec3(0.3,0.2,0.1)*mod(ro.y+0.033*prp.y,0.1)*mod(ro.y-0.05*prp.y,0.1);
	else if(prp.w>px*t)sc-=vec3(0.05,0.2,0.1)*abs(prp.z);
	else sc*=prp.x;
	vec3 scol=lc*(0.5+0.5*dot(N,L))*(sc+0.5*prp.x*rc*pow(max(0.0,dot(R,L)),2.0));
	col=mix(scol,col,clamp(d/(px*t),0.0,1.0));
	return col;
}
vec2 sphDistances( in vec3 ro, in vec3 rd, in vec4 sph )
{//from iq's AA Sphere example
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	float d = sqrt( max(0.0,sph.w*sph.w-h)) - sph.w;
	return vec2( d, -b-sqrt(max(h,0.0)) );
}
float Face(vec2 p){
	float m=abs(p.y+0.5-p.x*p.x*0.4+sin(p.x*8.0)*0.05);
	float t=abs(mod(p.x+sin(p.x*10.0+p.y*10.0)*0.025,0.1)-0.05)*18.0;
	float d=max(m-clamp(pow(t,8.0),0.0,0.1),abs(p.x)-0.75);
	p.x=abs(p.x);
	p.x-=0.075;
	d=min(d,length(vec2(p.x,p.y+p.x))-0.02);
	p.x-=0.25-p.y*0.1;p.y-=0.2;
	d=min(d,length(vec2(p.x,p.y+p.x*0.25))-0.2);
	return smoothstep(0.0,0.03,d);
}
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
vec3 Jack(vec3 ro, vec3 rd, vec3 col){
	vec4 sph=vec4(sin(time*0.3),ro.y-2.0+rd.y*0.5+cos(time*0.2),0.0,1.0);
	vec2 v=sphDistances(ro,rd,sph);
	if(v.y>0.0){
		if(v.x<px*v.y){
			ro+=rd*v.y;
			ro-=sph.xyz;
			vec3 N=normalize(ro+noyz(ro)*0.1);
			vec3 L=normalize(vec3(0.5,0.8,-0.4));
			vec3 R=reflect(rd,N);
			vec3 scol=vec3(1.0);
			scol+=pow(max(0.0,dot(R,L)),4.0);
			ro.zy=rotate(ro.zy,0.5);
			scol*=Face(vec2(atan(ro.x,ro.z),ro.y));
			scol*=(0.5+0.5*dot(N,L));
			col=mix(scol,col,clamp(v.x/(px*v.y),0.0,1.0));
		}
	}
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	px=1.5/size.y;
	float tm=time*0.2;
	vec3 ro=vec3(sin(tm),-tm,cos(tm))*3.0;
	vec3 rd=lookat(vec3(-ro.x,-0.5+0.5*sin(tm*0.3),-ro.z))*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,2.0));
	float t=DE(ro)*rndStart(fragCoord),d=0.0,od=1.0;
	vec4 edge=vec4(-1.0);
	bool bGrab=false;
	for(int i=0;i<96;i++){
		t+=d;
		d=DE(ro+rd*t);
		if(d>od){
			if(bGrab && od<px*t && edge.x<0.0){
				edge=vec4(edge.yzw,t-od);
				bGrab=false;
			}
		}else bGrab=true;
		od=d;
		if(t>100.0 || d<0.00001)break;
	}
	if(d<px*t){
		if(edge.x>0.0)edge=edge.wxyz;
		edge=vec4(edge.yzw,t);
	}
	vec3 col=Sky(rd);
	for(int i=0;i<4;i++){
		if(edge.w>0.0)col=Color(ro,rd,edge.w,col);
		edge=edge.wxyz;
	}
	col=Jack(ro,rd,col);
	fragColor = vec4(col,1.0);

}
