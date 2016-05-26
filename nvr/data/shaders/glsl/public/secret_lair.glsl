// Shader downloaded from https://www.shadertoy.com/view/XtjXz3
// written by shadertoy user ryk
//
// Name: secret lair
// Description: You could say I'm a fan of light fixtures behind fans. Better not, though.
// Copyright 2015 Martin Rykfors
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
// If you redistribute this work, please credit me by providing a link to https://www.shadertoy.com/user/ryk
float time;
vec2 size;
#define PI 3.1415926535897
#define Y_WALL 1.5
#define Z_WALL 1.5

struct Ray
{
	vec3 org;
	vec3 dir;
};

Ray createRay(vec3 center, vec3 lookAt, vec3 up, vec2 uv, float fov, float aspect)
{
	Ray ray;
	ray.org = center;
	vec3 dir = normalize(lookAt - center);
	up = normalize(up - dir*dot(dir,up));
	vec3 right = cross(dir, up);
	uv = 2.*uv - vec2(1.);
	fov = fov * 3.1415/180.;
	ray.dir = dir + tan(fov/2.) * right * uv.x + tan(fov/2.) / aspect * up * uv.y;
	ray.dir = normalize(ray.dir);	
	return ray;
}

float fan(vec2 p, float blur){
    float y = p.y;
    float rs = dot(p,p);
    float arg = atan(p.y, p.x);
    float f = 1. - smoothstep(1.-blur, 1.+blur, rs);
    f *= smoothstep(0.02-blur/8., 0.02+blur/8., rs);
    float period = 2.*PI/8.;
    arg += time*2.;
    arg += period;
    arg = mod(arg, 2.*period);
    arg -= period;
    p = sqrt(rs) * vec2(cos(arg), sin(arg));
    p -= vec2(0.55, 0.);
    p *= vec2(1.9,6.5);
    f *= smoothstep(1.-blur*4., 1.+blur*4., dot(p,p));
    return f;
}

float intensity(vec3 pos,float bias){
    float inside = (pos.y > -Y_WALL ? 1.: 0.) * (pos.z > -Z_WALL ? 1.: 0.);
    pos.z -= 2.;
    pos.z += pos.y/1.;
    vec2 p = pos.xz;
    float b = (pos.y + Y_WALL)/1.3 + bias;

    return fan(p,b) * 0.03 * inside;
}

float renderFog(Ray ray){
    float acc = 0.;
    float dist = 0.;
    vec3 pos;
    for (int i = 0; i < 80; i++){
        pos = ray.org + ray.dir*dist;
        acc += intensity(pos, 1.0) * smoothstep(-Z_WALL, -Z_WALL+0.08, pos.z);
        dist+=0.12;
    }
    return acc;
}

vec3 render(Ray ray){
    float n = -dot(vec3(0.,1.,0.), ray.dir);
    float delta = ray.org.y + Y_WALL;
    float dist1 = delta/n;
    dist1 = dist1 < 0. ? 100000. : dist1;
    
    n = -dot(vec3(0.,0.,1.), ray.dir);
    delta = ray.org.z + Z_WALL;
    float dist2 = delta/n;
    dist2 = dist2 < 0. ? 100000. : dist2;
    vec3 col;
    if (dist1 < dist2){
        vec3 pos = ray.org + ray.dir*dist1;
        col = vec3(0.19,0.24,0.24)/(1.+sqrt(dist1/8.)) + intensity(pos+vec3(0.,0.0001,0.),0.02)*38.;
    }
    else{
        vec3 pos = ray.org + ray.dir*dist2;
        col = vec3(0.17,0.21,0.21)/(1.+sqrt(dist2/8.))+ intensity(pos+vec3(0.,0.,0.001),-0.9)*38.;
    }
    return col;
}

vec3 centerTrajectory(){
    float t = sin(time/8.);
    float at = atan(abs(t*4.));
    t = sign(t)*at;
    return vec3(0, t*2.8+0.0, -t*2.0 + 0.5);
}

vec3 cameraTrajectory(){
    vec2 c = vec2(cos(time/4.), sin(time/4.));
    c.y *= 2.5;
    c.y += 4.5;
    c.x *= 4.;
    c.x += 1.;
    return vec3(c,0.5);
}

vec4 mainRender(vec2 uv){
   
    vec2 p = uv*2. - 1.;
    vec3 camPos = cameraTrajectory();
    vec3 center = centerTrajectory();
    vec3 up = vec3(0.,0.,1.);
    Ray ray = createRay(camPos, center, up, uv, 90., size.x/size.y);

    float fog = renderFog(ray);
    vec3 fogCol = vec3(1.) * fog;

    vec3 sceneCol = render(ray) + fogCol;
    return vec4(sceneCol, 1.);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    size = iResolution.xy;
    time = iGlobalTime + 15.;
	fragColor = mainRender(uv);
}