// Shader downloaded from https://www.shadertoy.com/view/MdXGDf
// written by shadertoy user eiffie
//
// Name: Trig Calculator
// Description: A handy desktop emergency trig calculator. Use the mouse to select the angle. Performs the functions Sine, Cosine, ArcSine, ArcCosine and calculates PI (if you lay the rulers on the table). It has an attachable Tangent ruler but it is a bit unwieldly.
// Trig Calculator by eiffie
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


const int MarchSteps=48,ShadowSteps=24;//the soft shadow code was a little unique, the rest bleh
const float FudgeFactor=1.0,shadows=0.6,contrast=0.6;
const float spec=1.0,specExp=64.0,HitDistance=0.001,maxDepth=10.0;
const vec3 dirLight=vec3(0.577,0.577,-0.577),colLight=vec3(1.0,0.9,0.7);
bool bColoring=false;
float px;
mat2 rmx;
vec3 pg,pg2,dc;

#define tex iChannel0
#define size iResolution
#define time iGlobalTime
float RBox(in vec3 z, in vec4 r){return length(max(abs(z)-r.xyz,0.0))-r.w;}
float RCyl(in vec3 z, in vec3 r){return length(max(vec2(abs(z.z)-r.y,length(z.xy)-r.x),0.0))-r.z;}
float DE(in vec3 z){//thingy
	float dT=RBox(z-vec3(-1.0,-1.3,3.0),vec4(5.0,0.245,3.1,0.05));
	float dW=RCyl(z-vec3(-px,0.0,0.25),vec3(0.95,0.245,0.05));
	float dA=RCyl((z-vec3(-px,-0.45,-0.1)).xzy,vec3(0.0,0.45,0.025));
	dA=min(dA,RCyl(z-vec3(-px,0.0,0.0),vec3(0.0,0.05,0.025)));
	float dA2=RBox(z-pg-vec3(0.0,-1.0,-0.15),vec4(0.025,1.0,-0.04,0.05));
	float dA3=RBox(z-pg2-vec3(0.0,-1.0,-0.2),vec4(0.025,1.0,-0.04,0.05));
	float dP=RCyl(z-pg,vec3(0.0,0.15,0.015));
	dP=min(dP,RCyl(z-pg2,vec3(0.0,0.2,0.015)));
	float dS=min(dP,min(min(dT,dW),min(dA,min(dA2,dA3))));
	if(bColoring){//since all the pixels get colored at once
		bColoring=false;
		if(dS==dT){//table
			dc=vec3(0.5);
			if(z.z<-0.13)dc=vec3(0.1,0.2,0.3);
			else if(z.z<0.0 && z.x<=0.0){
				float d=mod(z.x,1.0);
				if(z.z<-0.1){d=mod(d,0.025);}else if(z.z<-0.07)d=mod(d,0.1);
				dc=mix(vec3(0.0),dc,smoothstep(0.0,0.02,d));
			}
 		}else if(dS==dW){//wheel
			vec3 p=z-vec3(-px,0.0,0.0);
			p.xy=p.xy*rmx;
			dc=texture2D(tex,p.xy+vec2(0.0,sin(p.y+p.z*(10.0-p.x*3.0))*0.02)).rgb;
			dc=mix(vec3(0.0),dc,smoothstep(0.0,0.01,abs(length(p.xy+vec2(0.0,0.7))-0.03)));
			float r=length(p.xy);
			if(r>0.75 && r<0.975){
				float d=atan(p.y,p.x)*0.318;
				if(r>0.85){d=mod(d,0.02777777);}else d=mod(d,0.25);
				dc=mix(vec3(0.0),dc,smoothstep(0.0,0.01,d));
			}
		}else if(dS==dA)dc=vec3(1.0,0.0,0.0);//angle marker
		else if(dS==dA2 || dS==dA3){//sine and cosine rulers
			dc=vec3(0.75);
			if(dS==dA3){pg=pg2;dc=vec3(0.9,0.6,0.3);}
 			vec3 p=z-pg-vec3(0.0,-1.0,-0.15);
			dc=mix(vec3(0.0),dc,smoothstep(0.0,0.01,min(abs(length(p.xy)-0.03),max(abs(p.x),abs(p.y-1.0)-0.025))));
			if(p.x<0.0){
 				float d=p.y;
				if(p.x<-0.025){d=mod(d,0.025);}else d=mod(d,0.1);
 				dc=mix(vec3(0.0),dc,smoothstep(0.0,0.02,d));
			}
		}else dc=vec3(0.25);//pegs
	}
	return dS;
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{//using the number of steps as the major contributor 
 //but then doing something like iq's trick at the end to reduce banding
	float t=mint*10.0,d=1.0,fStep=0.0;
	for( int i=0; i<ShadowSteps; i++ ){
		if(t>maxt || d<0.001)continue;
		t+=d=DE(ro+rd*t);
		fStep+=1.0;
	}
	if(d<0.01)return 0.0;
	return 1.0-(fStep-d*k/t)/float(ShadowSteps);//no rationale, just seems to work
}

vec3 scene( vec3 ro, vec3 rd )
{// find color of scene
	vec3 col=vec3(0.2+rd.y*0.5);
	float t=0.0,d=10.0;
	for(int i=0;i<MarchSteps;i++){
		if(t>maxDepth || d<HitDistance)continue;
		t+=d=DE(ro+rd*t)*FudgeFactor;
	}
	if(d<0.02){
		bColoring=true;
		t+=d=DE(ro+rd*t);
		ro+=rd*(t-HitDistance);
		const vec2 ve=vec2(0.0002,0.0);
		vec3 nor=normalize(vec3(-DE(ro-ve.xyy)+DE(ro+ve.xyy),
			-DE(ro-ve.yxy)+DE(ro+ve.yxy),-DE(ro-ve.yyx)+DE(ro+ve.yyx)));
		float dif=max(0.0, dot(dirLight, nor)),shad=0.0;
		if(shadows>0.0 && dif>0.0)shad=softshadow(ro,dirLight,HitDistance,maxDepth,12.0);
		col=dc*(1.0-shadows+shad*shadows)*(1.0-contrast+dif*contrast)
			+colLight*shad*spec*pow(max(0.0,dot(rd,reflect(dirLight,nor))),specExp);
	}
	return clamp(col,0.0,1.0);
}	 

mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,normalize(up)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	px=5.0*iMouse.x/size.x;
	float f=0.0,cx=cos(px-f),sx=sin(px-f);
	rmx=mat2(cx,sx,-sx,cx);
	pg=vec3(rmx*vec2(-1.0,0.0),0.0)-vec3(px,0.0,0.0);
	pg2=vec3(rmx*vec2(0.0,-1.0),0.0)-vec3(px,0.0,0.0);
	vec3 clr=vec3(0.0);
	vec3 ro=vec3(-2.0,0.5,-3.0);
	mat3 rotCam=lookat(vec3(-px,-0.5,0.0)-ro,vec3(0.0,1.0,0.0));
	vec3 rd=rotCam*normalize(vec3((2.0*(fragCoord.xy)-size.xy)/size.y,2.0));
	fragColor = vec4(scene(ro,rd),1.0);
}



  