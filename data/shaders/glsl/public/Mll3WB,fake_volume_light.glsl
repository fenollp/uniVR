// Shader downloaded from https://www.shadertoy.com/view/Mll3WB
// written by shadertoy user eiffie
//
// Name: Fake Volume Light
// Description: Some really cheap volume light effect.
//Fake Volume Light by eiffie
//A one tap volume light effect

#define rez iResolution
#define tyme iGlobalTime

float Torus(in vec3 z, vec2 r){return length(vec2(length(z.xy)-r.x,z.z))-r.y;}
mat2 rm=mat2(cos(tyme),sin(tyme),-sin(tyme),cos(tyme));
float DE(in vec3 p){
	p+=vec3(0.0,-2.0,rm[0]);
	float dS=length(p)-0.5;
	p+=vec3(-3.0,3.0,0.0);
	p.xz=p.xz*rm;
	p.xy=rm*p.xy;
	float dB=length(max(abs(p)-vec3(0.5),0.0));
	p+=vec3(3.0,0.0,3.0);
	float dT=Torus(p.yzx,vec2(1.0,0.1));
	return min(dS,min(dB,dT));
}

vec4 scene(in vec3 ro, in vec3 rd, in vec2 fragCoord){
	vec3 col=vec3(0.0);
	vec3 LightPos=vec3(0.0);
	float rnd=fract(sin(fragCoord.x+cos(fragCoord.y))*4317.6219);
	float t=rnd,d;
	ro+=rd*t;
	for(int i=0;i<32;i++){
		t+=d=DE(ro);
		float l=length(LightPos-ro);
		float shad=clamp(2.0*(1.0+d)*DE(ro+d*(LightPos-ro)/l)/d,0.0,1.0);
		col+=exp(-l*5.0)+vec3(0.02)*clamp(1.0-l*0.1,0.0,1.0)*sqrt(d)*pow(shad,20.0);
		if(d<0.0001)break;
		ro+=rd*min(d,0.5);
	}
	return vec4(col,t);
}
mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float tim=tyme*0.6;
	vec3 ro=vec3(sin(tim)*2.0,sin(tim*0.7),cos(tim))*5.0;
	vec3 rd=lookat(-ro,vec3(0.0,1.0,0.0))*normalize(vec3((2.0*(fragCoord.xy)-rez.xy)/rez.y,1.0));
	vec4 color=scene(ro,rd,fragCoord);
	fragColor = vec4(color.rgb,1.0);
}
