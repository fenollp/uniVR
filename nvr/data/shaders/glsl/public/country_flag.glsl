// Shader downloaded from https://www.shadertoy.com/view/4tsXWn
// written by shadertoy user foxes
//
// Name: Country Flag
// Description: I just tried to make a flag of my country (Russia)

float pixSize=0.004;

float lerp(float a,float b,float s)
{
    return mix(a,b,s);
}

float mat(vec2 uw)
{
    vec2 uwa=fract(uw*90.0);
    //uwa=fract(uwa);
    //uwa.y=fract(uwa.y);
    //return max(0.4,min(1.0,abs(length(uwa-vec2(0.5,0.5))*4.0-1.5)));
    return uwa.x+uwa.y;//dot(uwa,uwa);
}

float matMip(vec2 uw)
{
    float x=pixSize;
    vec2 uw2=mod(uw,vec2(x,x));
    uw=uw-uw2;
    vec4 a=vec4(0.0);
    float z=pixSize*0.125;
    for (int i=0;i<8;i++)
        for (int j=0;j<8;j++) {
            vec2 uws=uw+vec2(i,j)*z;
			a+=vec4(mat(uws),mat(uws+vec2(8.0*z,0.0)),mat(uws+vec2(0.0,8.0*z)),mat(uws+vec2(8.0,8.0)*z));
        }
    //float s1=lerp(mat(uw),mat(uw+vec2(x,0.0)),uw2.x/x);
    //float s2=lerp(mat(uw+vec2(0.0,x)),mat(uw+vec2(x,x)),uw2.x/x);
    //return lerp(s1,s2,uw2.y/x);;
    uw2=uw2/x;
    vec2 s=mix(a.xz,a.yw,vec2(uw2.x));
	//float s1=mix(a.x,a.y,uw2.x);
    //float s2=mix(a.z,a.w,uw2.x);
    return mix(s.x,s.y,uw2.y)*0.125*0.125;
}

vec4 flag(vec2 uw,float zoom) {
    float a=mod((uw.x)*zoom,1.0);
    float b=mod((uw.y)*zoom,1.0);
    if (a<0.5) a=0.0;
    if (a>=0.5) a=0.9;
    if (b<0.5) a=0.9-a;
    return vec4(a,a,a,1.0)*matMip(uw);
}

vec4 flagRU(vec2 uw,float zoom) {
    float b=(uw.y)*zoom;
    float a=(uw.x)*zoom;
    if (b<0.0 || b>1.0 || a>3.0 || a<0.0) return vec4(0.0);
    vec4 color=vec4(0.0,0.0,1.0,1.0);
    b=mod(b,1.0);
    if (b<0.333) color=vec4(1.0,0.0,0.0,1.0);
    if (b>0.666) color=vec4(1.0,1.0,1.0,1.0);
    return color*matMip(uw);
}

vec4 flagGB(vec2 uw,float zoom) {
    float b=(uw.y)*zoom;
    float a=(uw.x)*zoom*0.8+0.1;
    if (a>3.0 || a<0.0) return vec4(0.0);
    if (b<0.0 || b>1.0) return vec4(0.0);
    b=mod(b,1.0);
    vec4 color=vec4(0.0,0.0,1.0,1.0);
    if (b>0.4 && b<0.6 || a>0.4 && a<0.6) color=vec4(1.0);
    if (b>0.45 && b<0.55 || a>0.45 && a<0.55) {
        color=vec4(1.0,0.3,0.3,1.0);
    	if (b-a>-0.05 && b-a<0.05) color=vec4(1.0,0.1,0.1,1.0);
    	if (a+b>0.95 && a+b<1.05) color=vec4(1.0,0.1,0.1,1.0);
    } else {
    	if (b-a>-0.05 && b-a<0.05) color=vec4(1.0,0.6,0.6,1.0);
    	if (a+b>0.95 && a+b<1.05) color=vec4(1.0,0.6,0.6,1.0);
    }
    return color*matMip(uw);
}

vec4 flagEN(vec2 uw,float zoom) {
    float b=(uw.y)*zoom;
    float a=(uw.x)*zoom*0.8+0.1;
    if (a>3.0 || a<0.0) return vec4(0.0);
    if (b<0.0 || b>1.0) return vec4(0.0);
    b=mod(b,1.0);
    vec4 color=vec4(0.0,0.0,1.0,1.0);
    if (b<0.5 || a>0.45) {
        color=vec4(1.0,1.0,1.0,1.0);
        if (mod(b*9.0,1.0)>0.5) color=vec4(1.0,0.0,0.0,0.0);
    }
    return color*matMip(uw);
}

float time = iGlobalTime*0.5;

float sin1(float a,float b)
{
    return sin(a)+cos(b*2.0)*0.5;
}

float sinDist(float x,float y,float step,float amp,float atime,out float ang)
{
    amp=max(amp,1.0);
    float amp1=(amp-1.0)/(50.0)+1.0;
    float amp2=(amp-1.0)/(50.0+step*5.0)+1.0;
    //float from=0.0;//sin((atime-2.5*abs(sin((atime)*3.14159265358979/step)))*3.14159265358979/step);
    float from=0.0;//sin((-atime)*3.14159265358979/step);
    //return (sin((x-atime)*3.14159265358979/step)-from)*(amp-1.0)*12.5493557084138+x*amp;
    atime=mod(atime,step*2.0);
    float sc=(amp2-1.0)*12.5493557084138;
    float stp=3.14159265358979/step;
    ang=cos((x-atime-2.5*(sin((x-atime)*stp)))*stp);
    return (sin1((x-atime-2.5*(sin1((x-atime)*stp,y)))*stp,y))*sc+x*amp1;
    //return (sin((x-atime)*3.14159265358979/step))*sc+x*amp;
}

// (x,y) rot, amp, size
vec2 sinDr(vec2 val,float vecWind,float wind,float amp,float time,vec2 pos,in vec3 n,out vec3 normal)
{
    float vecWinda=vecWind*3.14159265358979;
    vec2 p=val-pos;
    vec2 s=p;
    //s=vec2(s.x*cos(vecWind)+s.y*sin(vecWind),-s.x*sin(vecWind)+s.y*cos(vecWind));
    vec2 m=vec2(cos(vecWinda),sin(vecWinda));
    vec3 nn=vec3(n.x*m.x+n.y*m.y,-n.x*m.y+n.y*m.x,n.z);
    
    float ang=0.0;
    float angb;
    float ls=length(s);
    float l=sinDist(ls,s.y,amp,1.0+wind,time,angb);
    s=s/ls*l;
    ang+=angb;
    ls=length(s);
    l=sinDist(ls,s.y,amp*0.7,1.0+wind*0.15,time,angb);
    s=normalize(s)*l;
    ang+=angb*0.8;
    //l=sinDist(length(s),s.y,amp*4.0,1.0+wind*0.25,time,angb);
    //s=normalize(s)*l;
    //ang+=angb/(amp*4.0);
    ang=ang*0.2;
    m=vec2(cos(ang),sin(ang));
    nn=vec3(nn.x*m.x+nn.z*m.y,nn.y,-nn.x*m.y+nn.z*m.x);
    
    //s=vec2(s.x*cos(-vecWind)+s.y*sin(-vecWind),-s.x*sin(-vecWind)+s.y*cos(-vecWind));
    m=vec2(cos(-vecWinda),sin(-vecWinda));
    normal=vec3(nn.x*m.x+nn.y*m.y,-nn.x*m.y+nn.y*m.x,nn.z);
    
    s=mix(p,s,vec2(abs(p.x),abs(p.y)*abs(p.x)));
    //s.y=lerp(p.y,s.y,abs(p.y)*abs(p.x));
    s+=pos;
    return s;
    //return val;
}

vec4 render(vec2 uv)
{   
    vec3 normal=vec3(0.0,0.0,1.0);
    vec2 s=uv;//*0.7;
    vec3 normala;
    s=sinDr(s,0.5,1.06,100.0,time*5.2,vec2(-4.0,-2.0),normal,normala);
    normal=normala;
    //s=sinDr(s,0.5,0.36,100.0,time*5.2,vec2(-4.0,2.0),normal,normal);
    //s=sinDr(s,0.5,0.26,100.0,time*5.2,vec2(-4.0,0.0),normal,normal);
    
    s=sinDr(s,0.03,0.02,2.0,time*1.0,vec2(-4.0,2.4),normal,normala);
    normal=normala;
    s=sinDr(s,-0.02,0.02,2.0,time*4.0,vec2(-4.0,0.0),normal,normala);
    normal=normala;
    s=sinDr(s,-0.02,0.02,2.0,time*2.0,vec2(-4.0,-2.4),normal,normala);
    normal=normala;
    s=sinDr(s,-0.04,0.02,4.0,time*3.1,vec2(-4.0,-3.0),normal,normala);
    normal=normala;
    
    //s=sinDr(s,-0.4,2.0,100.0,time*10.0,vec2(-4.0,1.0),normal,normal);

    //s=s/0.7;
    //if (normal.z!=0.0)
    	pixSize=pixSize/(pow(normal.z,7.2));
    vec4 color=flagRU(s+vec2(2.0,2.0),0.2)*0.85;
    float shadow=abs(dot(normal,vec3(0.0,0.0,1.0)));
    float lig=max(0.0,min(1.0,pow(shadow,15.0)));
    
    return min(color*shadow+vec4(0.1,0.1,0.1,1.0)*lig,vec4(1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    float a=1.0/iResolution.y;
    uv.x *= iResolution.x * a;
    //float a=0.01/iResolution.y;
    
    pixSize=a*4.0;
    
    vec4 d=vec4(0.0);
    for (float i=2.0;i<5.0;i++) {
		d+=render(uv)/i;
    	time=time-0.008;
    }
    
	fragColor = min(d*0.8,vec4(1.0));
}
