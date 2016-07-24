// Shader downloaded from https://www.shadertoy.com/view/MdVGWh
// written by shadertoy user eiffie
//
// Name: Mission to Pluto
// Description: When the airbags deployed the mission controllers thought they could breath easy but quickly realized they had underestimated one variable... slipperiness.
//Mission to Pluto by eiffie - I was really just building a landscape for DE 2 DE collision
//but then tested it with spheres first and got this.

//I have no idea how this performs at different FPS - could be a mess

#define PI 3.14159

//now who did I steal these from ??
#define inside(a) (fragCoord.y-a.y == 0.5 && fragCoord.x-a.x == 0.5)
#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)
#define save(a,b) if(inside(vec2(a,0.0))){fragColor=b;return;}

#define MASSES 4
#define RADIUS 0.08

// From IQ's original 3D noise function. Ripped from Desert Canyon by Shane: https://www.shadertoy.com/view/Xs33Df
float noise3D(in vec3 p){
	const vec3 s = vec3(7, 157, 113);
	vec3 ip = floor(p);p -= ip;p = p*p*(3. - 2.*p);
	vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
	h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
	h.xy = mix(h.xz, h.yw, p.y);return mix(h.x, h.y, p.z); // Range: [0, 1].
}

float fbm(in vec3 p){
	p*=vec3(1.0,0.1,0.75);
	float g=(sin(p.x+sin(p.z*1.7))+sin(p.z+sin(p.x*1.3)))*0.2;
	return g+noise3D(p)*0.5+noise3D(p*2.3)*0.29;
}

float DE(in vec3 p){
	float dG=p.y+1.0-fbm(p);
	return dG;
}
vec4 mcol=vec4(0.0);
float CE(in vec3 p){
	float dG=p.y+1.0-fbm(p);
	float n=1.0-0.7*texture2D(iChannel1,p.xz).r-0.3*texture2D(iChannel1,p.xz*2.7).r;//noise3D(p*27.0);
	mcol+=vec4(vec3(0.6+n*0.4)*(1.0+p.y*0.5),n);
	dG-=n*0.01;
	return dG;
}

struct Hit{float t,s; vec3 n;}; //distance, shadow, normal

void Sphere( in vec3 ro, in vec3 rd, in vec3 p, in float r, inout Hit H)
{//intersect a sphere - based on iq's
	p=ro-p;
	float b=dot(p,rd);
	float h=b*b-dot(p,p)+r*r;
	float t=-b-sqrt(max(h,0.0));
	if(h>0.0 && t>0.0 && t<H.t){
		H.t=t;
		H.n=p+rd*t;
	}
	if(t>0.0)H.s=min(H.s,3.0*max(sqrt(max(0.0,r*r-h))-r,0.0)/t+t*0.25); 
}

#define MAX_DEPTH 100.0
void Intersect(in vec3 ro, in vec3 rd, inout Hit H){
	H.t=MAX_DEPTH;H.s=1.0;
	for(int i=0;i<MASSES;i++){//beads
		vec3 p1=load(i).xyz;
		Sphere(ro,rd,p1,RADIUS,H);
	}
}

float ShadAO(in vec3 ro, in vec3 rd){//like iq's with added sphere soft shad from iq
	float t=0.01,s=1.0,d,mn=t;
	for(int i=0;i<12;i++){
		d=max(DE(ro+rd*t)*1.2,mn);
		s=min(s,d/t+t*0.25);
		t+=d;
	}
	Hit H;
	Intersect(ro,rd,H);
	s=min(s,H.s);
	return 0.3+0.7*s;
}

vec3 scene(vec3 ro, vec3 rd){
	float t=0.0,d,px=1.0/iResolution.y;
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(t>MAX_DEPTH || d<px*t)break;
	}
	t=min(t,MAX_DEPTH);
	vec3 col=vec3(0.9,0.95,1.0)*max(0.0,0.5-abs(rd.y)),N,L=normalize(vec3(0.4,0.8,-0.5));
    col+=vec3(1.0)*pow(max(0.0,dot(rd,L)),500.0);
	Hit H;
	Intersect(ro,rd,H);
	if(H.t<t){
		ro+=rd*(H.t-px);
		N=normalize(H.n);
		mcol=vec4(0.6-dot(N,rd)*0.3,0.6,0.5,1.0);
		t=H.t;
		d=0.0;
	}else if(d<20.0*px*t){
		d=DE(ro+rd*t);if(d<0.0)t+=d*2.0;
		ro+=rd*t;
		vec2 v=vec2(px*t,0.0);
		N=normalize(vec3(CE(ro+v.xyy)-CE(ro-v.xyy),CE(ro+v.yxy)-CE(ro-v.yxy),CE(ro+v.yyx)-CE(ro-v.yyx)));
		mcol/=6.0;
		d=0.0;
	}
	if(d==0.0){//hit
		float dif=max(0.0,dot(N,L));
		float shad=(dif>0.0?ShadAO(ro,L):0.0);
		float spc=pow(max(0.0,dot(reflect(rd,N),L)),5.0);
		float fre=1.0+dot(rd,N);
		float amb=max(0.0,-N.y);	
		vec3 scol=mcol.rgb*clamp(0.3+dif*(1.0-0.5*fre)*shad+mcol.a*spc*fre+amb*0.1,0.0,1.0);
		float ct=iGlobalTime;
		for(int i=0;i<8;i++){
			ro-=rd*0.1;
			float n=(1.0-0.6*noise3D((ro+vec3(0.0,0.0,ct))*3.0)-0.4*noise3D((ro+vec3(ct,0.0,ct))*9.0));
			scol+=vec3(0.4)*clamp(-0.25-ro.y,0.0,1.0)*n*n;
		}
		col=mix(col,scol,exp(-t*0.08));
	}
	return col;
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec3 ro=load(MASSES*2).xyz;
    vec3 tg=load(MASSES*2+1).xyz;
	vec3 bl=load(0).xyz;
	vec3 rd=normalize(vec3((2.0*fragCoord-iResolution.xy)/iResolution.y,1.0));
	rd=lookat(0.2*(bl-ro)+(ro-tg)-vec3(0.0,1.0,0.0))*rd;
	fragColor=vec4(scene(ro,rd),1.0);
}