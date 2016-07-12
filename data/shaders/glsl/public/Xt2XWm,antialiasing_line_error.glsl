// Shader downloaded from https://www.shadertoy.com/view/Xt2XWm
// written by shadertoy user foxes
//
// Name: AntiAliasing Line Error
// Description: some fing crazy.
//    first i am write aaLine, and when i try experiment, i received this result when aaLine was a mistake - aaLineError
//    and i save it like shader on shadertoy.
vec3 preaaLine(vec2 a,vec2 b,vec2 uv)
{
	vec2 v2=(b-a)*0.5; 
	vec2 v1=uv-v2-a; 
    return vec3(dot(v1,v2),dot(v1,v1),dot(v2,v2));
 }

float aaLine(vec2 a,vec2 b,vec2 uv)
{
    vec3 al=preaaLine(a,b,uv);
    float g=al.y*al.z-al.x*al.x;
    float t=al.z*0.00001;
	if (al.z-al.y<=0.0) return 0.0;
    return max(0.0,1.0-g/t);
}

float aaLineError(vec2 a,vec2 b,vec2 uv)
{
	vec3 al=preaaLine(a,b,uv); 
    float g=al.y*al.z-al.x*al.x;
    float t=al.z*0.1;
	if (al.z-al.y<=0.0) return 0.0;
    return abs(1.0-g/t)*0.5;
}

float aaLineError2(vec2 a,vec2 b,vec2 uv)
{
    vec3 al=preaaLine(a,b,uv); 
    float g1=al.y*al.z-al.x*al.x;
    float g2=abs(al.z*al.x)-al.y*al.y;
    float t=al.z*0.1;
	if (g2<=0.0) return 0.0;
    return abs(1.0-g1/t)*0.3*min(1.0,g2*10000.0);
}

vec4 raysOfLight(vec2 center,vec2 uv,vec4 color,float time)
{
    float gt=floor(time);
    float lt=fract(time);
    float rat=iResolution.x/iResolution.y;
    float xsel=uv.x/rat;
	if (iMouse.z>0.0) xsel=iMouse.x/iResolution.x; 
    float l=0.0;
    center.x*=rat;
    
    vec2 ADD=vec2(425.255,125.23334);
    for (int i=0;i<20;i++) {
        float ii=float(i);
        float iia0=ii+gt-1.0;
        vec2 aiia0=(vec2(iia0)+vec2(2000.0,3000.0))*ADD;
        vec2 P20=sin(aiia0); aiia0+=ADD;
    	vec2 P21=sin(aiia0); aiia0+=ADD;
        vec2 P22=sin(aiia0); aiia0+=ADD;
        vec2 P23=sin(aiia0);
        
        // Catmull-Rom spline
		vec2 fcoef0= (P23- P20)*0.5 + (P21 - P22)*1.5;
		vec2 fcoef1= P20 -2.5*P21 + 2.0*P22 - 0.5*P23;
		vec2 P2 = ((fcoef0*lt+fcoef1)*lt+(P22-P20)*0.5)*lt+P21;
        
        float inn=max(0.0,1.5-length(P2));
        P2+=vec2(0.5);
        P2.x*=rat;
        inn=sqrt(inn);
        if (xsel<=0.25) l=aaLine(center,P2,uv);
        if (xsel>0.25 && xsel<=0.5) l=aaLineError(center,P2,uv);
        if (xsel>0.5 && xsel<=0.75) l=aaLineError2(center,P2,uv);
        if (xsel>0.75) l=aaLineError(center,P2,uv)-aaLineError2(center,P2,uv);
      	vec3 colorl=vec3(0.5)+0.5*sin(vec3(ii)*vec3(10.4,100.4,30.4)+vec3(0.0,2000.0,1000.0));
       	color=color+vec4(colorl*l*0.2*inn,0.0);
    }
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;

    fragColor = vec4(0.0);
    float gt=floor(iGlobalTime);
    float lt=fract(iGlobalTime);
    
    float t=iGlobalTime*0.5;
    vec2 P1=sin(vec2(t,t*0.6))*0.4+vec2(0.5);
    fragColor=raysOfLight(P1,uv,fragColor,t);
    P1=sin(vec2(t*0.6,t*1.7))*0.4+vec2(0.5);
    fragColor=raysOfLight(P1,uv,fragColor,t+0.5);

}