// Shader downloaded from https://www.shadertoy.com/view/lsd3Dl
// written by shadertoy user eiffie
//
// Name: Rocket City
// Description: Mouse to aim (pitch yaw), UP ARROW to thrust, DOWN ARROW to break, RIGHT/LEFT ARROWS to roll.
//Rocket City by eiffie (although there are no rockets and there is little if any
//resemblance to a city this is what I called it)

//I just wanted to make a reusable flight control but then messed that up with
//collision detection.

vec3 Tile(vec3 p){vec3 a=vec3(8.0);return abs(mod(p,a)-a*0.5)-a*0.25;}
float DERect(vec4 z,vec3 r){return length(max(abs(z.xyz)-r,0.0))/z.w;}
const float mr=0.5, mxr=0.975, scale = 2.52;
const vec3 rc=vec3(3.31,2.79,4.11),rcL=vec3(2.24,1.88,2.84);
const vec4 p0=vec4(4.0,0.0,-4.0,1.0);

float DE(in vec3 p)
{
	p=Tile(p);
	vec4 z = vec4(p,1.0);
	float dG=1000.0;
	for (int n = 0; n<5; n++) {
		z.xyz=clamp(z.xyz, -1.0, 1.0) *2.0-z.xyz;
		z*=scale/clamp(max(dot(z.xy,z.xy),max(dot(z.xz,z.xz),dot(z.yz,z.yz))),mr,mxr);
		z+=p0;
		if(n==2){dG=DERect(z,rcL);}
	}
	float ds=DERect(z,rc);
	return min(dG,ds);
}
vec4 mcol;
float CE(in vec3 p){
	p=Tile(p);
	vec4 z = vec4(p,1.0);
	float dG=1000.0;
	vec4 mc=vec4(0.0);
	for (int n = 0; n<5; n++) {
		z.xyz=clamp(z.xyz, -1.0, 1.0) *2.0-z.xyz;
		z*=scale/clamp(max(dot(z.xy,z.xy),max(dot(z.xz,z.xz),dot(z.yz,z.yz))),mr,mxr);
		z+=p0;
		if(n==4)mc=vec4(vec3(0.5,0.3,0.2)+z.xyz*0.05,0.25);
		else if(n==2){dG=DERect(z,rcL);}
	}
	float ds=DERect(z,rc);
	if(dG<ds)mcol+=vec4(0.5,0.6,0.9,0.9)+vec4(z.xyz*0.025,0.0);
	else mcol+=mc;
	return min(dG,ds);
}

vec3 sunDir=normalize(vec3(0.7,1.0,-0.7)),sunColor=vec3(1.0,0.99,0.9),skyColor=vec3(0.25,0.26,0.27);

vec3 Backdrop( in vec3 rd ){
	return skyColor+rd*0.05+sin(rd.yzx*5.0+2.4*sin(rd.zxy*3.0))*0.05+sunColor*(max(0.0,dot(rd,sunDir))*0.2+pow(max(0.0,dot(rd,sunDir)),256.0));
}


float rnd;
void randomize(in vec2 p){rnd=fract(float(iFrame)+sin(dot(p,vec2(13.3145,17.7391)))*317.7654321);}

float ShadAO(in vec3 ro, in vec3 rd){
	float t=0.0,s=1.0,d,mn=0.01+0.04*rnd;
	for(int i=0;i<12;i++){
		d=max(DE(ro+rd*t)*1.5,mn);
		s=min(s,d/t+t*0.5);
		t+=d;
	}
	return s;
}

vec3 scene(in vec3 ro, in vec3 rd){
	float d=DE(ro)*rnd*0.5,t=d,od=1.0,pxl=2.0/iResolution.y;
	vec4 dm=vec4(1000.0),tm=vec4(-1.0);
	for(int i=0;i<78;i++){
		d=DE(ro+rd*t);
		if(d<pxl*t && d<od && tm.w<0.0){dm=vec4(abs(d),dm.xyz);tm=vec4(t,tm.xyz);}//push
		t+=d;
		od=d;
		if(t>20.0 || d<0.00001)break;
	}
	if(d<pxl*t && d<dm.x){dm.x=d;tm.x=t;}
	vec3 col=Backdrop(rd),fcol=col;
	for(int i=0;i<4;i++){//unrolled back to front
		if(tm.x<0.0)break;
		float px=pxl*tm.x;
		vec3 so=ro+rd*tm.x;
		mcol=vec4(0.0);
		vec3 ve=vec3(px,0.0,0.0);
		float d1=CE(so);
		vec3 dn=vec3(CE(so-ve.xyy),CE(so-ve.yxy),CE(so-ve.yyx));
		vec3 dp=vec3(CE(so+ve.xyy),CE(so+ve.yxy),CE(so+ve.yyx));
		vec3 N=(dp-dn)/(length(dp-vec3(d1))+length(vec3(d1)-dn));
		vec3 L=sunDir;
		vec3 scol=mcol.rgb*0.14;
		vec3 R=reflect(rd,N);
		float v=dot(-rd,N),l=dot(N,L);
		float shad=ShadAO(so+N*0.001,L);
		vec3 cc=vec3(0.6,0.8,1.0),lc=vec3(1.0,0.8,0.6);
		float cd=exp(-distance(ro,so));
		float spcl=pow(clamp(dot(R,L),0.0,1.0),10.0),spcc=pow(max(0.0,dot(R,-rd)),1.0+cd)*0.25;
		scol=scol*(cd*v*cc+shad*l*lc)+(cd*spcc*cc+shad*spcl*lc)*mcol.a;
		scol=clamp(scol,0.0,1.0);
		float fog=min(pow(tm.x*0.2,1.33)*0.54,1.0);
		scol=mix(scol,fcol,fog);
		col=mix(scol,col,clamp(dm.x/px,0.0,1.0));
		dm=dm.yzwx;tm=tm.yzwx;
	}
	if(col!=col)col=vec3(1.0,0.0,0.0);
	return clamp(col*2.0,0.0,1.0);
}

//some quaterion math just to be different
#define quat vec4
quat qid(){return quat(0.0,0.0,0.0,1.0);}
quat qmulq(quat q1, quat q2){//multiply two quats
	return quat(q1.xyz*q2.w+q2.xyz*q1.w+cross(q1.xyz,q2.xyz),(q1.w*q2.w)-dot(q1.xyz,q2.xyz));
}
quat qinv(quat q){return quat(-q.xyz,q.w)/dot(q,q);}//inverse quaternion
vec3 qmulv(quat q, vec3 p){return qmulq(q,qmulq(quat(p,0.0),qinv(q))).xyz;}//rotate a vector
/* //extra quaternion functions
quat aa2q(vec3 axis, float angle){return quat(normalize(axis)*sin(angle*0.5),cos(angle*0.5));}
quat q2aa(quat q){return quat(q.xyz/sqrt(1.0-q.w*q.w),acos(q.w)*2.0);}//assumed q is normalized coverts to axis&angle
quat qlookat(vec3 v){return aa2q(vec3(-v.y,v.x,0.0),acos(v.z/length(v)));}//point in direction v
vec3 vmulq(vec3 p, quat q){return qmulq(qinv(q),qmulq(quat(p,0.0),q)).xyz;}//inverse rotation
quat qslerp(quat q1, quat q2, float f){
	float d=dot(q1,q2),theta=acos(abs(d)),ost=(1.0/sin(theta)); 
	return normalize(q1*sin(theta*(1.0-f))*ost*sign(d)+q2*sin(theta*f)*ost); 
}
*/
vec4 load(in int re) {
    return texture2D(iChannel0, (0.5+vec2(re,0.0)) / iChannelResolution[0].xy, -100.0 );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	randomize(fragCoord);
	vec3 rd=normalize(vec3((2.0*fragCoord-iResolution.xy)/iResolution.y,1.0));
	vec3 ro=load(0).xyz;
	quat fw=load(1);
	rd=qmulv(fw,rd);
	//ro=eye;rd=normalize(dir);
	fragColor=vec4(scene(ro,rd),1.0);
}