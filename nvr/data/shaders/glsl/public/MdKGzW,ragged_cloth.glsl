// Shader downloaded from https://www.shadertoy.com/view/MdKGzW
// written by shadertoy user eiffie
//
// Name: Ragged Cloth
// Description: Trying to render a 40x40 cloth (1600 points) in 3d with 100 texture calls.
//    Now it is getting tricky!
//    The original by iq: [url]https://www.shadertoy.com/view/4dG3R1[/url]
//Trying to render large clothes in 3d - eiffie
//This code is based on iq's 2d Cloth at https://www.shadertoy.com/view/4dG3R1
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


float hash1( vec2 p ) { float n = dot(p,vec2(127.1,311.7)); return fract(sin(n)*43758.5453); }

vec3 getParticle( vec2 id )
{
	id+=vec2(20.0);
	id=clamp(id,0.0,39.0);
    return texture2D( iChannel0, (id+0.5)/iResolution.xy ).xyz;
}

//this bit is experimental (well it ALL is) but this tries to find the poly
//#define TRY_TRIANGLES
#ifdef TRY_TRIANGLES

struct Hit{float t,id;vec3 n; vec2 uv;};

void iTri(in vec3 ro, in vec3 rd, in vec3 p1, in vec3 p2, in vec3 p3, in float id, inout Hit H){
	vec3 e1=p2-p1,e2=p3-p1,pv=cross(rd,e2),tv=ro-p1;
	H.n+=normalize(cross(e1,e2));
	float dd=1./dot(e1,pv),u=dot(tv,pv)*dd;
	if(u<0.0||u>1.0) return;
	vec3 qv=cross(tv,e1);
	float v=dot(rd,qv)*dd;
	if(v<0.0||v>1.0||(u+v)>1.0) return;
	float t=dot(e2,qv)*dd;
	if(t>0.0 && t<H.t){H.t=t;H.id=id;H.uv=vec2(u,v);}
}
void TriN(in vec3 p1, in vec3 p2, in vec3 p3, inout Hit H){
	vec3 e1=p2-p1,e2=p3-p1;
	H.n+=normalize(cross(e1,e2));
}
vec3 TriNS(vec3 A, vec3 B, vec3 C, vec3 P)
{
	vec3 v0 = C - A;
	vec3 v1 = B - A;
	vec3 v2 = P - A;

	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);
		
	// Compute barycentric coordinates
	float invDenom = 1. / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	return vec3(1.0-u-v,v,u);

}
#define maxDepth 10.0
vec4 scene(vec3 ro, vec3 rd, vec4 ids){
	Hit H; H.t=maxDepth; H.id=0.0; H.n=vec3(0.0);
	vec4 idsave=ids;
	for(int i=0;i<4;i++){
		if(ids.x>-1.0){
			float fid=float(i)*4.0;
			vec2 id=vec2(mod(ids.x,40.0),floor(ids.x/40.0))-vec2(20.0);
			vec3 p1=getParticle(id);
			vec3 p2=getParticle(id+vec2(1.0,0.0));
			vec3 p3=getParticle(id+vec2(0.0,1.0));
			iTri(ro,rd,p1,p2,p3,fid++,H);
			vec3 p4=getParticle(id+vec2(-1.0,0.0));
			iTri(ro,rd,p1,p3,p4,fid++,H);
			p3=getParticle(id+vec2(0.0,-1.0));
			iTri(ro,rd,p1,p4,p3,fid++,H);
			iTri(ro,rd,p1,p3,p2,fid++,H);
			ids=ids.yzwx;
		}
	}
	ids=idsave;
	vec4 col=vec4(0.0,0.0,0.0,1.0);
	if(H.t<maxDepth){
		float fid=floor(H.id*0.25);
		for(int i=0;i<4;i++)if(float(i)<fid)ids=ids.yzwx;
		vec2 idn[3];
		idn[0]=vec2(mod(ids.x,40.0),floor(ids.x/40.0))-vec2(20.0);
		vec2 o2=vec2(1.0,0.0),o3=vec2(0.0,1.0);
		fid=mod(H.id,4.0);
		if(fid>0.5)o2=vec2(-1.0,0.0);
		if(fid>1.5)o3=vec2(0.0,-1.0);
		if(fid>2.5)o2=vec2(1.0,0.0);
		idn[1]=idn[0]+o2;idn[2]=idn[0]+o3;
		vec3 N[3],P[3];
		
		//now recalc the normals for each vertex in the triangle we hit
		for(int i=0;i<3;i++){
			vec2 id=idn[i];
			H.n=vec3(0.0);
			vec3 p1=getParticle(id);P[i]=p1;
			vec3 p2=getParticle(id+vec2(1.0,0.0));
			vec3 p3=getParticle(id+vec2(0.0,1.0));
			TriN(p1,p2,p3,H);
			vec3 p4=getParticle(id+vec2(-1.0,0.0));
			TriN(p1,p3,p4,H);
			p3=getParticle(id+vec2(0.0,-1.0));
			TriN(p1,p4,p3,H);
			TriN(p1,p3,p2,H);
			N[i]=normalize(H.n);
		}
		vec3 n=TriNS(P[0],P[1],P[2],ro+rd*H.t);
		n=normalize(N[0]*n.x+N[1]*n.y+N[2]*n.z);
		vec3 L=normalize(vec3(0.3,1.0,0.6));
		vec3 scol=vec3(1.0,0.7,0.4)*abs(dot(n,L));
		col=vec4(scol,1.0);
	}
	return col;
}
#endif
float Length(vec3 p, vec3 rd){//p=p-ro
	float b=dot(p,rd);
	return sqrt(dot(p,p)-b*b);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 ro=vec3(0.5,0.5,-1.0);
    vec3 rd=normalize(vec3((2.0*fragCoord-iResolution.xy)/iResolution.y,1.75));
	vec2 id=vec2(-20.0);//-20 to 20 for ease of addressing
	//float h=Length(-ro,rd);
	//fragColor=vec4(h);return;
	float dr=1.0;//direction of search thru x
	vec4 idsave=vec4(-1.0);
	vec4 mn=vec4(100.0);
#ifdef TRY_TRAINGLES
    for(int i=0;i<200;i++){
#else
	for(int i=0;i<100;i++){
#endif
		if(id.y>19.0)break;//we are done marching
		vec3 p = getParticle( id.xy );
		float d=Length(p-ro,rd);
		if(d<0.1){//less than rest length/fudge
			float fid=(id.y+20.0)*40.0+id.x+20.0;
			if(d<mn.x){mn=vec4(d,mn.xyz);idsave=vec4(fid,idsave.xyz);}
#ifdef TRY_TRIANGLES
			else if(d<mn.y){mn=vec4(mn.x,d,mn.yz);idsave=vec4(idsave.x,fid,idsave.yz);}
			else if(d<mn.z){mn=vec4(mn.xy,d,mn.z);idsave=vec4(idsave.xy,fid,idsave.z);}
			else if(d<mn.w){mn.w=d;idsave.w=fid;}
#endif
		}
		
		d=floor(0.8*d/0.025)+1.0;//scale d back to ID length using rest length (then fudge!)
		if(abs(id.x+d*dr+0.5)>19.5){//turn around and weave the cloth
			id.y+=1.0;
			id.x-=(d-1.0)*dr;//get a bit of a head start
			dr=-dr;//change direction
		}else id.x+=d*dr; //march
	}
#ifdef TRY_TRIANGLES
    fragColor=scene(ro,rd,idsave);
#else
	vec3 f=mix(vec3(0.75),vec3(0.0),smoothstep(0.0,0.01,mn.x));
	fragColor=vec4(f,1.0);
#endif
	
}
