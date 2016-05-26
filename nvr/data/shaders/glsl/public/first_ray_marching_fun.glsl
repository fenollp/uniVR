// Shader downloaded from https://www.shadertoy.com/view/llBGW1
// written by shadertoy user archee
//
// Name: First ray-marching fun
// Description: I never made any demo scene release, that uses ray-marching. (preferred immediate ray casting)
//    Let's make up the fun that I had missed out.
//#define AUTOCAM

vec3 campos;
vec3 dir;
float time;

// rotate camera
#define pee (acos(0.0)*2.0)

float anglex,angley; // camera


vec3 rotatex(vec3 v,float anglex)
{
	float t;
	t =   v.y*cos(anglex) - v.z*sin(anglex);
	v.z = v.z*cos(anglex) + v.y*sin(anglex);
	v.y = t;
	return v;
}

vec3 rotcam(vec3 v)
{
	float t;
	v = rotatex(v,anglex);
	
	t = v.x * cos(angley) - v.z*sin(angley);
	v.z = v.z*cos(angley) + v.x*sin(angley);
	v.x = t;
	return v;
}


vec3 pos;
float mat;

float blob()
{
    vec3 p = pos;
    float f=0.0;
    f += 1.0/dot(p,p);
    p -= vec3(2.0+sin(time)*2.0,0.0,0.0);
    f += 1.0/dot(p,p);
    p = pos;
    p -= vec3(2.0,2.0+cos(time*1.2)*2.0,0.0);
    f += 1.0/dot(p,p);
    return sqrt(1.0/f)-1.0;
}

float maxfade(float a,float b)
{
    return max( (a+b)*0.5, max(a,b-0.2));
}

float asteroid()
{
    vec3 p = pos;
    float d=0.0;
    
    float rad = 1.0;
    
    p = rotatex(p,time);
    
    rad += clamp(sin(p.x*8.0)*2.0,-1.0,1.0)*0.05;
    rad += clamp(sin(p.y*8.0)*2.0,-1.0,1.0)*0.05;
    rad += clamp(sin(p.z*8.0)*2.0,-1.0,1.0)*0.05;
    d = (length(p)-rad)*0.5;
    
    
    return d;
}


float cube()
{
    float d;
    vec3 p = rotatex(pos,time); // cube
    vec3 p2 = p;
//    p=  (fract(p/8.0+0.5)-0.5)*8.0;
//    p.y = pos.y;
    p = abs(p);
    p = max(p-vec3(1.0),vec3(0.0));
    d =  length(p)-0.2;
    d = maxfade( d,   0.8+sin(time*3.0)*0.0-length(p2.xy) );
    d = max( d,   0.7-length(p2.xz) );
    d = max( d,   0.7-length(p2.yz) );
    return d;
}

float toroid()
{
    float d=0.0;
    vec3 p = pos;
//    p=  (fract(p/8.0+0.5)-0.5)*8.0;
    
    vec2 tp;
    tp = vec2(p.y/2.0,(dot(p.xz,p.xz))-1.0);
//    return (length(tp)-0.4)/1.0;
    d += 1.0/(length(tp));
    
    
    p.x += sin(time)*2.0+1.0;
    p.y += cos(time*1.2)*1.0+0.5;
    tp = vec2(p.z,length(p.xy)-1.0);
    d += 1.0/(length(tp));
    return (1.0/d-0.3)*0.5;
}

float dist2(float scene)
{
    scene = mod(scene,4.0);
    if (scene==0.0) return cube();
    if (scene==1.0) return toroid();
    if (scene==2.0) return asteroid();
//    if (scene==3.0) 
        return blob();
}

float dist()
{
/*    float d = mix(asteroid(),cube(),sin(time)*0.5+0.5);
//    d = cube();
    d = toroid();*/
    
    float tscene = (time/8.0);
    float iscene = floor(tscene);
    float d = mix( dist2(iscene), dist2(iscene+1.0), max(fract(tscene)*3.0-2.0,0.0));
    
    d = min(d,pos.y+3.0);
    return d;
}


float dist2(vec3 p)
{
    pos = p;
    return dist();
}

vec3 calcnormal(vec3 pos)
{
    float dd = 0.001;
    float mv = dist2(pos);
    return normalize(vec3( dist2(pos+vec3(dd,0.0,0.0))-mv, dist2(pos+vec3(0.0,dd,0.0))-mv, dist2(pos+vec3(0.0,0.0,dd))-mv));
}

vec3  trace_normal()
{
    float st = 0.5;
    pos = campos;
    mat = 0.0;
    
    float lastst=0.0;
    for(int p=0;p<250;p++)
    {
    	st = dist();
        if (st<0.002) 
        {
            return calcnormal(pos);
        }
        if (length(pos)>20.0) return vec3(0.0);
    	pos += dir*st;
        lastst = st;
    }
    return vec3(0.0);
}

float trace_shadow()
{
    float lastst=0.0;
    float st = 0.02;
    pos += dir*st;
    float travel = st/99.0;
    float shadow = 1.0;
    for(int p=0;p<250;p++)
    {
    	st = dist();
        shadow = min(shadow,st/travel*90.0);
        if (st<0.002) 
        {
            return 0.0;
        }
        if (length(pos)>20.0) return shadow;
    	pos += dir*st;
        travel += st;
        lastst = st;
    }
    return shadow;
    
}

vec3 sundir = normalize(vec3(0.7,1.0,0.2));

vec3 backGround(vec3 dir)
{
    return mix(vec3(0.3,0.2,0.1),vec3(0.6,0.8,1.0)*0.5,clamp(dir.y*10.0,0.0,1.0));
}

vec3 trace()
{
    vec3 norm = trace_normal();
    vec3 ambientLight = vec3(0.6,0.8,1.0);
    vec3 sunLight = vec3(1.0,0.8,0.6);

    if (length(norm)==0.0)
    {
        return backGround(dir);
    }
    
    vec3 refdir = reflect(dir,norm);
    float f = 1.0-max(-dot(dir,norm),0.0);
    float fresnel = 0.1+0.9*f*f*f*f*f;
    
    float spec = pow(max(dot(sundir,refdir),0.0),8.0)*4.0;
    
    dir = sundir;
	float shadow = trace_shadow();                    
    
   
    
    return (mix(ambientLight * (norm.y*0.5+0.5) + shadow*(sunLight*max(dot(norm,dir),0.0)),backGround(refdir)+shadow * vec3(spec),fresnel  ))*0.7;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // set camera
    if (iMouse.x!=0.0)
    {
    anglex = ( iMouse.y/iResolution.y*-0.6+0.3)*pee*1.2; // mouse cam
    angley = -iMouse.x/iResolution.x*pee*2.0;
    }
    else
    {
    anglex = sin(iGlobalTime*0.3)*-0.6+0.6;
    angley = pee + sin(iGlobalTime*0.2);
    }

    
    time = iGlobalTime+2.0;
	vec2 uv = fragCoord.xy / iResolution.xy;
	campos = vec3(0,0,0);
	dir = vec3(uv*2.0-1.0,1);
	dir.y *= 9.0/16.0; // wide screen
	
	dir = normalize(rotcam(dir));
	campos -= rotcam(vec3(0,0,4.0 + 0.0*exp(iGlobalTime*-0.8))); // back up from subject
    
 
    fragColor = vec4(trace(),0.0);
    
    
//    fragColor = vec4(dot(pos-campos,dir)*vec3(0.1,0.01,0.001),0);
}