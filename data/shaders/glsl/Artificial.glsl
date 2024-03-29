// Shader downloaded from https://www.shadertoy.com/view/4ljGW1
// written by shadertoy user mu6k
//
// Name: Artificial
// Description: Rotate with mouse. Started out as an experiment. Ended up as something awesome!

/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.*/

float time = iGlobalTime+99.0; //i hate the name in the uniforms

void angularRepeat(const float a, inout vec2 v)
{
    float an = atan(v.y,v.x);
    float len = length(v);
    an = mod(an+a*.5,a)-a*.5;
    v = vec2(cos(an),sin(an))*len;
}

float mBox(vec3 p, vec3 b)
{
	return max(max(abs(p.x)-b.x,abs(p.y)-b.y),abs(p.z)-b.z);
}

float mSphere(vec3 p, float r)
{
    return length(p)-r;
}

float rtime1 = time*.012;
float rtime2 = time*.027;
float rtime3 = time*.013;
mat3 rot = mat3(cos(rtime1),0,sin(rtime1),0,1,0,-sin(rtime1),0,cos(rtime1))*
    mat3(cos(rtime2),sin(rtime2),.0,-sin(rtime2),cos(rtime2),.0,0,0,1)*
    mat3(1,0,0,0,cos(rtime3),sin(rtime3),0,-sin(rtime3),cos(rtime3));

float df(vec3 p)
{
    float e=.4;
    for (int i=0;i<8; i++)
    {
        p = abs(p*rot)-e;
        p.y-=p.x*.1;
        p.x-=p.z*.1;
        e = e*.8+e*e*.1;
    }
    p = abs(p*rot)-e;
    p = abs(p*rot)-e;
  	return mBox(p,vec3(.05));
}

vec3 nf(vec3 p)
{
    vec2 e = vec2(0,0.005);
    return normalize(vec3(df(p+e.yxx),df(p+e.xyx),df(p+e.xxy)));
}

void rotate(const float a, inout vec2 v)
{
    float cs = cos(a), ss = sin(a);
    vec2 u = v;
    v.x = u.x*cs + u.y*ss;
    v.y = u.x*-ss+ u.y*cs;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-iResolution.xy*.5) / iResolution.yy;
    vec2 mouse = (iMouse.xy-iResolution.xy*.5) / iResolution.yy;
    
    vec3 pos = vec3(0,0,-5);
    vec3 dir = normalize(vec3(uv,1.0-length(uv)*.6));
    
    float rx = mouse.x*8.0 + time*.04 +.1;
    float ry = mouse.y*8.0 + time*.024+.4;
    
    rotate(rx,pos.xz);
    rotate(rx,dir.xz);    
    rotate(ry,pos.yx);
    rotate(ry,dir.yx);
    
    for (int i=0; i<40; i++)
    {
     	float dist = df(pos);
       	pos += dist*dir;
        if (dist<0.001||dist>10.0)break;
    }
    
    vec3 light = normalize(vec3(1,2,3));
    
    float value = 
        df(pos+light)+
        df(pos+light*.5)*2.0+
        df(pos+light*.25)*4.0+
        df(pos+light*.125)*8.0+
        df(pos+light*.6125)*16.0;
    
    value=value*.1+.04;
   
    vec3 ref = reflect(dir,nf(pos));
    float ro = min(max(min(min(df(pos+ref),df(pos+ref*0.25)*4.0), df(pos+ref*.5)*2.0)*.5,.0),1.0);
   
    vec3 tex = textureCube(iChannel0,ref).xyz;
    float fres = (dot(dir,nf(pos))*.5+.5)*9.0;
    
    vec3 color = value*vec3(dot(nf(pos),light)*.5+.5)*.5 + fres*tex*ro;
   
    color -= pow(length(uv),2.0)*.1;
    color = mix(color,vec3(length(color)),length(color)*.5);
    
	fragColor = vec4(pow(color,vec3(1.0/2.2)),1.0);
}
