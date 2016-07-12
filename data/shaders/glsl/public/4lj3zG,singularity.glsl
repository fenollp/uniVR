// Shader downloaded from https://www.shadertoy.com/view/4lj3zG
// written by shadertoy user mu6k
//
// Name: Singularity
// Description: The supermassive gravity is bending the light. I made them glow so that it's not boring. You can undefine glow if you want. Rotate with mouse.
/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.*/

#define glow

float time = iGlobalTime; //i hate the name in the uniforms

void angularRepeat(const float a, inout vec2 v)
{
    float an = atan(v.y,v.x);
    float len = length(v);
    an = mod(an+a*.5,a)-a*.5;
    v = vec2(cos(an),sin(an))*len;
}

 	
// iq's polynomial smooth min (k = 0.1);
// http://iquilezles.org/www/articles/smin/smin.htm
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float mBox(vec3 p, vec3 b)
{
	return max(max(abs(p.x)-b.x,abs(p.y)-b.y),abs(p.z)-b.z);
}

float mSphere(vec3 p, float r)
{
    return length(p)-r;
}

float rtime1 = time*.082;
float rtime2 = time*.027;
float rtime3 = time*.013;
mat3 rot = mat3(cos(rtime1),0,sin(rtime1),0,1,0,-sin(rtime1),0,cos(rtime1))*
    mat3(cos(rtime2),sin(rtime2),.0,-sin(rtime2),cos(rtime2),.0,0,0,1)*
    mat3(1,0,0,0,cos(rtime3),sin(rtime3),0,-sin(rtime3),cos(rtime3));


float size = time*0.1
    -1.0;

float df(vec3 p)
{
    float e = .5;
    for (int i=0; i<2; i++)
    {
        p *= rot;
        p.x = smin(p.x,-p.x,.5)+e*size;
        p.y = smin(p.y,-p.y,.5)+e*size;
        p.z = smin(p.z,-p.z,.5)+e*size;
        e = e*.5;
    }
    return length(p)-0.1;
}

vec3 nf(vec3 p)
{
    vec2 e = vec2(0,0.005);
    float c = df(p);
    return normalize(vec3(df(p+e.yxx)-c,df(p+e.xyx)-c,df(p+e.xxy)-c));
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
    
    vec3 pos = vec3(0,0,-7.0);
    vec3 dir = normalize(vec3(uv,.5));
    pos += dir*fract(fract((fragCoord.x*64.51230+fragCoord.y*42.123)*2.1512523)*351.2512313)*.5;
    
    float rx = mouse.x*8.0 + time*.04 +.1;
    float ry = mouse.y*8.0 + time*.024+.4;
    
    rotate(rx,pos.xz);
    rotate(rx,dir.xz);    
    rotate(ry,pos.yx);
    rotate(ry,dir.yx);
    
    float td = .0;
    
    for (int i=0; i<100; i++)
    {
     	float dist = df(pos);
        vec3 n = nf(pos);
       	pos += dist*dir*.5;
        dir = normalize(dir - n/(1.0+dist*dist)*.2);
        td += 1.0/(1.0+dist*dist);
        if (dist<0.001||dist>1000.0)break;
    }
    
    vec3 color;
    
    if (df(pos)>.1)
    {
        color = pow(textureCube(iChannel0,dir).xyz,vec3(2.2));
    }
    else
    {
    
        color = vec3(.0,.0,.0);
    }
    color /= 1.0+td;
    #ifdef glow
      color += vec3(td)*.2*vec3(.4,.1,.05);
    #endif
    color *= 1.0-length(uv)*.8;
   	color *= mix(vec3(.8,1.0,1.1),vec3(1.1,.9,.5), fragCoord.y/iResolution.y);
    
	fragColor = vec4(pow(color,vec3(1.0/2.2)),1.0);
}