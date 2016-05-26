// Shader downloaded from https://www.shadertoy.com/view/ltXGRj
// written by shadertoy user eiffie
//
// Name: Questionable Kiwi
// Description: It doesn't have an expiration date but I'm still hesitant.
//Questionable Kiwi by eiffie

//Another DE Fur example but had trouble coming up with a good hair placement.
//I think this DE is suffering from discontinuity and hairy ball syndrome (don't search that!)

#define time iGlobalTime
#define size iResolution
vec3 mcol,LDir;
float DE(in vec3 p){//fur ball
	p+=sin(p.yzx*(20.0+5.0*sin(time*0.1))+time*2.0)*0.02;
	float r=length(p);
	if(r<1.0){
		vec3 p2=p*p;
		mcol=vec3((r-0.5)*(1.0+0.5*dot(LDir,p)));
		vec2 v=(p2.x>p2.y && p2.x>p2.z)?p.yz/p.x:(p2.y>p2.z)?p.zx/p.y:p.xy/p.z;
		float m=0.03;//-0.04*dot(p2,p2);
		v=mod(v+m,2.0*m)-m;
		float r2=(length(v)-0.03+0.04*r);
		r-=0.8;
		if(r2<r)r=r2;else mcol.g*=1.25;
	}else r-=0.9;
	return r;
}


float rndStart(vec2 co){return 0.1+0.9*fract(sin(dot(co,vec2(123.42,117.853)))*412.453);}

mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float px=4.0/size.y;//find the pixel size
	float tim=time*0.3;
	
	//position camera
	vec3 ro=vec3(cos(tim),sin(tim*0.7)*0.3,sin(tim))*(2.0+0.7*cos(tim));
	vec3 rd=normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,2.0));
	rd=lookat(vec3(0.0,(2.7-length(ro))*0.3,0.0)-ro,vec3(0.0,1.0,0.0))*rd;
	//ro=eye;rd=normalize(dir);
	LDir=normalize(vec3(0.4,0.75,0.4));//direction to light
	vec3 bcol=clamp(vec3(1.0-rd.y,1.0-rd.y-0.1*exp(-abs(rd.y*15.0)),1.0-0.5*exp(-abs(rd.y*5.0))),0.0,1.0);//backcolor
	//march
	
	float tG=(-0.85-ro.y)/rd.y,d,step=0.0;
	if(tG<0.0)tG=1000.0;
	float MAX_T=min(tG,6.0);
	vec2 g=ro.xz+rd.xz*tG;
	float t=DE(ro)*rndStart(fragCoord.xy);
	vec4 col=vec4(0.0);//color accumulator
	for(int i=0;i<99;i++){
		d=DE(ro+rd*t);
		if(d<px){
			vec3 scol=mcol;
			float d2=DE(ro+rd*t+LDir*px);
			float shad=0.5*abs(d2/d);
			scol=scol*shad+vec3(0.2,0.0,-0.2)*(shad-0.5);
			float alpha=(1.0-col.w)*clamp(1.0-d/(px),0.0,1.0);
			col+=vec4(clamp(scol,0.0,1.0),1.0)*alpha;
			if(col.w>0.9)break;
		}
		t+=d*0.6;
		if(t>MAX_T)break;
	}

	//color the ground 
	if(rd.y<0.0){
		ro+=rd*tG;
		float s=1.0,dst=0.1;
		t=DE(ro)*rndStart(fragCoord.xy);
		for(int i=0;i<8;i++){
			float d=max(0.0,DE(ro+LDir*t)*1.5)+0.05;
			s=min(s,8.0*d/t);
			t+=dst;dst*=2.0;
		}
		bcol*=0.5+0.5*s;
	}
	col.rgb+=bcol*(1.0-clamp(col.w,0.0,1.0));

	fragColor=vec4(col.rgb,1.0);
} 