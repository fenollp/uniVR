// Shader downloaded from https://www.shadertoy.com/view/MdK3zm
// written by shadertoy user eiffie
//
// Name: Orchard Blight
// Description: Buggy Trees with broken branches (3d version too). Harder than it seems. Using knighty's dragon ifs example: [url]https://www.shadertoy.com/view/MsBXW3[/url]
//#define DO_3D
//Orchard Blight by eiffie (uncomment DO_3D for more ?... fun?)
//This is based on knighty's dragon ifs branching here: https://www.shadertoy.com/view/MsBXW3
//I wanted to do this earlier but didn't get to it. It needs lots of corrections so if
//you see anything amiss let me know!

//for iterating thru the branches
#define DEPTH 6
#define ITER_NUM pow(2., float(DEPTH))
float BR,BO; //bounding radii
float Findex=0.;//mapping of branch indices to [0,1]

//for making the tree (base angles and scales which are altered per branch)
#define angleY 0.58
#define angleZ 0.73
#define scale 1.5
#define MIN_DIST 0.01
mat2 mx=mat2(1.0,0.0,0.0,1.0);

void ComputeBR(){//a rather brutish way to calc a loose bounding radius :(
	BR=0.0;//1.0/(scale-1.0);
	float a=1.0;
	for(int i=0;i<DEPTH;i++){//the absolute worst case - a straight branch
		a/=scale;
		BR+=a;
	}
    BR=max(1.0,BR); //for the trunk (parent stem that gets drawn if scale>2.0)

	BO=BR*BR;
#ifdef DO_3D
	mx=mat2(cos(angleY),sin(angleY),-sin(angleY),cos(angleY));//give the tree depth
#endif
}
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
float rand(vec2 c){return fract(sin(dot(c,vec2(12.9898,78.233)))*43758.5453);}
float rand(float c){return fract(sin(c)*43758.5453);}
float Branch(vec3 p){return length(vec3(p.x,p.y-clamp(p.y,-1.0,0.0),p.z))-0.05+p.y*0.025;}

//the knighty bit
float dragonSample(vec3 p, inout float lastDist, in float rnd1, in float rnd2){
	float q=Findex;//Get the index of the current point
	float dd=1.;//running scale
	float md=100.0;//minimum distance to tree branchs
	float j=ITER_NUM;
	float scl=rnd1,ang=rnd2;
	for(int i=0; i<DEPTH; i++){
		float l2=dot(p,p);
		float temp=BR+lastDist*dd;//this is to avoid computing length (sqrt)
		if(l2>temp*temp || l2>BO || md<MIN_DIST) break;
		if(q<0.5){
			scl+=rnd2;
			ang+=rnd1;
		}else{
			//if(fract(scl*231.4563)>0.8)break;//the broken branches, not working :(
			scl+=rnd1;
			ang+=rnd2;
		}
        scl=scale+scale*rand(scl)*0.5;
        if(fract(scl*231.4563)>0.9)scl=scale*100.0;
		ang=(angleZ-angleZ*rand(ang)*0.5)*(q<0.5?1.0:-1.0);
		p.xz=p.xz*mx;
		p.xy=rotate(p.xy,ang);
		p*=scl;
		dd*=scl;
		p.y-=1.0;
		md=min(md,Branch(p)/dd);
		q=fract(2.*q);j*=.5;//move the indices
	}
	Findex += j/ITER_NUM;//update current index. it is not necessary to check the next j-1 points.
	lastDist=min((length(p)-BR)/dd,lastDist);//this is the distance to the bounding radius
	return md; //this is the distance to the fractal
}

float DE(in vec3 p){
    //some modding for 3d orchard
#ifdef DO_3D
	vec2 c=floor(vec2(100.0)+p.xz/(BR*2.0));
	p.xz=mod(p.xz,BR*2.0)-BR;	
#else
	float c=floor(iGlobalTime*0.5);
#endif
	float dist=length(p)+0.5,rnd1=rand(c),rnd2=rand(1.0-rnd1);
#ifdef DO_3D
	p.y+=rnd1*0.5;
	p.xz=rotate(p.xz,rnd2*3.14);
#endif
    //this is the good stuff (only 13 paths are used from trunk to leaf)
	Findex=0.;
	float d=Branch(p);
	for(int i=0; i<13; i++){
		d=min(d,dragonSample(p,dist,rnd1,rnd2));
		if(Findex>=1. || d<MIN_DIST) break;
	}

	return min(d,max(0.0,dist)+BR*0.15);
}

// From IQ's original 3D noise function. Ripped from Desert Canyon by Shane: https://www.shadertoy.com/view/Xs33Df
float noise3D(in vec3 p){
	const vec3 s = vec3(7, 157, 113);
	vec3 ip = floor(p);p -= ip;p = p*p*(3. - 2.*p);
	vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
	h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
	h.xy = mix(h.xz, h.yw, p.y);return mix(h.x, h.y, p.z); // Range: [0, 1].
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	ComputeBR(); //compute the bounding radius of a branch and all its children
#ifdef DO_3D
	vec3 ro=vec3(0.0,0.0,iGlobalTime);
	vec3 rd=normalize(vec3((2.0*fragCoord-iResolution.xy)/iResolution.y-vec2(sin(iGlobalTime)*0.1,0.2+sin(iGlobalTime*0.4)*0.1),2.0));
	float t=0.0,d;
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(t>40.0 || d<MIN_DIST)break;
	}
	t=clamp(min(t/40.0,(rd.y*3.0+1.0)*pow(1.0-abs(rd.y),5.0)+0.5*noise3D(40.0*rd*max(0.0,rd.y))),0.0,1.0);
#else
	vec3 p=vec3(3.0*(fragCoord/iResolution.xy-0.5),0.0);
	float t=DE(p);
	t=smoothstep(0.0,0.01,t);
#endif
	fragColor=vec4(t);
}
