// Shader downloaded from https://www.shadertoy.com/view/lllSzS
// written by shadertoy user KK
//
// Name: All States of Water
// Description: Shader made for Warsztat.GD compo.


float n(vec2 pos)
{
    vec2 ip = floor(pos);
    vec2 d = pos - ip;
    // 6x5 - 15x4 + 10x3
    d *= d*d*(10.0+d*(6.0*d-15.0));
    pos = ip + d;
    pos += 0.5;
    pos /= iChannelResolution[0].xy;
    return texture2D(iChannel0,pos.xy).x*2.0-1.0;
}

float n3(vec3 pos)
{
    float ip = floor(pos.z);
    float  d = pos.z - ip;
    d *= d*d*(10.0+d*(6.0*d-15.0));
    pos.xy += 100.0*ip;
    return mix(n(pos.xy),n(pos.xy+100.0),d);
}

float nt(vec2 pos,float t)	{ return n3(vec3(pos,t)); }

vec2 cosin(float t)
{
    return vec2(cos(t),sin(t));
}

float water(vec3 pos)
{
    float t = iGlobalTime*2.0;
    float d = pos.z;
    pos.xy *= 0.8;
    d -= n(pos.xy/0.2 + t*4.0*vec2(-1.8,0.1))/40.0;
    d -= n(pos.xy/0.7 + t*3.0*vec2(0.1,0.4) + cosin(t*1.1))/12.0;
    d -= n(pos.xy/1.0 - t*2.5 + cosin(t/4.1))/8.0;
    d -= n(pos.xy/2.1 + t/2.0 + cosin(t/2.0))/4.0;
    d -= n(pos.xy/4.0 +t*vec2(-1,0.5)/2.0)/2.0;
    d -= n(pos.xy/16.0 +t*vec2(1,-0.5)/2.0)/1.0;
    return d;
}

float fracno(vec2 pos)
{
    float v = 0.0;
    v += abs(n(pos.xy/1.0))*1.0;
    v += abs(n(pos.xy/2.0))*2.0;
    v += abs(n(pos.xy/4.0))*4.0;
    return v;
}

float ice(vec3 pos)
{
    vec2 pp = normalize(pos.xy);
    float r = n(pp*4.0)*0.3 + n(pp*410.0)*0.05;
    float d = length(pos.xy) - 10.0 - r;
    float h = pos.z-2.5;
    float l = length(pos.xy);
    h += sin(iGlobalTime*2.0)*0.4;
    h -= n(pos.xy/0.02)/50.0;
    //h -= n(pos.xy/0.07)/20.0;
    h += fracno(pos.xy/2.0)*l*l*0.007;
    d = max(d,h);
    return d;
}

vec4 Fn(vec3 pos)
{
    float d = water(pos);//pos.z + n(pos.xy)*0.5;
    float di = ice(pos);
    if(di<d) return vec4(0.0,1.0,0.0,di);

    return vec4(1.0,0.0,0.0,d);
}

vec3 nm(vec3 pos)
{
    vec3 normal;
    vec2 e = vec2(0.05+length(pos)*0.0005,0.0);
    normal.x = Fn(pos+e.xyy).w - Fn(pos-e.xyy).w;
    normal.y = Fn(pos+e.yxy).w - Fn(pos-e.yxy).w;
    normal.z = Fn(pos+e.yyx).w - Fn(pos-e.yyx).w;
    return normalize(normal);
}

void trace(vec3 tpos,vec3 tdir,out vec3 _pos,out vec4 mt)
{
	float g = 0.0;
    mt = vec4(0,0,0,0);

	for(int i=0;i<150;i++)
	{
		if(g>1000.0) break;
		mt = Fn(tpos);
		if(mt.w<0.002) break;
		tpos += mt.w*tdir;
		g += mt.w;
	}
    _pos = tpos;
}

float cloud(vec2 p)
{
    p *= 1.5;
    float t = iGlobalTime*0.3;
    float c = 0.0;
    c += n(p/4.0 + t*vec2(-0.3,1))*4.0;
    p += t*vec2(0.3,1)*4.0;
    c += n(p/2.0)*2.0;
    c += n(p*1.0)/1.0;
    c += n(p*2.0)/2.0;
    c += n(p*4.0)/4.0;
    c += n(p*8.0)/8.0;
    return max(c*0.5,0.0);
}

vec3 sky(vec3 dir)
{
    dir = normalize(dir);
    dir.z = abs(dir.z);
	vec3 c0 = mix(vec3(0.3,0.5,0.9),vec3(0.05,0.1,0.4),sqrt(dir.z*1.5));
    
    vec2 cpos = dir.xy/dir.z;
    float cl = cloud(cpos);
    float cl1 = cloud(cpos-0.1*vec2(-1,-1));
    cl1 = clamp(cl1,0.0,1.0);
    float lit = 1.0 - cl1;
    float shade = 0.5/(0.5+cl*0.5);
    vec3 ccol = mix(vec3(0.2,0.22,0.3)*shade,vec3(0.4,0.3,0.3),lit);
    
    c0 = mix(c0,ccol,clamp(cl,0.0,1.0));
    
    return c0;
}

vec4 getcolor(vec3 pos,vec3 dir,vec4 d)
{
	if(length(pos)>900.0)
        return vec4(sky(dir),0.0);

    vec3 ld = normalize(vec3(4,-2,4));
    vec3 normal = nm(pos);
    vec4 c = vec4(clamp(dot(normal,ld),0.0,1.0));
    if(d.y>0.5) return c*vec4(1.2,1.2,1.3,0.0);
    return c*vec4(0.02,0.04,0.05,0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vpos = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
	vpos.x *= iResolution.x/iResolution.y;
	vpos *= .8;
	
    
	vec2 mpos = iMouse.xy / iResolution.xy*2. - 1.;
	vec3 front = normalize(vec3(-1.,-mpos.x,mpos.y-.5));
    
    
	//front = normalize(vec3(-1,-0.7,0));
    front.xy = cosin(iGlobalTime*0.2);
    front.z = -(sin(iGlobalTime*0.3)*.5+.5)*0.6;
    front = normalize(front);
	vec3 up = vec3(0,0,1);
	vec3 right = cross(up,front);
	//pos = vec3(1,-2,1.2)-front*4.0;
    vec3 pos = vec3(0,0,2.2)-front*24.0;

	vec3 vdir = normalize(front + vpos.x*right + vpos.y*up);
	vec3 tdir = normalize(vdir);
	vec3 tpos = pos;
	vec4 c = vec4(sky(tdir)*0.3,0.0);
	float m=0.0;
    vec4 d=vec4(0,0,0,0);
	vec3 lpos = vec3(10,10,0);

	//fragColor = pow(c,vec4(1.0/2.2));
    //return;
    
    trace(tpos,tdir,tpos,d);

	if(d.w<0.002)
	{
		c = getcolor(tpos,tdir,d);
        
        //if(d.x>0.5)
        {
		    vec3 normal = nm(tpos);
            vec3 tpos2 = tpos + normal*0.02;
            vec3 tdir2 = reflect(tdir,normal);
            vec4 d2;
            trace(tpos2,tdir2,tpos2,d2);
            
            float fres = pow(1.0 - clamp(dot(normal,-tdir),0.0,1.0),5.0);
            c += getcolor(tpos2,tdir2,d2)*mix(0.04,1.0,fres);
        }
	}
    
	if(length(tpos)>900.0)
	{
		c = vec4(sky(tdir),0.0);
	}

	
	fragColor = pow(c,vec4(1.0/2.2));
}
