// Shader downloaded from https://www.shadertoy.com/view/4dGGz3
// written by shadertoy user eiffie
//
// Name: City Driving
// Description: Driving your scooter through the fog at night probably isn't a good idea... but flipping off that guy with no headlights was just plain dumb.
//City Driving by eiffie
//I was just checking performance before making a game.
#define PI 3.14159
//originally from iq and mods by others
#define inside(a) (fragCoord.y-a.y == 0.5 && (fract(a.x) == 0.1 || fragCoord.x-a.x == 0.5))
#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)
#define save(a,b) if(inside(vec2(a,0.0))){fragColor=b;return;}

vec2 rep(vec2 p, vec2 a){return abs(mod(p+a,a*2.0)-a);}
float RRomb(vec3 p, vec4 r, vec3 d){return length(max(abs(p)-r.xyz+p.y*vec3(abs(p.x+d.y)*d.x*2.0,0.0,abs(p.z)*d.z*2.0),0.0))-r.w;}
vec3 CO;mat3 MX;
float DEC(in vec3 p){
	p=MX*(p-CO);
	p*=5.0;
	p.xz=p.zx;p.z=-p.z;//flippin car, i can't tell which is the front
	p.y+=0.275;
	float h=0.07-0.01*p.x;
	float dB=RRomb(p,vec4(0.75,h,0.33,0.08), vec3(-0.1,-0.15,-0.12));
	if(dB>1.0)return dB-0.5;
	float dC=RRomb(p-vec3(0.1,0.23,0.0),vec4(0.31,h,0.3,0.05), vec3(0.74,-0.18,0.55));
	p.x=abs(p.x)-0.48;
	p.y+=0.09;
	float r=length(p.xy);
	dC=max(min(dB,dC)*0.9,-(r-0.17));
	float dT=length(max(vec2(r-0.1,abs(abs(p.z)-0.35)-0.05),0.0))-0.03;
	return min(dC,dT)*0.2;
}
float DE(vec3 z0){//amazing surface/box thnx to kali/tglad
	float dC=DEC(z0);
	vec2 q=z0.xz*0.1;
	float th=(sin(q.x+cos(q.y))+sin(q.y+cos(q.x)))-0.1;
	z0.xz=rep(z0.xz,vec2(4.25));
	vec4 z=vec4(z0,1.0);
	vec2 c=vec2(1.0,0.66);
	float dS=z0.y+2.0,dB=length(vec2(length(max(abs(z.xz)-vec2(0.5),0.0))-3.6,z.y+th))-0.36;//ground,tunnel

	z.xz=clamp(z.xz, -1.0, 1.0) *2.0-z.xz;
	z*=2.0/clamp(dot(z.xyz,z.xyz),0.75,1.37);
	z.yz+=c;
	dS=min(dS,(length(max(abs(z.xyz)-vec3(0.82,2.83,0.82),0.0))-0.33)/z.w);//buildings

	//unrolled loop
	z.xz=clamp(z.xz, -1.0, 1.0) *2.0-z.xz;
	z*=2.0/clamp(dot(z.xyz,z.xyz),0.75,1.37);
	z.yz+=c;
	dS=min(dS,(length(max(abs(z.xyz)-vec3(0.82,2.83,0.82),0.0))-0.33)/z.w);//buildings
		
	float dR=max(dB,z0.y+0.2+th);//road
	dS=max(dS,-dB);//city with tunnel removed
	float dG=dS+0.037;//interior is glass
	z.xyz=abs(mod(z.xyz,0.4)-0.2);
	dS=max(dS,-max(z.y-0.16,min(z.x,z.z)-0.15)/z.w);//cut out windows
	return min(min(dS,dG),min(dC,dR));
}

vec4 mcol;
float CE(vec3 z0){//for coloring
	float dC=DEC(z0);
	vec2 c=z0.xz*0.1;
	float th=(sin(c.x+cos(c.y))+sin(c.y+cos(c.x)))-0.1;
	z0.xz=rep(z0.xz,vec2(4.25));
	vec4 z=vec4(z0,1.0);
	c=vec2(1.0,0.66);
	float b=length(max(abs(z.xz)-vec2(0.5),0.0))-3.6;
	float dS=z0.y+2.0,dB=length(vec2(b,z.y+th))-0.36;//ground,tunnel
	float a=atan(z.z,z.x);
	z.xz=clamp(z.xz, -1.0, 1.0) *2.0-z.xz;
	z*=2.0/clamp(dot(z.xyz,z.xyz),0.75,1.37);
	z.yz+=c;
	dS=min(dS,(length(max(abs(z.xyz)-vec3(0.82,2.83,0.82),0.0))-0.33)/z.w);//buildings

	//unrolled loop
	z.xz=clamp(z.xz, -1.0, 1.0) *2.0-z.xz;
	z*=2.0/clamp(dot(z.xyz,z.xyz),0.75,1.37);
	z.yz+=c;
	dS=min(dS,(length(max(abs(z.xyz)-vec3(0.82,2.83,0.82),0.0))-0.33)/z.w);//buildings
		
	c.x=abs(fract(z.x*z.y*2.0)*0.2-0.1);
	float dR=max(dB,z0.y+0.2+th);//road
	dS=max(dS,-dB);//city with tunnel removed
	float dG=dS+0.037;//interior is glass
	vec4 c2=floor(z*2.5);
	z.xyz=abs(mod(z.xyz,0.4)-0.2);
	dS=max(dS,-max(z.y-0.16,min(z.x,z.z)-0.15)/z.w);//cut out windows
	
	if(dS<dR && dS<dG && dS<dC){
		z*=200.0;
		dS+=sin(z.x+2.4*sin(z.y+2.4*sin(z.z)))*0.00005;
		mcol=vec4(c.x*vec3(1.0,0.9,0.7),1.0);
	}else if(dR<dG && dR<dC){
		float d=0.04+smoothstep(0.01,0.0,max(abs(b)-0.0025,abs(fract(a*10.0)-0.5)*0.1-0.01));
		mcol=vec4(d,d,mcol.x*0.1,32.0);//rand(z0.xz)
		mcol*=clamp(dC*20.0,0.0,1.0);
	}else if(dG<dC){
		float spec=step(-0.8,sin((1.0+iGlobalTime*0.01)*(4.0*c2.x-c2.y+3.0*c2.z)))-0.5;
		z.xyz=vec3(0.2)*fract((c2.x+c2.z-c2.y)*0.32454213)*step(0.0,z0.y+1.9);
		mcol=vec4(z.xyz,spec);		
	}else{
		mcol=vec4(0.0);
	}
	return min(min(dS,dG),min(dR,dC));
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd ){//huh, you'll probably be inside the buildings
	float rnd=fract(sin(dot(fragCoord,vec2(13.14,63.242)))*2342.123); //try an abs of the DE if you are
	/*float t=rnd*DE(ro),d,px=1.0/iResolution.x;
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(d<px*t || t>20.0)break;
	}*/
	float t=rnd*DE(ro),px=1.0/iResolution.x;
	float d,pd=10.0,os=0.0,step;	
	for(int i=0;i<64;i++){
		d=DE(ro+rd*t);
#define AUTO_OVERSTEP
#ifdef AUTO_OVERSTEP
		if(d>=os){		//we have NOT stepped over anything
			os=0.47*d*d/pd;//calc overstep based on ratio of this step to last
			step=d+os;	//add in the overstep
			pd=d;	//save this step length for next calc
		}else{
			step=-os;d=1.0;pd=10.0;os=0.0;//remove ALL of overstep
		}
#else
		step=d;
#endif
		t+=step;
		if(t>20.0 || d<px*t)break;
	}
	vec3 fog=vec3(1.0-abs(rd.y))*(0.9+0.1*rnd);
	vec3 col=fog;
	if(t<20.0){
		mcol=vec4(rnd,0.0,0.0,0.0);
		float nd=CE(ro+rd*t);
		float vis=clamp(1.0-nd/d,0.0,1.0);
		float spec=0.07*clamp((1.0-vis)*t*0.4,0.0,1.0);
		mcol.rgb/=(1.0+nd*nd*100000.0);
		if(mcol.a<0.0)mcol.rgb*=10.0*vec3(0.5+0.5*vis,0.9,1.0-0.5*vis);
		mcol.rgb*=4.0/(t*t)*max(vis,0.5);
		mcol.rgb=mix(mcol.rgb,fog,spec);
		col=mix(mcol.rgb,fog,clamp(sqrt(t)/4.4,0.0,1.0));
	}
	fragColor=vec4(col,1.0);
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}
//from Walkable Character WADS keys by MMGS https://www.shadertoy.com/view/MsKGR3 (but changed direction of rot y)
mat3 rotate_x(float a){float sa = sin(a); float ca = cos(a); return mat3(1.,.0,.0,    .0,ca,sa,   .0,-sa,ca);}
mat3 rotate_y(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,.0,-sa,    .0,1.,.0,   sa,.0,ca);}
mat3 rotate_z(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,sa,.0,    -sa,ca,.0,  .0,.0,1.);}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec3 ro=load(0).xyz;
	vec3 fw=normalize(load(2).xyz);
    vec2 uv=fragCoord/iResolution.xy;
    float b=length(uv-iMouse.xy/iResolution.xy);
    if(b<0.25){
        fw=-fw;
        uv-=(iMouse.x==0.0?vec2(0.125):iMouse.xy/iResolution.xy);
        uv/=0.25;
        uv.x=-uv.x;
    }else{
        uv=uv-0.5;
    }
    uv.y*=iResolution.y/iResolution.x;
	vec3 rd=lookat(fw)*normalize(vec3(uv,1.0));
    
	CO=load(3).xyz;
	vec3 rt=-load(5).xyz;
   	MX=(rotate_z(rt.z)*rotate_x(rt.x))*rotate_y(rt.y);
	mainVR(fragColor, fragCoord, ro, rd);
    fragColor.rgb=mix(vec3(1.0,0.5,0.2),fragColor.rgb,clamp(abs(b-0.25)*60.0,0.0,1.0));
}