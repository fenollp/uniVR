// Shader downloaded from https://www.shadertoy.com/view/XsG3Rd
// written by shadertoy user eiffie
//
// Name: Shepherd Drone
// Description: See if you can herd the sheep into a tight circle in the middle of the field. I saw a dog do it once. You're better than a dog right?
//Shepherd Drone by eiffie
//This shader has bugs left but you get the gist. I wanted to march thru 100s of autonomous
//creatures without testing the distance to each one individually.
//It was inspired by various works...
//This MV uses a cut scene of sheep, i guess i found it cute https://www.youtube.com/watch?v=4OrCA1OInoo
//Iapafoto's Interactive Fish Shoal https://www.shadertoy.com/view/ldd3DB
//Cellular Automata Particle Field by alleycatsphinx https://www.shadertoy.com/view/MdGGzG
//There was also a shader (i think by Dave Hoskins) of ants. (can't find it now)
//I used ideas from each. As long as the sheep aren't forced onto the same pixel it works fine.

//needs more march steps
#define MARCH_STEPS 16
#define PI 3.14159
//quad and capsule by iq
float Quadric(in vec3 p,in vec4 r){return (dot(p*r.xyz,p)-r.w)/length(2.0*r.xyz*p);}
float CapsuleY(in vec3 p, vec3 r){return length(vec3(p.x,p.y-clamp(p.y,r.x,r.y),p.z))-r.z;}
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float DE(in vec3 p, in vec2 c, in vec4 o){
	p.xz-=c+o.xy;
	float a=atan(o.z,o.w);
	p.xz=rotate(p.xz,PI-a);
	o.zw=normalize(o.zw);
	float langle=sin(dot(o.zw,o.xy)*8.0*PI)*0.5; //leg angle NOT CORRECT!
	p*=5.0;
	float d1=length(p)-1.0;
	p.z-=1.0+langle*0.2;
	d1=min(d1,length(p-vec3(langle*0.2,0.55,0.88))-0.1);
	float d2=length(p)-1.0;
	p.z+=1.75+langle*0.1;
	p.y-=0.9+langle*0.1;
	d2=min(d2,Quadric(p,vec4(1.0,1.0,0.5,0.25)));
	p.x=abs(p.x)-0.5;
	float d3=length(p-vec3(0.0,0.3,0.3))-0.05;
	p.z-=1.25;
	p.y+=1.5;
	p.z=abs(p.z)-0.9;
	p.zy=rotate(p.zy,langle);
	d3=min(d3,CapsuleY(p,vec3(-1.0,0.0,0.15)));
	float k=8.0;
	float d=-log(exp(-k*d1)+exp(-k*d2)+exp(-k*d3))/k;
	return d/5.0;
}

float DEShad(in vec3 p, in vec2 c, in vec4 o){
	p.xz-=c+o.xy;
	float a=atan(o.z,o.w);
	p.xz=rotate(p.xz,PI-a);
	p*=5.0;
	float d1=length(p)-1.0;
	p.z-=1.0;
	float d2=length(p)-1.0;
	float k=8.0;
	float d=-log(exp(-k*d1)+exp(-k*d2))/k;
	return d/5.0;
}

vec2 bx_cos(vec2 a){return clamp(abs(mod(a,8.0)-4.0)-2.0,-1.0,1.0);}//chebyshev rotation kekeke
vec2 bx_cossin(float a){return bx_cos(vec2(a,a-2.0));}
float bx_length(vec2 p){return max(abs(p.x),abs(p.y));}
bool exists(vec4 c){return (c.x>-1.5);}
#define T(x) texture2D(iChannel0,(x)/iResolution.xy)
float minp(float x,float y){return (x<0.0?y:min(x,y));}
float abox(vec2 p, vec2 rd, vec2 s){//distance to inside of box
	vec2 t0=(-s-p)/rd,t1=(s-p)/rd;
	return minp(t0.x,minp(t0.y,minp(t1.x,minp(t1.y,1000.0))));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 uv=(fragCoord-iResolution.xy*0.5)/iResolution.x;
	vec4 st=texture2D(iChannel0,vec2(103.5)/iResolution.xy); //state of camera 
	float h=sin(iGlobalTime+sin(iGlobalTime*0.7));
	vec3 ro=vec3(st.x,4.0+h,st.y);
	vec3 rd=vec3(uv.x,-1.0,uv.y);
	rd.yz=rotate(rd.yz,1.1-h*0.1);
	rd.xz=rotate(rd.xz,st.z+sin(iGlobalTime*0.9)*0.1);
	rd=normalize(rd);
	
	float maxt=(-0.36-ro.y)/rd.y,mint=(0.4-ro.y)/rd.y;
	float t=mint,d,od=1.0,md=1.0;
	float ft=abox(ro.xz-vec2(50.0),rd.xz,vec2(50.0));
	
	for(int i=0;i<MARCH_STEPS;i++){
		vec3 p=ro+rd*t;
		vec2 c=floor(p.xz);
		float e=abox(fract(p.xz)-vec2(0.5),rd.xz,vec2(0.5));
		c+=vec2(0.5);
		vec4 o=T(c);
		d=e+0.5;
		if(o.x>-2.5 && max(abs(p.x-50.0),abs(p.z-50.0))<50.0){
			if(exists(o))d=min(d,DE(p,c,o));
			for(float i=0.0;i<8.0;i+=1.0){//rotate around a box with 'radius' 1
				vec2 v=bx_cossin(i); //direction to check
				vec4 n=T(c+v); //the sheep in that direction
				if(exists(n))d=min(d,DE(p,c+v,n));//like voronoi sheep
			}
		}
		t+=d;
		md=min(md,d);
		if(d<0.002 || t>maxt)break;
		od=d;
	}
	t=min(t,maxt);
	vec3 p=ro+rd*(maxt-0.06);
	vec3 col=texture2D(iChannel1,p.xz*0.001).rgb*0.5+texture2D(iChannel1,p.xz*0.01).rgb*vec3(0.6,0.5,0.2)+vec3(0.0,0.2,0.0);
	vec3 c2=texture2D(iChannel1,p.xz*0.2).rgb;
	p=ro+rd*(maxt-0.03);
	c2+=texture2D(iChannel1,p.xz*0.2).rgb;
	p=ro+rd*maxt;
	c2+=texture2D(iChannel1,p.xz*0.2).rgb;
	col+=c2*0.2;
	col*=vec3(0.4)*clamp(md*56.0,0.0,1.0);
	if(maxt>ft){
		vec3 p2=ro+rd*ft;
		if(p2.y<0.4){
			p2.xz=abs(fract(p2.xz*0.5)*2.0-0.5);
			p2.y=abs(abs(p2.y)-0.2);
			col=mix(vec3(0.9),col,smoothstep(0.0,0.04,p2.y-0.05));
			col=mix(vec3(0.6),col,smoothstep(0.0,0.04,min(p2.x,p2.z)-0.05));
		}
	}
	//cheap?? shadow
	vec2 c=floor(p.xz)+vec2(0.5);
	vec4 o=T(c);
	float d2=100.0;
	if(o.x>-2.5 && max(abs(p.x-50.0),abs(p.z-50.0))<50.0){
		if(exists(o))d2=min(d2,DEShad(p,c,o));
		for(float i=0.0;i<8.0;i+=1.0){//rotate around a box with 'radius' 1
			vec2 v=bx_cossin(i); //direction to check
			vec4 n=T(c+v); //the sheep in that direction
			if(exists(n))d2=min(d2,DEShad(p,c+v,n));//like voronoi sheep
		}
	}
	col*=clamp(d2*d2*17.0,0.0,1.0);
//to debug "exists" red=no sheep within 1st shell, blue=there is, green=a sheep here (still buggy)
#if 0
	if(o.x<-2.5)col=vec3(1.0,0.0,0.0);
	else if(o.x<-1.5)col=vec3(0.0,0.0,1.0);
	else if(max(abs(o.x),abs(o.y))>0.5)col=vec3(1.0,0.0,1.0);
#endif
	if(d<0.002){
		col=vec3(clamp(1.0-abs(d/od),0.0,1.0));
	}
	fragColor=vec4(col,1.0);
}