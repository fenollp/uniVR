// Shader downloaded from https://www.shadertoy.com/view/Mlf3Df
// written by shadertoy user eiffie
//
// Name: Eiffie Balls
// Description: This shader speaks to the human condition... you know... the itchy one.
//Eiffie Balls (you don't want to know)

#define TAO 6.283

float tym=0.0;
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}
float DERect(in vec2 z, vec2 r){return max(abs(z.x)-r.x,abs(z.y)-r.y);}
vec2 EBall(vec3 p, float c){
	p.zy=rotate(p.zy,c+tym*4.3);
	p.xz=rotate(p.xz,c+tym*2.0);
	c=mod(c,6.0);
	float dB=length(p);
	float s=0.8*dB;
	p*=1.0/s;
	float d=DERect(p.xy,vec2(0.25,0.9));//I
	if(c!=1.0 && c!=4.0){
		d=min(d,min(DERect(p.xy+vec2(0.25,-0.7),vec2(0.5,0.2)),DERect(p.xy+vec2(0.25,0.0),vec2(0.5,0.2))));//F
		if(c==0.0 || c==5.0)d=min(d,DERect(p.xy+vec2(0.25,0.7),vec2(0.5,0.2)));//E
	}
	float L=clamp((1.0-dB),0.0,1.0);
	return vec2(max(dB-0.1,-d*s),L*smoothstep(0.05,-0.05,d));
}

vec2 sort(vec2 a, vec2 b){return vec2((a.x<b.x)?a.x:b.x,a.y+b.y);}//(a.y>b.y)?a.y:b.y);}
vec2 DE(in vec3 p){
	const float pdvt=64.0/TAO,tdvp=TAO/64.0;
	float a=atan(p.z,p.x)*pdvt;
	float c=floor(a)-1.0;
	a=(c+0.5)*tdvp;
	vec3 P=vec3(cos(a)*8.0,0.0,sin(a)*8.0)+sin(c*2.0+tym)*0.2;
	vec2 d=EBall(p-P,c);
	c+=1.0;
	a=(c+0.5)*tdvp;
	P=vec3(cos(a)*8.0,0.0,sin(a)*8.0)+sin(c*2.0+tym)*0.2;
	d=sort(d,EBall(p-P,c));
	c+=1.0;
	a=(c+0.5)*tdvp;
	P=vec3(cos(a)*8.0,0.0,sin(a)*8.0)+sin(c*2.0+tym)*0.2;
	d=sort(d,EBall(p-P,c));
	return d;
}
vec4 Norm(in vec3 p){
	const float pdvt=64.0/TAO,tdvp=TAO/64.0;
	float a=atan(p.z,p.x)*pdvt;
	float c=floor(a);
	a=(c+0.5)*tdvp;
	vec3 P=vec3(cos(a)*8.0,0.0,sin(a)*8.0)+sin(c*2.0+tym)*0.2;
	return vec4(normalize(p-P),c);
}
/*float sinNoise2d(in vec2 p,float tyme){
	float s=0.5,r=0.0;
	for(int i=0;i<3;i++){
		p+=p+sin(1.7*p.yx+tyme);
		s*=0.5;
		r+=sin(p.x+sin(2.0*p.y))*s;
	}
	return r;
}*/
const mat2 m2 = mat2(.8,.6,-.6,.8);
//from guil https://www.shadertoy.com/view/MtfGDX

float sinNoise2d(in vec2 p, float tyme){

    float res=0.;
    float f=1.;
	for( int i=0; i< 3; i++ ) 
	{		
        p=m2*p*f+.6;     
        f*=1.2;
        res+=sin(p.x+sin(2.*p.y+tyme)-tyme);
	}        	
	return res/3.;
}
float rand(vec2 c){return fract(sin(c.x+2.4*sin(c.y))*34.1234);}
vec4 scene(vec3 ro, vec3 rd) {
	float tG=(-0.5-ro.y)/rd.y;
	float tMax=(tG<0.0)?20.0:min(20.0,tG);
	float t=0.5*rand(gl_FragCoord.xy);//vaporize them if too close
	vec2 d;
	vec3 sum=vec3(0.0),p=ro+rd*t,col=vec3(0.0);
	for(int i=0;i<99;i++){
		d=DE(p);
		if(d.x<1.0){
			sum+=(sin(p)*0.5+0.5)*d.y*d.y*0.1;
			d.x=min(d.x,0.1);
		}else d.x=d.x-0.75;
		t+=d.x;
		p+=rd*d.x;
		if(t>tMax || d.x<0.001)break;
	}
	
	if(tMax<=tG && d.x>=0.01){//t>min(tMax-1.0,10.0)){
		vec3 p=ro+rd*tG;
		d=DE(p);
		if(d.x<1.0){
			sum+=(sin(p)*0.5+0.5)*d.y;
		}
		float n=2.0*abs(sinNoise2d(p.xz,tym*4.0));
		col=0.25*exp(-tG*0.1)+(vec3(1.0)+vec3(sin(n),cos(n),sin(n*0.3)))*0.05*n;
	}else if(d.x<0.01){
		sum+=(sin(p)*0.5+0.5)*d.y*0.5;
		vec4 N=Norm(p);
		col=(vec3(1.0)+vec3(sin(N.w),cos(N.w),sin(N.w*0.3)))*max(0.0,0.2*dot(N.xyz,normalize(vec3(-0.4,0.8,0.2))));
	}else{
		vec2 pt=vec2(abs(atan(rd.z,rd.x))/3.1416,rd.y*2.0);
		pt.y=sqrt(abs(pt.y));
		col=vec3((0.2+0.1*sinNoise2d(pt*5.0,0.0))*pt.y);
	}

	col=clamp(col+sum,0.0,1.0);
	return vec4(col,t);
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
vec3 path(float tyme){return vec3(cos(tyme),abs(sin(tyme*0.7))*0.1,sin(tyme))*(7.5+sin(tyme));}
void SetCamera(inout vec3 ro, inout vec3 rd, float tyme, vec2 uv){
	ro=path(tyme);
	vec3 ta=path(tyme+0.2);ta.y=0.0;
	rd=lookat(ta-ro)*normalize(vec3(uv,1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy -iResolution.xy)/ iResolution.y;
    vec3 ro,rd;
    SetCamera(ro,rd,iGlobalTime*0.5,uv);
    vec4 col=scene(ro,rd);
	fragColor = vec4(col.rgb,1.0);
}