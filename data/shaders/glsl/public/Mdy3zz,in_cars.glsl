// Shader downloaded from https://www.shadertoy.com/view/Mdy3zz
// written by shadertoy user eiffie
//
// Name: In Cars
// Description: Here in my car I feel safest of all. Use SPACE BAR for everything else. Chase the ball and put it in your (RED) goal.
//    A glitchy game written long long ago to be like Ball Blazer from Commodore 64 days. If this still crashes let me know!
#define RED vec3(1.0,0.2,0.3)
#define BLUE vec3(0.2,0.5,1.0)
#define MaxDepth 1000.0
#define PI 3.14159
#define FIELD_WIDTH 30.0
#define HALF_FIELD 15.0
#define WALL_HEIGHT 4.0
#define GOAL_WIDTH 0.5

//matrix math
mat3  rotAA(vec3 v, float angle){//axis angle rotation
	float c=cos(angle);vec3 s=v*sin(angle);
	return mat3(v.xxx*v,v.yyy*v,v.zzz*v)*(1.0-c)+mat3(c,-s.z,s.y,s.z,c,-s.x,-s.y,s.x,c);
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

float Pattern(in vec3 uv){
	return 0.5+0.5*sin(uv.x+sin(2.0*uv.y)+sin(3.0*(uv.z)+sin(0.5*uv.x*uv.y)));
}

struct Hit{vec3 n; vec2 uv; float dist,obj;};

//struct Triad{vec3 p1,p2,p3; vec2 t1,t2,t3;};//this was fancier but may crash??
// intersect a triangle
/*float iTri( in vec3 ro, in vec3 rd, in vec3 p, in mat3 mx, in Triad T, inout Hit H)
{//this is some very old code ripped from ???
	vec3 p1=p+mx*T.p1;
	vec3 u=p+mx*T.p2-p1;
	vec3 v=p+mx*T.p3-p1;
	vec3 n=cross(u,v);		//calc normal
	float r=dot(n,rd);
	if(r==0.0)return MaxDepth;
	vec3 w=ro-p1;
	r=dot(-n,w)/r;			//distance	
	if(r<0.0 || r>H.dist)return MaxDepth;
	p=ro+rd*r;			//hit point
	float uu=dot(u,u);
	float uv=dot(u,v);
	float vv=dot(v,v);
	w=p-p1;
	float wu=dot(w,u);
	float wv=dot(w,v);
	float d=uv*uv-uu*vv;
	float s=(uv*wv-vv*wu)/d;
	if(s<0.0||s>1.0)return MaxDepth;
	float t=(uv*wu-uu*wv)/d;
	if(t<0.0||(s+t)>1.0)return MaxDepth;
	d=1.0-t-s;
	if(p.y>0.43 && min(s,t)>0.05)return MaxDepth; //cut out windows
	H.uv=T.t1*d+T.t2*s+T.t3*t;	//texture coord
	H.n=n;
	H.obj=1.0;
	H.dist=r;
	return r;
}*/
//intersect a sphere
float iSph( in vec3 ro, in vec3 rd, in vec3 p, in mat3 mx, in float r, inout Hit H)
{//based on iq's
	p-=ro;
	float b=dot(p,rd);
	float inner=b*b-dot(p,p)+r*r;
	if(inner<0.0)return MaxDepth;
	float t=b-sqrt(inner);
	if(t<0.0 || t>H.dist)return MaxDepth;
	H.dist=t;
	H.obj=0.0;
	H.n=normalize((-p+rd*t)*mx);
	H.uv=vec2(atan(H.n.x,H.n.z)/PI,H.n.y*0.5+0.5);
	return t;
}
vec3 N[4];
void setup(){
	N[0]=normalize(vec3(0.0,0.3,-1.0));N[1]=normalize(vec3(-1.0,0.4,0.3));
	N[2]=normalize(vec3(1.0,0.4,0.3));N[3]=vec3(0.0,-1.0,0.0);
}
//intersect planes
float iGeod( in vec3 ro, in vec3 rd, in vec3 p, in mat3 mx, float r, inout Hit H)
{//a convex shape made by the intersecting planes
 //find the farthest facing plane nearer then the closest back-facing plane
	float t1=-MaxDepth,t2=MaxDepth;
	vec3 N1,N2;
	for(int i=0;i<4;i++){
		vec3 n=mx*N[i];
		float frontface=dot( n, -rd );
		float t = (dot( n, ro-p ) - ((i==0)?0.666:r)) / frontface;
		if(frontface>0.0){
			if(t>t1){N1=n;t1=t;}
		}else{
			if(t<t2){N2=n;t2=t;}
		}
	}
	if(t1<0.0 || t1>t2 || t1>H.dist)return MaxDepth;
	H.n=N1*mx;H.dist=t1;H.obj=1.0;H.uv=((ro+rd*t1-p)*mx).zy;
	return t1;
}
vec3 bps,cp;
mat3 bm,cm;

Hit GetHits(vec3 ro, vec3 rd){
	Hit H;
	H.dist=MaxDepth;
	iSph(ro,rd,bps,bm,0.2,H);
	iGeod(ro,rd,cp,cm,0.25,H);
	/*Triad T;
	T.p1=vec3(0.0,0.0,0.0);T.p2=vec3(0.0,-1.0,1.75);T.p3=vec3(-0.75,-1.0,-0.25); 
	T.t1=vec2(0.0,1.0);T.t2=vec2(1.0,0.0);T.t3=vec2(0.0);
	iTri(ro,rd,cp,cm,T,H);
	T.p3.x*=-1.0;
	iTri(ro,rd,cp,cm,T,H);
	T.p2=vec3(-0.75,-1.0,-0.25);
	iTri(ro,rd,cp,cm,T,H);*/
	return H;
}

//from iq
vec4 load(in int re) {
    return texture2D(iChannel0, (0.5+vec2(re,0.0)) / iResolution.xy, -100.0 );
}

// ==================================================
// Bit Packed Sprites by Flyguy
// https://www.shadertoy.com/view/XtsGRl
#define CHAR_SIZE vec2(3, 7)
float ch_1 = 730263.0;
float ch_2 = 693543.0;
float ch_3 = 693354.0;
float ch_4 = 1496649.0;
float ch_5 = 1985614.0;
float ch_6 = 707946.0;
float ch_7 = 1873042.0;
float ch_8 = 709994.0;
float ch_9 = 710250.0;
float ch_0 = 711530.0;

//Extracts bit b from the given number.
float extract_bit(float n, float b)
{
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

//Returns the pixel at uv in the given bit-packed sprite.
float sprite(float spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0)));
    bounds = bounds && all(lessThan(uv,size));
    
    return bounds ? extract_bit(spr, bit) : 0.0;

}
//Returns the sprite data for the given number.
float get_digit(int d)
{
    if(d == 0) return ch_0;
    if(d == 1) return ch_1;
    if(d == 2) return ch_2;
    if(d == 3) return ch_3;
    if(d == 4) return ch_4;
    if(d == 5) return ch_5;
    if(d == 6) return ch_6;
    if(d == 7) return ch_7;
    if(d == 8) return ch_8;
    if(d == 9) return ch_9;
    return 0.0;
}
float print_digit(int digit, vec2 uv){
	return sprite(get_digit(digit),CHAR_SIZE, uv);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	setup();
	vec4 lbp=load(0);
	vec4 lpp=load(1);
	bps=vec3(lbp.x,0.75,lbp.y);
	cp=vec3(lpp.z,0.25,lpp.w);
	vec3 ro=vec3(lpp.x,1.0,lpp.y);
	vec3 or=load(2).xyz;
	ivec4 gm=ivec4(load(3)+vec4(0.25));
	vec3 rd=vec3((2.0*fragCoord-iResolution.xy)/iResolution.y,1.0);
	bm=mat3(1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0);
	cm=rotAA(vec3(0.0,1.0,0.0),or.y-1.57);
	mat3 pm=rotAA(vec3(0.0,1.0,0.0),or.z-1.57);
	rd=normalize(pm*rd);
	vec3 L=normalize(vec3(0.7,0.6,0.4)); //light dir
	
	//draw the playing field
	vec3 col=mix(vec3(0.4,0.5,0.7),vec3(1.0),Pattern(rd*vec3(1.5,8.0,1.5)));
	if(rd.y<0.0){//ground
		float t=-ro.y/rd.y;
		vec2 p=abs(fract((ro.xz+rd.xz*t)*0.25)-vec2(0.5))-0.25;
		vec3 chk=mix(vec3(0.25),vec3(1.0),smoothstep(0.0,t*t*0.001,sign(p.x*p.y)*min(abs(p.x),abs(p.y))));
		//chk=mix(chk,vec3(0.35),clamp(t*0.03,0.0,1.0));
		col=mix(chk,col,clamp(t*0.01,0.0,1.0));
		Hit H=GetHits(ro+rd*t,L);
		if(H.dist<MaxDepth)col=min(col,vec3(0.15+H.dist*0.1));
	}
	float ct=MaxDepth;
	float t=(sign(rd.x)*HALF_FIELD-ro.x)/rd.x;
	if(t>0.0){//walls
		vec3 p=ro+rd*t;
		if(abs(p.z)<HALF_FIELD && p.y>0.0 && p.y<WALL_HEIGHT){
			col=mix(col,vec3(0.2,0.1,0.0),2.0*abs(fract(p.z)-0.5));
			ct=t;
		}
	}
	float sz=sign(rd.z);
	t=(sz*HALF_FIELD-ro.z)/rd.z;
	if(t>0.0){
		vec3 p=ro+rd*t;
		if(abs(p.x)<HALF_FIELD && p.y>0.0 && p.y<WALL_HEIGHT && abs(p.x)>GOAL_WIDTH){
			col=mix(col,(sz>0.0)?BLUE:RED,2.0*abs(fract(p.x)-0.5));
			if(t<ct)ct=t;
		}
	}
	
	//draw the ball and opponent
	Hit H=GetHits(ro,rd);
	if(H.dist<MaxDepth){
		if(H.obj==0.0)col=vec3(0.1,1.0,0.3);
		else col=mix(BLUE,vec3(0.2),smoothstep(0.4,0.405,H.uv.y));
		H.n=normalize(H.n);
		col*=0.5+0.5*dot(L,H.n);
		col+=vec3(1.0,0.9,0.7)*pow(max(0.0,dot(reflect(rd,H.n),L)),4.0);
		col+=mix(RED,BLUE,-dot(rd,H.n))*0.1;
	}
    //draw score
	float d1=print_digit(gm.x,fragCoord/iResolution.xy*100.0-vec2(10.0,90.0));
	float d2=print_digit(gm.y,fragCoord/iResolution.xy*100.0-vec2(80.0,90.0));
	col=mix(col,RED,d1);
	col=mix(col,BLUE,d2);
	fragColor=vec4(col,1.0);
}
