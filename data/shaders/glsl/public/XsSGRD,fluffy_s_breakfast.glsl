// Shader downloaded from https://www.shadertoy.com/view/XsSGRD
// written by shadertoy user eiffie
//
// Name: fluffy's breakfast
// Description: Now I like the name &quot;Confusion Marching&quot;.
// fluffy's breakfast by eiffie
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// using massive DoF to march around this little guy's furry butt

const float focalDistance=1.0,aperature=0.07,fudgeFactor=0.9;

#define size iResolution
#define time iGlobalTime

//handy routines from iq
float smin(float a,float b,float k){return -log(exp(-k*a)+exp(-k*b))/k;}//negative k gives int and dif
float Ellipsoid(vec3 z, vec4 r){float f=length(z*r.xyz);return f*(f-r.w)/length(z*r.xyz*r.xyz);}
float Segment(vec3 p, vec3 p0, vec3 p1, float r){vec3 v=p1-p0;v*=clamp(dot(p-p0,v)/dot(v,v),0.0,1.0);return distance(p-p0,v)-r;}
float Cone(in vec3 z, vec2 r){return max(abs(z.y)-r.y,(length(z.xz)-r.x*clamp(r.y-abs(z.y),0.0,r.y))/(1.0+r.x/r.y));}
vec4 seg4( vec3 pa, vec3 ba )//iq's tube returning nearest point and distance along segment
{//same as tube except it lets you shape the result with dot(j.xyz,rt) and j.w
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec4(pa - ba*h,h);
}
// See http://www.iquilezles.org/www/articles/morenoise/morenoise.htm for a proper version :)
float hash(float n) {return fract(sin(n) * 43758.5453123);}
float noyz(vec2 x) {//simple version
	vec2 p=floor(x),f=fract(x),u=f*f*(3.0-2.0*f);
	const float tw=117.0;
	float n=p.x+p.y*tw,a=hash(n),b=hash(n+1.0),c=hash(n+tw),d=hash(n+tw+1.0);
	return a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y;
}
float fbm(vec2 p) {return 0.5*noyz(p)+0.3*noyz(p*2.3)+0.2*noyz(p*3.7);}

float RCyl(in vec3 z, vec3 r){return length(max(vec2(abs(z.z)-r.y,length(z.xy)-r.x),0.0))-r.z;}

float linstep(float a, float b, float t){return clamp((t-a)/(b-a),0.,1.);}// i got this from knighty and/or darkbeam
float rand(vec2 co){// implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
	return fract(sin(dot(co*0.123,vec2(12.9898,78.233))) * 43758.5453);
}

float headbob,tailwag;
float DE(in vec3 p)
{
	vec3 z=p+vec3(0.0,1.2,2.5);
	float dB=Cone(z,vec2(0.75,1.5));//dog bowl
	dB=smin(dB,-length(z+vec3(0.0,-1.215,0.0))+1.08,-64.0);//smooth difference to scoop out bowl
	float dF=z.y;  //floor
	float d=Ellipsoid(p,vec4(1.4,1.4,1.0,1.0)); //body
	vec4 j=seg4(p+vec3(0.0,-0.58,-1.0),vec3(tailwag,0.68,0.0));//create tail segment
	j.z-=sin(j.w*3.1416)*0.1;//add a curve to the tail
	float d2=length(j.xyz); //tail distance
	vec2 uv=vec2(atan(p.z,p.x),p.y); //basic fur pattern
	p.x=abs(p.x);
	uv.xy=mix(vec2(uv.x+(p.y-0.32)*1.3,p.y+d2*3.3),uv.xy,smoothstep(0.0,0.25,d2));//changing fur direction for tail
	float d3=min(d2,RCyl(p+vec3(-0.4,headbob,1.35),vec3(0.15,0.0,0.02))); //ears
	uv.y=mix(p.y+d3*3.3,uv.y,smoothstep(0.0,0.51,d3));//changing fur direction for ears
	d2=min(d2,d3);
	float h=fbm(uv*25.0); 
	p.z=abs(p.z);
	d2=min(d2,Ellipsoid(p+vec3(-0.45,0.78,-0.63),vec4(2.0,1.0,2.0,0.07))); //feet
	d=(smin(d2,d,8.0)-h*0.2)*0.5; //smooth together and add fur
	return min(d,min(dB,dF)); //return closest object
}
vec3 mcol;
float CE(vec3 p){//same for coloring
	vec3 z=p+vec3(0.0,1.2,2.5);
	float dB=Cone(z,vec2(0.75,1.5));
	dB=smin(dB,-length(z+vec3(0.0,-1.215,0.0))+1.08,-64.0);
	float dF=z.y;
	float d=Ellipsoid(p,vec4(1.4,1.4,1.0,1.0));
	vec4 j=seg4(p+vec3(0.0,-0.58,-1.0),vec3(tailwag,0.68,0.0));
	j.z-=sin(j.w*3.1416)*0.1;
	float d2=length(j.xyz);
	vec2 uv=vec2(atan(p.z,p.x),p.y);
	p.x=abs(p.x);
	uv.xy=mix(vec2(uv.x+(p.y-0.32)*tailwag*1.3,p.y+d2*3.3),uv.xy,smoothstep(0.0,0.25,d2));//changing the direction for ears
	float d3=min(d2,RCyl(p+vec3(-0.4,headbob,1.35),vec3(0.15,0.0,0.02)));
	uv.y=mix(p.y+d3*3.3,uv.y,smoothstep(0.0,0.51,d3));
	d2=min(d2,d3);
	float h=fbm(uv*25.0);
	p.z=abs(p.z);
	d2=min(d2,Ellipsoid(p+vec3(-0.45,0.78,-0.63),vec4(2.0,1.0,2.0,0.07)));
	float d1=(smin(d2,d,8.0)-h*0.2)*0.5;
	d=min(d1,min(dB,dF));
	if(abs(d-dB)<0.001)mcol+=vec3(0.9,0.9,0.2);
	else if(abs(d-dF)<0.001){mcol+=vec3(1.0,0.4+noyz(z.xz*vec2(50.0,1.0))*0.4,0.4)*(0.4+0.6*clamp(d1*3.0,0.0,1.0));}
	else mcol+=vec3(0.7,0.5,0.3)*h+vec3(-p.y*0.5);
	return d;
}

float pixelSize;
float CircleOfConfusion(float t){//calculates the radius of the circle of confusion at length t
	return max(abs(focalDistance-t)*aperature,pixelSize*t);
}
mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,normalize(up)));return mat3(rt,cross(rt,fw),fw);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	pixelSize=1.0/size.y;
	headbob=-0.6+abs(sin(time*9.0)*sin(time*3.5))*0.1;
	tailwag=sin(time*14.0)*0.1;
	vec3 ro=vec3(-1.5,0.15,2.75)+vec3(cos(time),sin(time*0.7)*0.5,sin(time))*0.25;
	vec3 rd=lookat(-ro,vec3(0.0,1.0,0.0))*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,2.0));
	vec3 L=normalize(ro+vec3(0.5,2.5,0.5));
	vec4 col=vec4(0.0);//color accumulator
	float t=0.0;//distance traveled
	for(int i=1;i<48;i++){//march loop
		if(col.w>0.9 || t>7.0)continue;//bail if we hit a surface or go out of bounds
		float rCoC=CircleOfConfusion(t);//calc the radius of CoC
		float d=DE(ro)+0.25*rCoC;
		if(d<rCoC){//if we are inside add its contribution
			vec3 p=ro;//-rd*abs(d-rCoC);//back up to border of CoC
			mcol=vec3(0.0);//clear the color trap, collecting color samples with normal deltas
			vec2 v=vec2(rCoC*0.5,0.0);//use normal deltas based on CoC radius
			vec3 N=normalize(vec3(-CE(p-v.xyy)+CE(p+v.xyy),-CE(p-v.yxy)+CE(p+v.yxy),-CE(p-v.yyx)+CE(p+v.yyx)));
			//if(dot(N,rd)<0.0){//doesn't seem to matter??
				vec3 scol=mcol*0.1666*(0.7+0.3*dot(N,L));//do some fast light calcs (you can forget about shadow casting, too expensive)
				scol+=pow(max(0.0,dot(reflect(rd,N),L)),8.0)*vec3(1.0,0.5,0.0);
				float alpha=fudgeFactor*(1.0-col.w)*linstep(-rCoC,rCoC,-d);//calculate the mix like cloud density
				col+=vec4(scol*alpha,alpha);//blend in the new color
			//}
		}
		d=abs(fudgeFactor*d*(0.7+0.2*rand(fragCoord.xy*vec2(i))));//add in noise to reduce banding and create fuzz
		ro+=d*rd;//march
		t+=d;
	}//mix in background color
	vec3 scol=mix(vec3(0.025,0.1,0.05)+rd*0.025,vec3(0.1,0.2,0.3)+rd*0.1,smoothstep(-0.1,0.1,rd.y));
	col.rgb+=scol*(1.0-clamp(col.w,0.0,1.0));

	fragColor = vec4(clamp(col.rgb,0.0,1.0),1.0);
}

