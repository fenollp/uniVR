// Shader downloaded from https://www.shadertoy.com/view/XtjGDd
// written by shadertoy user eiffie
//
// Name: Cheby'd Menger
// Description: Making sure these weird rotations work with Ray-Marching before I spend time trying to do Squircle Rotation.
#define Pi 4.0
float Cos(float a){return clamp(abs(mod(a,2.0*Pi)-Pi)-Pi/2.0,-1.0,1.0);}
float Sin(float a){return Cos(a-Pi/2.0);}
vec2 CosSin(float a){return vec2(Cos(a),Sin(a));}
float Length(vec2 p){return max(abs(p.x),abs(p.y));}//==(x^inf+y^inf)^(1/inf)
float Length(vec3 p){return max(abs(p.x),max(abs(p.y),abs(p.z)));}
float Atan(vec2 p){
	if(p.y==0.0)return (p.x>0.0?0.0:4.0);
	float a=p.x/p.y;
	if(abs(a)<1.0){
		if(p.y>0.0)return 2.0-a;
		else return 6.0-a;
	}else {
		a=p.y/p.x;
		if(p.x>0.0)return mod(a,8.0);
		else return 4.0+a;
	}
}
vec2 Rotate(vec2 p,float a){return CosSin(Atan(p)+a)*Length(p);}

const int iters=4;
float psni=pow(3.0,-float(iters)),tym=iGlobalTime;
float DE(in vec3 p){//menger with chebyshev rotation
	p.xy=Rotate(p.xy,tym);
	//p.xz=Rotate(p.xz,tym);//for more weirdness
	for (int n = 0; n < iters; n++) {
		p = abs(p);
		if (p.x<p.y)p.xy = p.yx;
		if (p.x<p.z)p.xz = p.zx;
		if (p.y<p.z)p.yz = p.zy;
		p = p*3.0 - 2.0;
		if(p.z<-1.0)p.z+=2.0;
	}
	return (Length(p)-1.0)*psni*0.707;//.707 compensates for the square rotation
}

vec3 scene(vec3 ro, vec3 rd){
	vec3 col=(0.5+0.5*rd.y)*vec3(0.9,0.9,1.0);
	float t=0.0,d=0.001,dL;
	for(int i=0;i<64;i++){
		dL=d;
		t+=d=DE(ro+rd*t);
		if(d<0.001 || t>10.0)break;
	}
	if(d<0.4){
		col=clamp((1.0-t/(1.0+length(ro))+0.64*d/dL)*(vec3(1.0,0.9,0.9)+ro*0.05+rd*0.2),0.0,1.0);		
	}
	return col;
}

mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv=(2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
	vec3 ro=vec3(max(-0.1+abs(sin(tym))*0.1,cos(tym)),cos(tym*0.3),sin(tym))*3.0;
	vec3 rd=lookat(-ro)*normalize(vec3(uv,2.0));
	vec3 col=scene(ro,rd);//eye,normalize(dir));
	fragColor = vec4(col,1.0);
}