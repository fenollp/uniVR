// Shader downloaded from https://www.shadertoy.com/view/lsK3Dt
// written by shadertoy user eiffie
//
// Name: Drifter              
// Description: Like asteroids only your engine is dead and you're surrounded by aliens. Mouse or arrow keys to aim, space to shoot and R to restart. 
//Drifter by eiffie
//like asteroids...https://www.shadertoy.com/view/4l2GzR & https://www.shadertoy.com/view/4llSD2
//only your engine is dead and you're surrounded by aliens
//mouse or arrow keys to aim, space to shoot, R to restart
#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)

#define HALF_FIELD vec2(20.0,15.0)

//https://www.shadertoy.com/view/4dsSzN funpatterns by cafe (editted by FabriceNeyret2)
float rand (vec2 co){  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }
#define pix(U)  step(.5, rand(floor(U)))
float hm(vec2 uv, float tim){
    uv.y+=tim;
    if(uv.y<25.0)return 0.0;
    uv*=0.2;
	vec2 nuv = 2.*fract(uv)-1.,
	     pos = sign(nuv)*.9;
	float d = max(max(abs(nuv.x),abs(nuv.y)),max(abs(nuv.x+nuv.y),abs(nuv.x-nuv.y))*0.707),	
	      v = pix(uv);
    if (d<1.) return v;
	float v0 = v,
          v1 = pix(uv+vec2(pos.x,0)),
	      v2 = pix(uv+vec2(0,pos.y));
	if (v1==v2)	v = v==pix(uv+pos) && v!=v1 ? 0. : v1;
	return mix(v0, v, smoothstep(d,1.,1.001));
}

float Quadric(in vec2 p,in vec3 r){return (dot(p*r.xy,p)-r.z)/length(2.0*r.xy*p);}
float Arc(in vec2 p, vec4 r) {float t=clamp(atan(p.y,p.x),r.z,r.w);return length(p-r.x*vec2(cos(t),sin(t)))-r.y;}
float Tube(vec2 pa, vec2 ba, float r){return length(pa-ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0))-r;}
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
vec2 cossin(float a){return vec2(cos(a),sin(a));}

float DES(vec2 p){
	float d=abs(Quadric(p,vec3(0.5,1.0,0.25)))-0.01;
	d=min(d,Arc(p-vec2(0.0,0.75),vec4(1.0,0.01,-2.14,-1.05)));
	vec2 ap=abs(p);
	d=min(d,Tube(ap-vec2(0.22,0.47),vec2(0.11,0.25),0.01));
	p.x=abs(p.x);
	p-=vec2(0.22,0.47)+vec2(0.11,0.25)*1.33;
	d=min(d,abs(length(p)-0.08)-0.01);
	p.y+=1.54;
	d=min(d,max(abs(p.x)-0.1,abs(p.y)-0.01));
	return d;
}
float DEP(vec2 p){
	p.y=abs(p.y);p.x-=0.5;
	float d=Tube(p,vec2(-1.,0.5),0.01);
	return d;
}

// Letter code (https://dl.dropboxusercontent.com/u/14645664/files/glsl-text.txt)
const float lineWidth = 0.02,border = 0.05,scale = 0.15;
float line(vec2 p, vec2 s, vec2 e) {s*=scale;e*=scale;float l=length(s-e);vec2 d=vec2(e-s)/l;p-=vec2(s.x,-s.y);p=vec2(p.x*d.x+p.y*-d.y,p.x*d.y+p.y*d.x);return length(max(abs(p-vec2(l/2.0,0))-vec2(l/2.0,lineWidth/2.0),0.0))-border;}
float E(vec2 p){float d=line(p,vec2(5,1.5),vec2(1,1.5));d=min(d,line(p,vec2(1,1.5),vec2(1,5)));d=min(d,line(p,vec2(1,5),vec2(3,5)));d=min(d,line(p,vec2(3,5),vec2(1,5)));d=min(d,line(p,vec2(1,5),vec2(1,8)));d=min(d,line(p,vec2(1,8),vec2(5,8)));return d;}
float L(vec2 p){float d=line(p,vec2(1,1.5),vec2(1,8));d=min(d,line(p,vec2(1,8),vec2(5,8)));return d;}
float O(vec2 p){float d=line(p,vec2(5,1.5),vec2(1,1.5));d=min(d,line(p,vec2(1,1.5),vec2(1,8)));d=min(d,line(p,vec2(1,8),vec2(5,8)));d=min(d,line(p,vec2(5,8),vec2(5,1.5)));return d;}
float R(vec2 p){float d=line(p,vec2(1,8),vec2(1,1.5));d=min(d,line(p,vec2(1,1.5),vec2(5,1.5)));d=min(d,line(p,vec2(5,1.5),vec2(5,5)));d=min(d,line(p,vec2(5,5),vec2(1,5)));d=min(d,line(p,vec2(1,5),vec2(3.5,5)));d=min(d,line(p,vec2(3.5,5),vec2(5,8)));return d;}
float S(vec2 p){float d=line(p,vec2(5,1.5),vec2(1,1.5));d=min(d,line(p,vec2(1,1.5),vec2(1,5)));d=min(d,line(p,vec2(1,5),vec2(5,5)));d=min(d,line(p,vec2(5,5),vec2(5,8)));d=min(d,line(p,vec2(5,8),vec2(1,8)));return d;}
float V(vec2 p){float d=line(p,vec2(1,1.5),vec2(3,8));d=min(d,line(p,vec2(3,8),vec2(5,1.5)));return d;}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 p=fragCoord/iResolution.xy;
	vec4 st0=load(32);
	vec4 st1=load(33);
    vec4 st2=load(34);
	float r=rand(p);
	vec3 col=vec3(sin(fragCoord),0.75)*pow(r*0.99,40.0);
	p-=0.5;p*=1.9*HALF_FIELD;
    float d=hm(p,st2.x);
    col=mix(col,vec3(0.5),d);
	d=DEP(rotate(p-st0.xy,st1.z));
	for(int i=0;i<16;i++){
		vec2 s=load(i).xy;
		d=min(d,DES(p-s));
		s=load(i+16).xy;
		d=min(d,length(p-s)-0.02);
	}
	if(abs(st0.x)>999.0){
		p+=vec2(2.5,-0.5);
		d=min(d,L(p));p.x-=1.0;
		d=min(d,st0.x<0.0?O(p):E(p));p.x-=1.0;
		d=min(d,st0.x<0.0?S(p):V(p));p.x-=1.0;
		d=min(d,E(p));p.x-=1.0;
		d=min(d,st0.x<0.0?R(p):L(p));p.x-=1.0;
        if(st0.x>0.0){p.x=-(p.x-2.0);d=min(d,st0.x<1500.0?S(p):E(p));}
	}
	d=smoothstep(0.0,0.1,d);
	col=mix(vec3(1.0),col,d);
	fragColor=vec4(col,1.0);
}