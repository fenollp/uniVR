// Shader downloaded from https://www.shadertoy.com/view/lllGR2
// written by shadertoy user eiffie
//
// Name: Orbit Fractals
// Description: A satellite orbiting a planet orbiting a sun orbiting a black hole would create interesting patterns if the scale was a bit more linear. The drawing code is based on [url]https://www.shadertoy.com/view/XdSSRw[/url] from nimitz.
//Orbit Fractals by eiffie, based on Parametrics by nimitz https://www.shadertoy.com/view/XdSSRw

//This is related to rolling fractals - http://www.fractalforums.com/new-theories-and-research/rolling-fractals/
//I did not expect to find the HEX and TRIANGLE shapes in "planetary" orbits and with such strange scales! 
//I doubt they will work in your browser tho :(
#define SIMP
//#define SIMP3D
//#define HEX
//#define TRI
//#define HASHTAG


#define LOCAL_STEPS 6
#define MIN_T 0.0
#define SCALE_Z 0.0

#ifdef SIMP
	#define GLOBAL_STEPS 99
	#define MAX_T 25.1
	#define ITERS 2
	#define SCALE -3.5
#endif
#ifdef SIMP3D
	#define GLOBAL_STEPS 99
	#define MAX_T 12.0
	#define ITERS 5
	#define SCALE -3.0
	#undef SCALE_Z
	#define SCALE_Z 2.0
	#define CAM_3D
#endif
#ifdef HEX
	#define GLOBAL_STEPS 1024
	#define MAX_T 150.0
	#define ITERS 3
	#define SCALE 3.4495
#endif
#ifdef TRI
	#define GLOBAL_STEPS 1024
	#define MAX_T 200.0
	#define ITERS 3
	#define SCALE 2.3028
#endif
#ifdef HASHTAG
	#define GLOBAL_STEPS 1024
	#define MAX_T 200.0
	#define ITERS 3
	#define SCALE -2.992
#endif


#define time iGlobalTime
#define size iResolution

vec3 orbit(float a, float r){return vec3(cos(SCALE_Z*a)*vec2(cos(a),sin(a)),sin(SCALE_Z*a))*r;}
vec3 F(float t){
	float r=1.0;
	vec3 p=orbit(t,r);
	for(int i=0;i<ITERS;i++){
		t*=SCALE,r/=abs(SCALE);
		p+=orbit(t,r);
	}
	return p;
}
float SegD(vec3 pa, vec3 ba, vec3 rd){
	float d=dot(rd,ba);
	float t=clamp((dot(rd,pa)*d-dot(pa,ba))/(dot(ba,ba)-d*d),0.0,1.0);
	pa+=ba*t;
	float b=dot(pa,rd);
	float h=dot(pa,pa)-b*b;
	return h;
}
float Arms(float t, vec3 ro, vec3 rd){
	float d=100.0;
	vec3 p1=vec3(0.0),p2;
	float r=1.0;
	for(int i=0;i<ITERS+1;i++){
		p2=p1+orbit(t,r);
		d=min(d,SegD(p1-ro,p2-p1,rd));
		t*=SCALE,r/=abs(SCALE);
		p1=p2;
	}
	return d;
}
vec4 D=vec4(1000.0),TF=vec4(0.0),TN=vec4(0.0);//a stack of distances (from the curve, not to) and times
void zStack(float d, float tf, float tn){
	if(d<D.x){D=vec4(d,D.xyz);TN=vec4(tn,TN.xyz);TF=vec4(tf,TF.xyz);}
	else if(d<D.y){D.yzw=vec3(d,D.yz);TN.yzw=vec3(tn,TN.yz);TF.yzw=vec3(tf,TF.yz);}
	else if(d<D.z){D.zw=vec2(d,D.z);TN.zw=vec2(tn,TN.z);TF.zw=vec2(tf,TF.z);}
	else if(d<D.w){D.w=d;TN.w=tn;TF.w=tf;}
}

vec3 scene( vec3 ro, vec3 rd )
{
	float stride=2.0*(MAX_T-MIN_T)/float(GLOBAL_STEPS);
	float t=MIN_T,ot=t,d=0.0;
	vec3 p1=F(t),p2;
	for(int i=0;i<GLOBAL_STEPS;i++){//stepping thru the whole curve to find possible roots
		t+=max(stride*0.2,stride*log(d+1.15));
		p2=F(t);
		d=SegD(p1-ro,p2-p1,rd);
		zStack(d,t,ot);
		if(t>MAX_T)break;
		ot=t;
		p1=p2;
	}
	d=100.0;
	for(int j=0;j<4;j++){//stepping thru the possible roots
		float near=TN.x,far=TF.x;
		for(int i=0;i<LOCAL_STEPS;i++){//...and finding local minima
			float mid=(near+far)*0.5;
			p1=F(mid);
			float mdrv=SegD(p1-ro,F(far)-p1,rd)-SegD(p1-ro,F(near)-p1,rd);
			if(mdrv > 0.0)far=mid;else near=mid;
		}
		p1=F(near);p2=F(far);
		d=min(d,SegD(p1-ro,p2-p1,rd));
		TN=TN.yzwx;TF=TF.yzwx;
	}
	vec3 col=vec3(smoothstep(0.0,0.0001,d));
	d=Arms(time*0.5,ro,rd);
	col=mix(vec3(0.0,0.75,0.0),col,smoothstep(0.0,0.0001,d));
	return col;
}	 
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv=(2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
	vec3 ro=vec3(0.0,0.0,3.0);
#ifdef CAM_3D
	ro=vec3(cos(time),0.05,sin(time))*3.0;
#endif
	vec3 rd=lookat(-ro)*normalize(vec3(uv,2.0));
	fragColor = vec4(scene(ro,rd),1.0);
}
