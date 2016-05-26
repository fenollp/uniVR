// Shader downloaded from https://www.shadertoy.com/view/ldGGRD
// written by shadertoy user eiffie
//
// Name: Whippy Rope
// Description: A strange beaded rope. Haha IQ beat me to it with better cloth! (and better code) This should be more stable now.
//Whippy Rope by eiffie
//I uploaded this before realizing IQ made a nice cloth demo so that is a better
//example if you want to learn verlet.
//This has some fun features - to interact with the scene yet draw fast the
//rendering uses tracing and the physics uses distance estimates.
//I added some really bad but cheap AA that just takes 1 extra sample where
//the sub-pixel is most different in color. (or it tries to)

vec4 load(in vec2 re) {
	return texture2D(iChannel0, (0.25+floor(re))/iResolution.xy );
}

#define PI 3.14159
#define MAX_DEPTH 1000.0

struct Hit{float t,id; vec3 n;}; //distance, object id, normal

void Plane( in vec3 ro, in vec3 rd, in vec3 p, in vec3 n, in float id, inout Hit H)
{//intersect a plane
	p=ro-p;
	float t = -dot( n, p ) / dot( n, rd );
	if(t > 0.0 && t < H.t ){H.t=t;H.n=n;H.id=id;}
}

void Sphere( in vec3 ro, in vec3 rd, in vec3 p, in float r, in float id, inout Hit H)
{//intersect a sphere - based on iq's
	p=ro-p;
	float b=dot(p,rd);
	float h=b*b-dot(p,p)+r*r;
	if(h>0.0){
		float t=-b-sqrt(h);
		if(t>0.0 && t<H.t){
			H.t=t;
			H.id=id;
			H.n=normalize(p+rd*t);//mx*;
		}
	}
}
void Segment(in vec3 ro, in vec3 rd, in vec3 p1, in vec3 p2, in float r, in float id, inout Hit H)
{//intersect a tube (distance and normal are faked) mod from iq's
	p2-=p1;
	p1-=ro;
	float d=dot(rd,p2);
	float t=clamp((dot(rd,p1)*d-dot(p1,p2))/(dot(p2,p2)-d*d),0.0,1.0);
	p1+=ro+p2*t;
	Sphere(ro,rd,p1,r,id,H);
}
void Quadric(vec3 ro, vec3 rd, vec3 p, vec3 abc, float r, vec2 yCap, float id, inout Hit H)
{//intersect any quadric Ax^2 + By^2 + Cz^2 - r = 0  (this is only complicated because of the cap)
 //ex: ellipse: abc=vec3(1.0,0.5,1.0), cyl: abc=vec3(1.0,0.0,1.0), cone: abc=vec3(1.0,-1.0,1.0)
	p=ro-p ;//mx*(ro-p);rd=mx*rd;//for rotations
	vec2 pln=vec2(0.0);
	vec3 N;
	float Y_Plane=1.0,t1=MAX_DEPTH,t2=-MAX_DEPTH;
	if(yCap!=vec2(0.0)){ 
		pln=vec2(p.y-yCap)/-rd.y;
		if(pln.x>pln.y){pln.xy=pln.yx;Y_Plane=-Y_Plane;}
	}
	if(pln.y>=0.0){
		float A=dot(abc*rd,rd),B=2.0*dot(abc*p,rd),C=dot(abc*p,p)-abs(r)*r,inner=B*B-4.0*A*C;
		if(inner<0.0){//throw out if not inside (if inside your looking thru the middle of a cylinder etc.)
			if(C<0.0){t1=-MAX_DEPTH;t2=MAX_DEPTH;}
		}else{
			inner=sqrt(inner);
			vec2 t=vec2(-B-inner,-B+inner)/(2.0*A);
			if(t.x>t.y){if(t.y>0.0 && t.y>pln.x){t.x=-MAX_DEPTH;}t.y=MAX_DEPTH;}
			t1=t.x;t2=t.y;N=abc*(p+rd*t.x);
		}
		if(yCap!=vec2(0.0)){
			if(pln.x>t2 || pln.y<t1){t1=MAX_DEPTH;}//no hit
			else if(pln.x>t1){t1=pln.x;N=vec3(0.0,Y_Plane,0.0);}
		}
		if(t1>0.0 && t1<H.t){
			H.t=t1;H.id=id;H.n=normalize(N);//*mx;
		}
	}
}

vec4 GN(int i){//plane definitions for geod
    vec4 n=vec4(0.0,1.0,0.0,0.5);
    if(i==11)n.y=-n.y;
    else if(i>0){
        float j=mod(float(i)-1.0,5.0);
        float a=2.0*PI/5.0*j;
        float y=0.6;
        if(i>5){a+=PI/5.0;y=-y;}
		n=vec4(cos(a),y,sin(a),0.6);
    }
    return n;
}
void Geod( in vec3 ro, in vec3 rd, in vec3 p, in float id, inout Hit H)
{//a convex shape made by intersecting planes
 //find the farthest facing plane nearer then the closest back-facing plane
	p=ro-p;
	float t1=-MAX_DEPTH,t2=MAX_DEPTH;
	vec3 N1;
	for(int i=0;i<12;i++){
		vec4 n=GN(i); //mx*N[i].xyz;
		float frontface=dot( n.xyz, -rd );
		float t = (dot( n.xyz, p ) - n.w) / frontface;
		if(frontface>0.0){
			if(t>t1){N1=n.xyz;t1=t;}
		}else{
			if(t<t2){t2=t;}
		}
	}
	if(t1>0.0 && t1<=t2 && t1<H.t){
		H.t=t1;H.id=id;H.n=N1;//*mx;
	}
}

//matrix math - rotate vector with m*v, inverse with v*m
#define MAT_ID mat3(1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0)
mat3  rotAA(vec3 v, float angle){//axis angle rotation
	float c=cos(angle);vec3 s=v*sin(angle);
	return mat3(v.xxx*v,v.yyy*v,v.zzz*v)*(1.0-c)+mat3(c,-s.z,s.y,s.z,c,-s.x,-s.y,s.x,c);
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

void Intersect(in vec3 ro, in vec3 rd, inout Hit H){
	H.t=MAX_DEPTH;
	Plane(ro,rd,vec3(0.0,-1.0,0.0),vec3(0.0,1.0,0.0),0.0,H);
	Sphere(ro,rd,vec3(0.0),1.0,1.0,H);
	Quadric(ro,rd,vec3(2.0,0.0,0.0),vec3(1.0,0.1,1.0),0.5,vec2(0.5,-1.0),2.0,H);
	Quadric(ro,rd,vec3(-2.0,0.0,0.0),vec3(1.0,-0.3,1.0),0.1,vec2(0.3,-1.0),3.0,H);
	Geod(ro,rd,vec3(1.0,-0.5,2.0),4.0,H);
	for(int i=0;i<16;i++){//beads
		vec3 p1=load(vec2(i,0.0)).xyz;
		Sphere(ro,rd,p1,0.1,5.0,H);
        if(i>0){
			vec3 p2=load(vec2(i-1,0.0)).xyz;
			Segment(ro,rd,p1,p2,0.02,6.0,H);
		}
	}
}
void DoScene(out vec4 fragColor, in vec2 fragCoord){
	vec2 ms=(iMouse.x>0.0)?iMouse.xy/iResolution.xy:vec2(0.5);ms*=vec2(PI*2.0,PI*0.5);
	vec3 ro=vec3(cos(ms.x)*cos(ms.y),sin(ms.y),sin(ms.x)*cos(ms.y))*3.0;
	vec3 rd=lookat(-ro)*normalize(vec3((2.0*fragCoord-iResolution.xy)/iResolution.y,1.0));
	Hit H;
	Intersect(ro,rd,H);
	vec3 col=vec3(0.0),L=normalize(vec3(0.3,1.0,0.5));
	if(H.t<MAX_DEPTH){
		if(H.id==0.0){
			vec2 p=abs(fract((ro.xz+rd.xz*H.t)*0.25)-vec2(0.5))-0.25;
			col=mix(vec3(0.25),vec3(0.75),smoothstep(0.0,H.t*H.t*0.0001,sign(p.x*p.y)*min(abs(p.x),abs(p.y))));
		}else{
			col=abs(cos(vec3(H.id,H.id+0.3,H.id+0.8)));
		}
		col*=max(0.1,dot(H.n,L));
		col+=vec3(1.0,0.9,0.7)*pow(max(0.0,dot(reflect(rd,H.n),L)),4.0);
		float h=1.1+dot(H.n,rd)*0.2;
		col*=vec3(h,1.0,1.0/h);
		col*=exp(-H.t*0.1);
		h=-H.n.y;
		Intersect(ro+rd*(H.t-0.001),L,H);
		if(H.t<MAX_DEPTH)col=min(col,vec3(0.1));
		col+=vec3(0.1,0.15,0.2)*max(0.0,h);
		
	}
	fragColor=vec4(col,1.0);
}

float dot2(vec3 v){return dot(v,v);}

//1+1(rarely) AA
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	//if(fragCoord.x<10.0){fragColor=vec4(1.0,0.0,0.0,1.0);return;}
	vec3 c00=texture2D(iChannel1,(fragCoord.xy+vec2(0.0,0.0))/iResolution.xy).rgb;
	vec3 c10=texture2D(iChannel1,(fragCoord.xy+vec2(1.0,0.0))/iResolution.xy).rgb;
	vec3 c01=texture2D(iChannel1,(fragCoord.xy+vec2(0.0,1.0))/iResolution.xy).rgb;
	vec3 c11=texture2D(iChannel1,(fragCoord.xy+vec2(1.0,1.0))/iResolution.xy).rgb;
	
	vec2 v=vec2(dot2(c00-c10),dot2(c00-c10))+vec2(dot2(c00-c11)*0.5);
	float mx=max(v.x,v.y);//clamp(length(v),0.0,1.0);
	if(mx>0.1){//is there enough difference to care?
		//fragColor=vec4(0.0,1.0,mx*0.5,1.0);return;
		vec2 coord=fragCoord.xy+v/mx*0.5; //find the new point to sample
		DoScene(fragColor,coord);
		fragColor=mix(vec4(c00,1.0),fragColor,0.4+clamp(0.15*length(v),0.0,0.35));
	}else fragColor=vec4(c00,1.0);
}
