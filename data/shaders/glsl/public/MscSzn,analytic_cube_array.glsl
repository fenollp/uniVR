// Shader downloaded from https://www.shadertoy.com/view/MscSzn
// written by shadertoy user Bers
//
// Name: Analytic Cube Array
// Description: An exercise with analytic (no distance field) ray-cube intersections.
// Author : Sébastien Bérubé
// Created : Sept 2014
// Modified : Feb 2016
//
// An exercise with analytic (no distance field) ray-cube intersections.
// 
// License : Creative Commons Non-commercial (NC) license

const float MAX_DIST = 2000.0;
float CELL_SIZE = 8.0;
struct Cam
{
    vec3 R; //right
    vec3 U; //up
    vec3 D; //dir
    vec3 o; //origin
};
    
Cam lookAt(vec3 at, float fPitch, float dst, float rot)
{
	Cam cam;
    cam.D = vec3(cos(rot)*cos(fPitch),sin(fPitch),sin(rot)*cos(fPitch));
    cam.U = vec3(-sin(fPitch)*cos(rot),cos(fPitch),-sin(fPitch)*sin(rot));
    cam.R = cross(cam.D,cam.U);
    cam.o = at-cam.D*dst;
    return cam;
}

Cam mouseLookAt(vec3 at, float dst)
{
    vec2 speed = vec2(3.1416,4.0);
    vec2 mvt   = ((iMouse.xy/iResolution.xy)-0.5)*speed;
    return lookAt(at,mvt.y,dst,mvt.x);
}

float planeLineIntersect(vec3 o,vec3 d,vec3 pn,vec3 pp)
{
    return dot(pp-o,pn)/dot(d,pn);
}

vec3 ray(vec2 uv, Cam cam)
{
    uv -= 0.5;
    uv.y *= iResolution.y/iResolution.x;
    return normalize(uv.x*cam.R+uv.y*cam.U+cam.D);
}

float _sign(float x)
{
    return (x>0.)?1.:-1.;
}

vec3 rotate(vec3 p, const float yaw, const float pitch)
{
    p.xz = vec2( p.x*cos(yaw)+p.z*sin(yaw),
                 p.z*cos(yaw)-p.x*sin(yaw));
    p.yz = vec2( p.y*cos(pitch)+p.z*sin(pitch),
                 p.z*cos(pitch)-p.y*sin(pitch));
    return p;
}

struct hitInfo
{
	float dist;
    vec2 uv;
};

//ro = ray origin
//rd = ray direction
hitInfo rayCubeIntersec(vec3 ro, vec3 rd, vec3 size)
{
    float cullingDir = all(lessThan(abs(ro),size))?1.:-1.;
    vec3 viewSign = cullingDir*sign(rd);
    vec3 t = (viewSign*size-ro)/rd;
    vec2 uvx = (ro.zy+t.x*rd.zy)/size.zy; //face uv : [-1,1]
    vec2 uvy = (ro.xz+t.y*rd.xz)/size.xz;
    vec2 uvz = (ro.xy+t.z*rd.xy)/size.xy;
    if(      all(lessThan(abs(uvx),vec2(1))) && t.x > 0.) return hitInfo(t.x,(uvx+1.)/2.);
    else if( all(lessThan(abs(uvy),vec2(1))) && t.y > 0.) return hitInfo(t.y,(uvy+1.)/2.);
    else if( all(lessThan(abs(uvz),vec2(1))) && t.z > 0.) return hitInfo(t.z,(uvz+1.)/2.);
	return hitInfo(MAX_DIST,vec2(0));
}

hitInfo rayMarchArray(vec3 origin, vec3 dir)
{
    vec3 size = vec3(0.95,0.95,0.95);
    float t=1.0;
    hitInfo info;
    for(int i=0; i < 100; ++i)
    {
        //Cube position
        vec3 p = origin+t*dir;
        vec3 cubePos = floor(p/CELL_SIZE)*CELL_SIZE+0.5*CELL_SIZE;
        
        //rotation values
        float yaw = sin(iGlobalTime+cubePos.x+cubePos.y+cubePos.z);
        float pitch = iGlobalTime/1.0+sin(iGlobalTime+cubePos.x+cubePos.y+cubePos.z);
    	
        //rotated ray origin and direction
        vec3 rd = rotate(dir,yaw,pitch);
		vec3 ro = rotate(origin-cubePos,yaw,pitch);
        
        //ray-cube intersection function
        info = rayCubeIntersec(ro,rd,size);
        
        //check for hit : stop or continue.
        if(info.dist<MAX_DIST)
        	break;
        
        //Step into the next cell.
        t = t+CELL_SIZE; 
    }
    return info;
}

vec3 subMain(vec2 uv)
{
    Cam cam = mouseLookAt(vec3(2,2.0,-12.0),5.0);
    vec3 dir     = ray(uv,cam);
	vec3 origin  = vec3(1.5*sin(iGlobalTime/1.21),1.5*sin(iGlobalTime/1.00),6.4*iGlobalTime);
    
    hitInfo info = rayMarchArray(origin,dir);
    
    vec3 color = texture2D(iChannel0,info.uv,-2.0).xyz;
    return mix(color,vec3(1.0,1.0,1),info.dist/400.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = vec4(subMain(uv),1);
}