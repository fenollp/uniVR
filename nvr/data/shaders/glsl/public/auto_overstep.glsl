// Shader downloaded from https://www.shadertoy.com/view/lsBSDK
// written by shadertoy user eiffie
//
// Name: Auto Overstep
// Description: I've been out of the loop so this has probably been done before (please point me to it!)
//    The paper &quot;Enhanced Sphere Tracing&quot; describes a simple overstep method that assures no surface is missed. This is the result of my experiments &quot;improving&quot; it. :)
// auto-overstep by eiffie
// playing with the overstep method described in the paper...
// http://erleuchtet.org/~cupe/permanent/enhanced_sphere_tracing.pdf
// by adding an automated overstep calculation similar to huwb's...
// https://www.shadertoy.com/view/Mdj3W3
// and bisecting the overstep error until no overstep is found

// in "real world" examples I was able to get a 10% increase in speed by adding
// 6 lines of code
// in this example I rarely see my "improvements" doing better than the method
// outlined in the paper

// comment the following two lines to see the original method
#define AUTO_OVERSTEP
#define BISECT_OVERSTEP_ERROR


#define size iResolution
#define time iGlobalTime
float Tube(vec2 pa, vec2 ba){return length(pa-ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0));}

float DE(vec2 pt){
	float d=100.0,f=0.0005,ft=floor(time*0.2)*1.3;
	vec2 p0=vec2(-1.65,-0.6),p1;
	for(int i=0;i<11;i++){
		p1=p0+vec2(0.3,f+sin(float(i)*1.3+ft)*0.3);
		d=min(d,Tube(pt-p0,p1-p0));
		p0=p1;f+=f;
	}
	return d;
}
float DE_Circle(vec2 pt, vec2 c, float r){
	return abs(distance(pt,c)-r);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 pt=(2.0*fragCoord.xy-size.xy)/size.y;
	
	vec3 clr=vec3(1.0);//white background
	clr=mix(vec3(0.0),clr,smoothstep(0.0,0.02,DE(pt)));//draw the surface
	float dR=100.0,dB=100.0,dG=100.0;
	vec2 ro=vec2(-1.5,0.0),rd=vec2(1.0,0.0);//this method works the same with vec3
	float t=0.0;	//total distance
	float d=0.0;	//estimated distance
	float pd=10.0;//previous estimate
	float os=0.0;	//overstep
	float sf=fract(time*0.2)*0.5;
	for(int i=0;i<10;i++){//march with overstepping
		d=DE(ro+rd*t);//get the distance estimat to surface
		if(d>os){	//we have NOT stepped over anything
			dB=min(dB,DE_Circle(pt,ro+rd*t,d));//for drawing only
			dG=min(dG,DE_Circle(pt,ro+rd*t,0.01));//for drawing only
#ifdef AUTO_OVERSTEP
			os=sf*d*d/pd;//calc overstep based on ratio of this step to last
			pd=d;	//save this step length for next calc
#else
			os=sf*d;//this is the normal overstep outlined in the paper
#endif
			t+=d+os;//add in the overstep		
		}else{		//we MAY have stepped over something
			dR=min(dR,DE_Circle(pt,ro+rd*t,d));//for drawing only
			dR=min(dR,Tube(pt-(ro+rd*t),-rd*os)-0.01);//for drawing only
#ifdef BISECT_OVERSTEP_ERROR
			os*=0.5;//bisect the overstep
			t-=os;	//and back up
#else
			t-=os;	//back up
			os=0.0;	//and remove overstep
#endif
		}
	}
	clr=mix(vec3(1.0,0.0,0.0),clr,smoothstep(0.0,0.01,dR));//draw overstepped in red
	clr=mix(vec3(0.0,1.0,0.0),clr,smoothstep(0.0,0.02,dG));//draw normal march steps in green
	clr=mix(vec3(0.0,0.0,1.0),clr,smoothstep(0.0,0.01,dB));//draw understepped in blue
	fragColor = vec4(clr,1.0);
}
