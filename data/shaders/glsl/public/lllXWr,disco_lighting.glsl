// Shader downloaded from https://www.shadertoy.com/view/lllXWr
// written by shadertoy user eiffie
//
// Name: Disco Lighting
// Description: I am a silent carrier of disco fever.

//only one ball when showing reflections on walls
//#define SHOW_WALL_REFLECTIONS

#define MARCH_STEPS 32
#define MAX_DEPTH 20.0
#define MIN_DIST 0.001
#define TILE_SIZE 0.125
#define BALL_RADIUS 0.5
float SPREAD=0.1+sin(iGlobalTime)*0.09,SPIN=-iGlobalTime*0.6;

vec3 sph1=vec3(1.0,0.0,0.0),sph2=vec3(0.0,0.1,1.25),sph3=vec3(-0.5,0.15,0.0);

float Sphere(vec3 pos, float r, vec3 ro, vec3 rd){
	vec3 p=pos-ro;
	float b=dot(p,rd),h=b*b-dot(p,p)+r*r;
	if(h>0.0)h=b-sqrt(h);
	return h>0.0?h:MAX_DEPTH;
}
float Box(vec3 p, vec3 s, vec3 ro, vec3 rd){//insideout box
	p-=ro;
	vec3 f=max((p-s)/rd,(p+s)/rd);
	return min(f.x,min(f.y,f.z));
}
vec3 DiscoNormal(vec3 p){
	float a=atan(p.z,p.x)+SPIN,b=atan(p.y,length(p.xz));
	b-=mod(b,TILE_SIZE)-TILE_SIZE*0.5;
	float ts=TILE_SIZE+b*b*0.15;
	a-=mod(a+b,ts)-ts*0.5+SPIN;
	float cb=cos(b);
	return vec3(cb*cos(a),sin(b),cb*sin(a));
}
vec4 VolLights(in vec3 p){
#ifdef SHOW_WALL_REFLECTIONS
	float d1=max(-p.y,0.005*sin(p.y*150.0)+length(p.xz-sph3.xz));
#else
	float d1=max(-p.y,0.005*sin(p.y*150.0)+min(length(p.xz-sph1.xz),min(length(p.xz-sph2.xz),length(p.xz-sph3.xz))));
#endif
	p.y-=1.0;//+=10.0;
	p.z=abs(p.z)-2.0;
	float a=atan(p.x,-p.y),b=a*0.5;
	a+=sin(iGlobalTime*2.4)*0.1;
	a=clamp(a,-SPREAD,SPREAD)*2.0-a;
	a=clamp(a,-SPREAD/3.0,SPREAD/3.0)*2.0-a;
	p.x=length(p.xy)*sin(a);
	float d=length(p.xz);
	if(d1<d){d=d1;b=-0.5;}
	vec3 col=vec3(0.5+b,0.3-b,1.0)*exp(-d*100.0);
	return vec4(col,d);
}

vec3 Background(in vec3 rd){
	vec3 col=vec3(0.25)+vec3(0.125,0.05,0.125)*(rd+sin(rd*6.0+2.4*sin(rd.yzx*5.3+iGlobalTime)));
	col+=pow(abs(rd),vec3(80.0))+pow(abs(rd.yzx),vec3(120.0));
	return clamp(col,0.0,1.0);
}

vec3 trace(inout vec3 ro, inout vec3 rd){
	vec3 col=vec3(0.0),vol=vec3(0.0);
	float b3=Sphere(sph3,BALL_RADIUS,ro,rd);
	vec3 p=sph3;
#ifndef SHOW_WALL_REFLECTIONS
	float b1=Sphere(sph1,BALL_RADIUS,ro,rd);
	float b2=Sphere(sph2,BALL_RADIUS,ro,rd);
	if(b1<b3){b3=b1;p=sph1;}
	if(b2<b3){b3=b2;p=sph2;}
#endif
	float w=min(Box(vec3(4.0,-10.0,0.0),vec3(11.0),ro,rd),b3);
	float d,t=0.0;
	for(int i=0;i<MARCH_STEPS;i++){
		if(t>w)continue;
		vec4 v=VolLights(ro+rd*t);
		vol+=v.rgb;
		t+=v.w;
		//if(t>w)break;
	}
	if(b3<MAX_DEPTH){
		vec3 N=DiscoNormal(ro-p+rd*b3);
		vec3 L=normalize(vec3(-0.6,0.7,0.5));
		vec3 R=reflect(rd,N);
		float dif=max(dot(N,L),0.0);
		float amb=0.5+0.5*N.y;
		float spe=pow(max(dot(R,L),0.0),16.0);
		float vis=abs(dot(rd,N));
		vec3 brdf=dif*vec3(1.0)+amb*vec3(0.3)+spe*vec3(1.0);
		col=mix(brdf,Background(R)*vis,1.0-vis*0.5);
		ro+=rd*(b3-MIN_DIST);
		rd=R;
	}else {
		col=Background(rd)*0.2;
		ro+=rd*w;
#ifdef SHOW_WALL_REFLECTIONS
		rd=normalize(ro-sph3);
		ro=sph3+rd*(BALL_RADIUS+MIN_DIST);
		rd=reflect(DiscoNormal(rd*BALL_RADIUS),-rd);
#endif
	}
	return col+vol;
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;

	// camera	
	vec3 ro = vec3(cos(iGlobalTime*0.3)*2.0,sin(iGlobalTime*0.2)-0.25,sin(iGlobalTime*0.3)*3.0); //camPath(time);
	vec3 ta = vec3(0.0);

	// camera-to-world transformation
	mat3 ca = setCamera( ro, ta, 0.0 );
    
	// ray direction
	vec3 rd = ca * normalize( vec3(p.xy,2.5) );
	
	// render	
	vec3 col=trace(ro,rd);
	col+=trace(ro,rd)*0.75;
	col+=trace(ro,rd)*0.5;

	//col = pow( col, vec3(0.4545) );

	fragColor=vec4( col, 1.0 );
} 
