// Shader downloaded from https://www.shadertoy.com/view/4ddSzn
// written by shadertoy user eiffie
//
// Name: kumbum
// Description: compilers &lt;img src=&quot;/img/emoticonSad.png&quot;/&gt;
//kumbum by eiffie
//playing with patterns but then got carried away and now the patterns don't compile in chrome :(
//if you can get it to compile it runs fast so you can walk around

//just the building
#define LOW_QUAL

//add patterns and shadows
//#define MED_QUAL

//try a couple samples
//#define HI_QUAL

#ifdef LOW_QUAL
#define ITERS 48
#else
#define ITERS 64
#endif

#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)
#define PI 3.14159
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float DEK1(in vec2 p){
	float d=min(max(p.x,p.y)-4.0,min(max(p.x-5.0,p.y-2.0),max(p.x-2.0,p.y-5.0)));
	return min(d,min(max(p.x-5.75,p.y-0.5),max(p.x-0.5,p.y-5.75)));
} 
float DEK2(in vec3 p){
	p.xz=abs(p.xz)-2.15;
	p.xz=abs(p.xz)-0.9;
	p.xz=abs(p.xz)-0.23;
	return max(p.y<-1.0?fract(p.y)-0.75:abs(fract(p.y)-0.5)-0.2,min(p.x,p.z));
}
float DE(in vec3 p0){
	vec3 p=abs(p0);
	float y=min(p0.y+(p0.y>3.0?7.0:0.0),10.0),y7=p0.y-7.0;
	float scale=1.0+floor(y)*0.1;
	float d1=max(y7,max(abs(DEK1(p.xz*scale)/scale)-0.05,-DEK2(p0)));//walls
	y=p0.y-0.5;
	scale=1.0+floor(min(y+(y>3.0?7.0:0.0),10.0))*0.1;
	y=abs(fract(y)-0.5);
	float a=45.0,b=0.02;
	if(p0.y>4.0){if(p0.y>11.6){a=-10.0;b=0.04;}else{a/=2.;}}
	float sy=sin(-y*a)*b;
	float d2=max(y7,max(DEK1(p.xz*scale)/scale-0.15+sy,y-0.05));//ceiling
	float ln=length(p0.xz);
	y=y7*10.0;
	float r=p0.y<5.0?3.7:p0.y<7.0?2.24:p0.y<12.0?1.5+sy*0.2+1.5*sin(log(y)*0.9):1.0-0.25*(p0.y-12.0);
	float d3=ln-r,d5=10.0;//cylinder
	if(p0.y<-1.0){
		float c=floor(atan(p0.z,p0.x)*16.0/PI+0.5);
		float a=c*PI/16.0;c=sin(c);
		vec2 v=vec2(cos(a),sin(a))*r;
		y=p0.y+1.75;
		float r2=length(v-p0.xz);
		d3=max(d3,0.31-y*y-r2);
		d5=r2-0.1-c*0.02-(0.033+0.015*c)*sin(-y*(15.0-3.0*c));
		d5=max(p0.y+1.55-c*0.05,abs(d5)-0.01);
	}
	d2=min(d2,max(abs(p0.y-5.0)-0.1,ln-3.9+sy));
    d2=min(d2,max(abs(y7)-0.1,ln-3.0+sy));
    d2=min(d2,max(abs(p0.y-12.0)-0.4,ln-1.9+sy));//more roofs
	p=p0;p.y-=16.0;
	d3=min(d3,length(p)-0.25);
	p.y+=5.25;
	p=abs(p)-1.25;
	float d4=length(p.xz);//sticks
	p.xz=abs(vec2(p0.x+p0.z,p0.x-p0.z)*0.707)-1.25;
	d4=max(min(d4,length(p.xz))-0.05,p.y);
	float d0=p0.y+2.0;//ground
    float d=min(d0,min(d1,d2));
    d=min(d,min(d3,min(d4,d5)));
	//float d=min(d0,min(d1,min(d2,min(d3,min(d4,d5)))));
	return d*0.9;
}
float Pattern(vec2 p, float t){//0.25,1/3,0.5,2/3,0.75,0.8,1.0
	vec2 c=fract(vec2(p.x+p.y,p.x-p.y)*t)-0.5;
	p=fract(p)-0.5;
	return step(p.x*p.y,0.0)*step(c.x*c.y,0.0);
}
// From IQ's original 3D noise function. Ripped from Desert Canyon
float noise3D(in vec3 p){
	const vec3 s = vec3(37, 157, 113);
	vec3 ip = floor(p);p -= ip;p = p*p*(3. - 2.*p);
	vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
	h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
	h.xy = mix(h.xz, h.yw, p.y);return mix(h.x, h.y, p.z); // Range: [0, 1].
}

#define EPSILON 0.000001
vec4 ctrap;
float map(vec3 p0){
#ifdef LOW_QUAL
	ctrap+=vec4(1.0);
	return DE(p0);
#else
	vec3 p=abs(p0);
	float y=min(p0.y+(p0.y>3.0?7.0:0.0),10.0),y7=p0.y-7.0;
	float scale=1.0+floor(y)*0.1;
	float d1=max(y7,max(abs(DEK1(p.xz*scale)/scale)-0.05,-DEK2(p0)));//walls
	y=p0.y-0.5;
	scale=1.0+floor(min(y+(y>3.0?7.0:0.0),10.0))*0.1;
	y=abs(fract(y)-0.5);
	float g=45.0,b=0.02;
	if(p0.y>4.0){if(p0.y>11.6){g=-10.0;b=0.04;}else{g/=2.;}}
	float sy=sin(-y*g)*b;
	float d2=max(y7,max(DEK1(p.xz*scale)/scale-0.15+sy,y-0.05));//ceiling
	float ln=length(p0.xz);
	y=y7*10.0;
	float r=p0.y<5.0?3.7:p0.y<7.0?2.24:p0.y<12.0?1.5+sy*0.2+1.5*sin(log(y)*0.9):1.0-0.25*(p0.y-12.0);
	float d3=ln-r,d5=(y7>0.0 || abs(ln-3.5)<0.005)?d3-0.0001:10.0;//cylinder
	float c=0.0;
	if(p0.y<-1.0){
		c=floor(atan(p0.z,p0.x)*16.0/PI+0.5);
		float a=c*PI/16.0;c=sin(c);
		vec2 v=vec2(cos(a),sin(a))*3.7;
		y=p0.y+1.75;
		float r2=length(v-p0.xz);
		d3=max(d3,0.31-y*y-r2);
		d5=min(d5,max(p0.y+1.55-c*0.05,abs(r2-0.1-c*0.02-(0.033+0.015*c)*sin(-y*(15.0-3.0*c)))*0.9-0.01));
	}
	d2=min(d2,max(abs(p0.y-5.0)-0.1,ln-3.9+sy));
    d2=min(d2,max(abs(y7)-0.1,ln-3.0+sy));
    d2=min(d2,max(abs(p0.y-12.0)-0.4,ln-1.9+sy));//more roofs
	p=p0;p.y-=16.0;
	d5=min(d5,length(p)-0.25);
	p.y+=5.25;
	p=abs(p)-1.25;
	float d4=length(p.xz);//sticks
	p.xz=abs(vec2(p0.x+p0.z,p0.x-p0.z)*0.707)-1.25;
	d4=max(min(d4,length(p.xz))-0.05,p.y);
	float d0=p0.y+2.0;//ground
	float d=min(d0,min(d1,d2));
    d=min(d,min(d3,min(d4,d5)));
	float bump=-0.001;
    d+=EPSILON;
	vec3 bscl=p0*200.0;//,pscl=p0*10.0,pcol=0.5*abs(sin(pscl.yzx+2.4*sin(pscl.zxy)));
	if(d0<d){//grass
		bscl=p0*10.0;
		bscl=bscl+sin(bscl.yzx+2.4*sin(bscl.zyx));
		ctrap+=vec4(0.4+sin(bscl.x+bscl.z)*0.05,0.5,0.25+sin(bscl.x-bscl.z)*0.03,0.9);
		bscl*=20.0;
	}
    if(d1<d){//walls
		vec3 col=vec3(1.0);
		if(fract(p0.y)>0.8){
			float p=Pattern(vec2(p0.x+p0.z,p0.y)*10.0,2.0/3.0);
			col=mix(col,0.5*abs(sin(p0.yzx*10.0+2.4*sin(p0.zxy*10.0))),p);
			bump*=1.0-p;
		}
		ctrap+=vec4(col,1.0);
	}
    if(d2<d){//roofs
		vec3 col=vec3(1.0,0.5,0.4);
		if(p0.y<-1.5){
			float p=Pattern(p0.xz*10.0,1.0);
			col=mix(vec3(0.75),0.5*abs(sin(p0.yzx*10.0+2.4*sin(p0.zxy*10.0)))*0.2+0.8,p);
			bump*=1.0-p;
		}else {bscl=p0*vec3(10.0,400.0,10.0);}
		ctrap+=vec4(col,0.25);
	}
    if(d3<d){//cylinder
		vec3 col=vec3(1.0);
		if(fract(p0.y)>0.8 || (p0.y<-1.0 && ln<3.5)){
			float p=Pattern(vec2(atan(p0.z,p0.x)*35.0,p0.y*10.0),floor(c*10.0)/3.0);
			col=mix(col,0.5*abs(sin(p0.yzx*10.0+2.4*sin(p0.zxy*10.0))),p);
			bump*=1.0-p;
		}
		ctrap+=vec4(col,1.0);
	}
    if(d4<d){//sticks
		ctrap+=vec4(1.0,0.2,0.1,0.0);
	}
    if(d5<d){//pots
		bscl=p0*20.0;bump=0.012;
		if(abs(p0.y+1.78-c*0.05)-0.04<0.07*abs(c)){
            float c2=floor(atan(p0.z,p0.x)*16.0/PI+0.5);//repeating code to ease compiling
			float a=c2*PI/16.0;
			vec2 v=vec2(cos(a),sin(a))*3.7;
			v-=p0.xz;
			float p=Pattern(vec2(atan(v.y,v.x)*3.0,p0.y*20.0),floor(c*10.0)*0.1);
			bump*=1.0-0.5*p;
		}
		ctrap+=vec4(1.0,0.7,0.3,2.5);
	}
	float n=noise3D(bscl);
	d+=n*bump-EPSILON;
	return d;
#endif
}

vec3 getBackground( in vec3 rd ){
    vec3 SunDir=normalize(vec3(0.5,0.9,-0.4));
	vec3 col=vec3(0.6,0.7,0.8);
	if(rd.y<0.0)col=vec3(0.4,0.5,0.25);
	else col+=rd*0.1+vec3(1.0,0.9,0.7)*(max(0.0,dot(rd,SunDir))*0.2+pow(max(0.0,dot(rd,SunDir)),256.0));
	return col;
}

// Tetrahedral normal from IQ modified to find curvature.
vec4 normal(vec3 p, float e){vec2 v=vec2(-e,e);
	float d1=map(p+v.yxx),d2=map(p+v.xxy),d3=map(p+v.xyx),d4=map(p+v.yyy);
	return vec4(normalize(v.yxx*d1+v.xxy*d2+v.xyx*d3+v.yyy*d4),(d1+d2+d3+d4)*0.25);
}
float rnd;
float rand(){return fract(sin(rnd++));}
void randomize(in vec2 p){rnd=fract(sin(dot(p,vec2(13.3145,17.7391)))*317.7654321);}

float ShadAO(in vec3 ro, in vec3 rd){
#ifdef LOW_QUAL
    return 1.0;
#else
	float t=0.005*rnd+0.001;
	for(int i=0;i<14;i++)t+=DE(ro+rd*t);
	return clamp(t*0.56,0.0,1.0);
#endif
}
void Light(float t, float pxt, float d, vec3 ro, vec3 rd){
    vec3 SunDir=normalize(vec3(0.5,0.9,-0.4));
	t-=(pxt-d);
	ctrap=vec4(0.0);
	vec3 so=ro+rd*t,L=SunDir;
	float att=1.0,h=(so.y<-1.0?DEK1(abs(so.xz)*0.8):0.0);
	if(h<0.0){//inside lighting
		vec3 p=vec3(sign(so.x)*4.0,-1.08,sign(so.z)*4.0)-so;
		float a=length(p);
		L=mix(L,p/a,clamp(-h*20.0,0.0,1.0));
		att/=(0.25+0.25*a*a);
	}
	float nd=map(so);
	vec4 N=normal(so,pxt);
	N.xyz*=1.0-clamp(0.5*abs(nd-N.w)/pxt,0.0,1.0);
	float dif=att*max(0.0,dot(N.xyz,L));
	ctrap.rgb*=0.2*(dif*ShadAO(so+N.xyz*pxt*2.5,L)+0.175);
	vec3 refl=reflect(rd,N.xyz);
	float r=clamp(ctrap.a*0.2+min(0.0,dot(rd,N.xyz)),0.0,1.0);
	ctrap.rgb+=vec3(1.0,0.9,0.7)*r*max(0.0,dot(refl,L))*att*att;
}
vec3 scene( vec3 ro, vec3 rd ){
	float maxt=(rd.y<0.0?(-2.0-ro.y)/rd.y:50.0);
	float t=rnd*DE(ro),d,px=1.0/iResolution.y,px2=px;//et=0.0
#ifdef HI_QUAL
    float et=0.0,px1=px*0.72;
    px2=px*0.01;
#endif
	for(int i=0;i<ITERS;i++){
		d=DE(ro+rd*t);
#ifdef HI_QUAL
		if(d<px1*t && et==0.0)et=t;
#endif
		t+=d;
		if(d<px2*t || t>maxt)break;
	}
	vec3 col=getBackground(rd);
	if(length(ro+rd*t)<10.0)col=vec3(0.0);
	if(d<10.0*px*t && d<0.4){//light it
		float pxt=px*t;
		Light(t,pxt,d,ro,rd);
		col=ctrap.rgb;	
	}
#ifdef HI_QUAL
	if(et>0.0){
		t=et;
		float pxt=px*t;
		d=DE(ro+rd*t);
		Light(t,pxt,d,ro,rd);
		col=mix(ctrap.rgb,col,clamp(d/(pxt),0.0,1.0));	
	}
#endif
	//if(col!=col)col=vec3(1.0,0.0,0.0);
	return col;
}	 

vec2 brownConradyDistortion(vec2 uv)
{//from meshula https://www.shadertoy.com/view/MlSXR3
    // positive values of K1 give barrel distortion, negative give pincushion
    float barrelDistortion1 = 0.15; // K1 in text books
    float barrelDistortion2 = 0.42; // K2 in text books
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
    //uv*=1.0+r2+r2*r2;
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
    return uv;
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	randomize(fragCoord.xy+vec2(iGlobalTime));
	vec3 ro=load(0).xyz;
	vec2 rt=load(1).xy;
	vec2 uv=brownConradyDistortion((fragCoord-0.5*iResolution.xy)/iResolution.y);
	vec3 rd=normalize(vec3(uv,0.5));
	rd.yz=rotate(rd.yz,rt.y);
	rd.xz=rotate(rd.xz,rt.x);
	fragColor=vec4(scene(ro,rd),1.0);
}