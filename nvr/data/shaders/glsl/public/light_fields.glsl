// Shader downloaded from https://www.shadertoy.com/view/lt2GRV
// written by shadertoy user mu6k
//
// Name: Light Fields
// Description: Took my terrain from rocket science and added some glowing spheres.
/* by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. */
/* synced to this: https://www.youtube.com/watch?v=0NKUpo_xKyQ */

//#define motion_blur

#ifdef motion_blur
float time = iGlobalTime + texture2D(iChannel0,gl_FragCoord.xy/256.0).x/24.0;
#else
float time = iGlobalTime;  //i hate the name in the uniforms
#endif

void angularRepeat(const float a, inout vec2 v)
{
    float an = atan(v.y,v.x);
    float len = length(v);
    an = mod(an+a*.5,a)-a*.5;
    v = vec2(cos(an),sin(an))*len;
}


void angularRepeat(const float a, const float offset, inout vec2 v)
{
    float an = atan(v.y,v.x);
    float len = length(v);
    an = mod(an+a*.5,a)-a*.5;
    an+=offset;
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


vec2 frot(const float a, in vec2 v)
{
    float cs = cos(a), ss = sin(a);
    vec2 u = v;
    v.x = u.x*cs + u.y*ss;
    v.y = u.x*-ss+ u.y*cs;
    return v;
}

void rotate(const float a, inout vec2 v)
{
    float cs = cos(a), ss = sin(a);
    vec2 u = v;
    v.x = u.x*cs + u.y*ss;
    v.y = u.x*-ss+ u.y*cs;
}

float dfTerraHills(vec3 p)
{
    p.y-=1.0;
    vec3 pm = p;
    pm.xz = mod(pm.xz+vec2(8.0),16.0)-vec2(8.0);
    pm = abs(pm);
    return (p.y*.8+3.0+pm.x*.1+pm.z*.1);
}

float dfTerra(vec3 p)
{
    p.y+=.1;
    vec3 p2 = p;
    float height = (sin(p.x*.1)+sin(p.z*.1))*1.5;
    rotate(.6,p2.xz);
    return max(dfTerraHills(p2),dfTerraHills(p))+height;
}


float dfBalls(vec3 p)
{
    vec2 pm = mod(p.xz+5.0,10.0)-5.0;
    vec2 id = p.xz-pm;
    float h = dfTerra(vec3(id.x,.0,id.y));
    h+=sin(id.x*7.1+id.y*17.841+time*sin(id.x*9.1+id.y))*.5;
    p.y+=h;
    
    return length(vec3(pm.x,p.y,pm.y))-.3;
}

float df(vec3 p)
{
    return min(dfTerra(p),dfBalls(p));
}

vec3 nf(vec3 p)
{
    vec2 e = vec2(0,0.005);
    return normalize(vec3(dfTerra(p+e.yxx),dfTerra(p+e.xyx),dfTerra(p+e.xxy)));
}

vec3 cf(vec2 p)
{
    return texture2D(iChannel0,p*.00005).xyz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ctime = time*.125+32.0;
    float stime = ctime - mod(ctime,1.0);
    float cs0 = sin(stime*141.123);
    float cs1 = sin(stime*51.124);
    cs0 = cs0*cs0*cs0*cs0*cs0*4.0;
    cs1 = cs1*cs1;
	vec2 uv = (fragCoord.xy-iResolution.xy*.5) / iResolution.yy;
    vec2 mouse = (iMouse.xy-iResolution.xy*.5) / iResolution.yy;
    if (iMouse.w>.2) mouse*=.0;;
    
    vec3 pos = vec3(.1,.1,-5);
    //vec3 dir = normalize(vec3(uv,1.0));
    vec3 dir = normalize(vec3(uv,1.0));
    
    pos.z += time*8.0*cs1+stime*8.0;
    rotate(.3,pos.xz);
    rotate(-.1+sin(time*.071*cs0+stime*2.0)*.2,dir.yz);
    rotate(.3+sin(sin(time*.05*cs0+stime*2.0)*2.0+time*.1*cs0+stime*2.0),dir.xz);
    
    
    float dist,tdist = .0;
    vec3 fog = vec3(.0);
    
    for (int i=0; i<120; i++)
    {
        float db, df;
        dist = min(df = dfTerra(pos),db = dfBalls(pos));
     	//dist = df(pos);
        fog += vec3(0.01/(1.0+db*db))*dist*cf(pos.xz);
       	pos += dist*dir;
        tdist+=dist;
        if (dist<0.0001||dist>200.0)break;
    }
    
    vec3 light = normalize(vec3(1,2,3));
    
    
    vec3 skyColor = vec3(.1,.1,.1)*.7;
    
    vec3 ambientColor = skyColor*.07;
    vec3 materialColor = vec3(.5,.5,.5);
    vec3 emissiveColor = vec3(.0,.0,.0);
    vec3 reflection = vec3(.0);
    float diffuse = 1.0;
    
    if (dfBalls(pos)<dfTerra(pos))
    {
     	materialColor= vec3(.0);
        emissiveColor = cf(pos.xz)*2.0;
    }
    else
    {
        diffuse = 1.0/(1.0+dfBalls(pos));
        vec3 noi = texture2D(iChannel0,pos.xz).xyz;
        vec3 col = cf(pos.xz);
        materialColor = col*noi;
        vec3 rpos = pos;
        vec3 rdir = reflect(dir,nf(pos));
        rdir += (noi.xyz-vec3(.5))*9.0;
        rdir = normalize(rdir);
        float dist = .0;
        for (int i=0; i<10; i++)
        {
            dist = dfBalls(rpos);
            rpos += dist*rdir;
        }
        if (dist<.1)
            reflection = col*noi.x*.5;
    }
  
    
   
    float value = 
        df(pos+light)+
        df(pos+light*.5)*2.0+
        df(pos+light*.25)*4.0+
        df(pos+light*.125)*8.0+
        df(pos+light*.06125)*16.0;
    
    value=value*.2+.04;
    value=min(value,1.0);
    value=max(.0,value);
    
    vec3 normal = nf(pos);
   
    vec3 ref = reflect(dir,nf(pos));
    //float ro = min(max(min(min(df(pos+ref),df(pos+ref*0.25)*4.0), df(pos+ref*.5)*2.0)*.5,.0),1.0);
   	float ro=1.0;
    
    float ao = df(pos+normal*.125)*8.0 +
        df(pos+normal*.5)*2.0 +
    	df(pos+normal*.25)*4.0 +
    	df(pos+normal*.06125)*16.0;
    
    ao=ao*.125+.5;
    
    
    float fres = pow((dot(dir,nf(pos))*.5+.5),2.0);
    
    vec3 color = (value*vec3(dot(nf(pos),light)*.5+.5)*.5+ambientColor*ao)*materialColor*diffuse +reflection*fres;
    color += emissiveColor;
    //color = vec3(fres);
    vec3 cSky = skyColor*(1.0-dir.y);
    if (dist>0.5) color = cSky*.1;
    /*else color = mix(cSky,color,1.0/(1.0+tdist*.005));*/
   	
    color += fog;
    //color = fog;
    //color = reflection;
    
    color*=1.3; //boost
    ;
    color *= (1.0-pow(length(uv),2.0)*.9);
    color *= min(time*.1,1.0);
    color *= 1.5/(.5+mod(time,8.0)*.125);
    color = mix(color,vec3(length(color)),length(color)*.5-.1);
    
	fragColor = vec4(pow(color,vec3(1.0/2.2)),1.0)+texture2D(iChannel0,fragCoord.xy/256.0)/128.0;
    //fragColor = vec4(ro);
    //fragColor = vec4(ao);
    //fragColor = vec4(value);
}