// Shader downloaded from https://www.shadertoy.com/view/4sy3zh
// written by shadertoy user eiffie
//
// Name: Last Incandescent
// Description: Playing with depth maps for volume light, shadow mapping and reduced size initial marching.
//Last Incandescent by eiffie
//buf A is used for a shadow map and also to jump start the ray march similar to
//... Dave Hoskins' https://www.shadertoy.com/view/4tfXDN

//I can't figure out why bufferA is returning garbage in win/chrome, linux/firefox
//but works with win/firefox?? (It was the discard!)

#define PI 3.14159
#define LIGHT_FALLOFF 1.0

float rand(vec3 co){// implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
	return fract(sin(dot(co*0.123,vec3(12.9898,78.233,112.166))) * 43758.5453);
}

vec3 Tile(vec3 p, float a){return abs(mod(p+a,a*4.0)-a*2.0)-a;}
const int iters=5,iter2=3;
float scale=3.48;vec3 offset=vec3(1.9,0.0,2.56);
float psni=pow(scale,-float(iters)),psni2=pow(scale,-float(iter2));
int obj;
float DE(in vec3 z){
	z=Tile(z,3.0);
	vec3 z2;
	for (int n = 0; n < iters; n++) {
		if(n==iter2)z2=z;
		z = abs(z);
		if (z.x<z.y)z.xy = z.yx;
		z.xz = z.zx;
		z = z*scale - offset*(scale-1.0);
		if(z.z<-0.5*offset.z*(scale-1.0))z.z+=offset.z*(scale-1.0);
	}
    float d1=(length(z.xy)-1.0)*psni;
    float d2=length(max(abs(z2)-vec3(0.2,5.1,1.3),0.0))*psni2;
    obj=(d1<d2)?0:1;
	return min(d1,d2);
}

mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

float sgn(float x){return (x<0.?-1.:1.);}

float isInShadow(vec3 p, vec3 posLight, float eps){
    vec3 L=(p-posLight);//light direction for shadow lookup
	float d=length(L);
	if(d<LIGHT_FALLOFF){//ignore if light is too far away
		L/=d;//normalize
		float phi=asin(L.y);//transform back to 2d
		vec2 pt=vec2(asin(L.z/cos(phi)),phi);
        if(L.x<0.0)pt.x=sgn(L.z)*PI-pt.x;
        pt/=vec2(PI*2.0,PI);
		pt+=0.5;//uncenter
		pt*=vec2(0.5,1.0);//left side of texture only
		if(d-2.0*eps*d<texture2D(iChannel0,pt).r*LIGHT_FALLOFF)return d;
	}
    return -1.0;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pt=uv*0.5+vec2(0.5,0.0);
	//fragColor = texture2D(iChannel0,uv);return;
    uv-=0.5;
    uv*=vec2(iResolution.x/iResolution.y,1.0);
    vec3 posLight=vec3(iGlobalTime,sin(iGlobalTime*0.4),1.25);
	vec3 ro=vec3(iGlobalTime-1.0+sin(iGlobalTime*0.24)*0.25,sin(iGlobalTime*0.3),0.88+0.5*sin(iGlobalTime*0.34));
	vec3 rd=normalize(vec3(uv,1.0));
	rd=lookat(posLight-vec3(0.0,sin(iGlobalTime*0.3)*0.4,sin(iGlobalTime*0.2)*0.3)-ro)*rd;
    
    float maxdepth=10.0,eps=1.0/iResolution.y,d,t=texture2D(iChannel0,pt).r*maxdepth;
    vec4 ts=vec4(0.0),ds=vec4(0.0);
    for(int i=0;i<48;i++){
        t+=d=DE(ro+rd*t);
        if(d<eps*t){ts=vec4(t,ts.xyz);ds=vec4(d,ds.xyz);}//push
        if(ts.w>0.0 || t>maxdepth)break;
    }
    t=clamp(t,0.0,maxdepth);
    vec3 col=vec3(clamp(0.5*t/maxdepth,0.0,1.0));
    for(int i=0;i<4;i++){
        if(ts.x<0.001)break;
    	vec3 scol=vec3(clamp(0.4999*ts.x/maxdepth,0.0,1.0));
   		vec3 p=ro+ts.x*rd;
    	float d2=isInShadow(ro+rd*ts.x,posLight,eps);
    	if(d2>=0.0){
			vec3 L=normalize(p-posLight);
        	float d3=DE(ro+rd*ts.x-L*ds.x);//test in the direction of the light
			scol+=clamp((d3-ds.x*0.75)/ds.x,0.0,1.0)*vec3(1.0,0.9,0.8)/(1.0+4.0*d2*d2);
            if(obj==1)scol+=vec3(0.0,0.12,0.1);
		}
        col=mix(scol,col,clamp(ds.x/(eps*ts.x),0.0,1.0));
        ts=ts.yzwx;ds=ds.yzwx;//pop
    }
	float dt=2.0*LIGHT_FALLOFF/32.0;
    maxdepth=t;
	t=max(0.0,length(ro-posLight)-LIGHT_FALLOFF)+dt*rand(rd);
	for(int i=0;i<32;i++){
        d=isInShadow(ro+rd*t,posLight,eps);
        if(d>=0.0){
			col+=vec3(1.0,0.9,0.6)/(1.0+300.0*d*d);
		}
		t+=dt;
        if(t>maxdepth)break;
    }
	clamp(col,0.0,1.0);
    
	fragColor=vec4(col,maxdepth);//maxdepth is actually scene depth
}