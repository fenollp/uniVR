// Shader downloaded from https://www.shadertoy.com/view/4dBXzw
// written by shadertoy user TDM
//
// Name: Holographic
// Description: Inspired by Johnny Lee VR work. 3D effect on flat surface.
// "Holographic" by Alexander Alekseev aka TDM - 2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//#define PIXELIZE
#define CAMERA_CHANGE

const int NUM_STEPS = 64;
const int AO_SAMPLES = 4;
const float AO_RADIUS = 1.3;
const float AO_DARKNESS = 3.5;
const float INV_AO_SAMPLES = 1.0 / float(AO_SAMPLES);
const float TRESHOLD 	= 0.001;
const float EPSILON 	= 1e-5;
const float PI 			= 3.1415;
const float HPI 		= PI * 0.5;
const float LIGHT_INTENSITY = 0.37;
const vec3 RED 		= vec3(1.0,0.7,0.7) * LIGHT_INTENSITY;
const vec3 ORANGE 	= vec3(1.0,0.67,0.43) * LIGHT_INTENSITY;
const vec3 BLUE 	= vec3(0.54,0.77,1.0) * LIGHT_INTENSITY;
const vec3 WHITE 	= vec3(1.0,0.99,0.98) * LIGHT_INTENSITY;
float WEIGHT 			= 2.0 / iResolution.x;

// holo
const vec2 HOLO_SIZE 	= vec2(0.79,0.49);
const float HOLO_ASPECT = HOLO_SIZE.x / HOLO_SIZE.y;
const int HOLO_LINES 	= 8;
const vec2 dxdy 		= HOLO_SIZE / float(HOLO_LINES/2);
const float HOLO_DEPTH 	= 5.0;
const float HOLO_DDEPTH = HOLO_DEPTH / float(HOLO_LINES-1);

#ifdef PIXELIZE
const vec2 HOLO_RESOLUTION = vec2(20.0,16.0);
#endif

// math
mat4 fromEuler(vec3 ang) {
	vec2 a1 = vec2(sin(ang.x),cos(ang.x));
    vec2 a2 = vec2(sin(ang.y),cos(ang.y));
    vec2 a3 = vec2(sin(ang.z),cos(ang.z));
    mat4 m;
    m[0] = vec4(a1.y*a3.y+a1.x*a2.x*a3.x,a1.y*a2.x*a3.x+a3.y*a1.x,-a2.y*a3.x,0.0);
	m[1] = vec4(-a2.y*a1.x,a1.y*a2.y,a2.x,0.0);
	m[2] = vec4(a3.y*a1.x*a2.x+a1.y*a3.x,a1.x*a3.x-a1.y*a3.y*a2.x,a2.y*a3.y,0.0);
	m[3] = vec4(0.0,0.0,0.0,1.0);
	return m;
}
mat4 getPosMatrix(vec3 p) {   
    mat4 ret;
    ret[0] = vec4(1.0,0.0,0.0,p.x);
    ret[1] = vec4(0.0,1.0,0.0,p.y);
    ret[2] = vec4(0.0,0.0,1.0,p.z);   
    ret[3] = vec4(0.0,0.0,0.0,1.0);
    return ret;
}
vec3 rotate(vec3 v, mat4 m) {
    return vec3(dot(v,m[0].xyz),dot(v,m[1].xyz),dot(v,m[2].xyz));
}
vec3 intersectPlane(vec3 o,vec3 d,vec4 p) {
    float t = (dot(p.xyz,o)-p.w) / dot(p.xyz,d);
    return o - d * t;    
}

// rasterize
float line(vec2 p, vec2 p0, vec2 p1) {
    vec2 d = p1 - p0;
    float t = clamp(dot(d,p-p0) / dot(d,d), 0.0,1.0);
    vec2 proj = p0 + d * t;
    float dist = length(p - proj);
    dist = 1.0/dist*WEIGHT;
    return min(dist*dist,1.0);
}

// lighting
float diffuse(vec3 n,vec3 l,float p) { return pow(dot(n,l) * 0.4 + 0.6,p); }
float specular(vec3 n,vec3 l,vec3 e,float s) {    
    float nrm = (s + 8.0) / (3.1415 * 8.0);
    return pow(max(dot(reflect(e,n),l),0.0),s) * nrm;
}

// distance functions
float plane(vec3 gp, vec4 p) {
	return dot(p.xyz,gp+p.xyz*p.w);
}
float sphere(vec3 p,float r) {
	return length(p)-r;
}
float capsule(vec3 p,float r,float h) {
    p.y -= clamp(p.y,-h,h);
	return length(p)-r;
}
float cylinder(vec3 p,float r,float h) {
	return max(abs(p.y/h),capsule(p,r,h));
}
float box(vec3 p,vec3 s) {
	p = abs(p)-s;
    return max(max(p.x,p.y),p.z);
}
float rbox(vec3 p,vec3 s) {
	p = abs(p)-s;
    return length(p-min(p,0.0));
}
float quad(vec3 p,vec2 s) {
	p = abs(p) - vec3(s.x,0.0,s.y);
    return max(max(p.x,p.y),p.z);
}

// boolean operations
float boolUnion(float a,float b) { return min(a,b); }
float boolIntersect(float a,float b) { return max(a,b); }

// world
float map(vec3 p) {
    float d = plane(p,vec4(0.0,1.0,0.0,1.0));
    d = boolUnion(d,plane(p,vec4(0.0,-1.0,0.0,4.0))); 
    d = boolUnion(d,plane(p,vec4(0.0,0.0,1.0,5.0)));
    d = boolUnion(d,plane(p,vec4(0.0,0.0,-1.0,5.0)));  
    d = boolUnion(d,plane(p,vec4(1.0,0.0,0.0,8.0)));
    d = boolUnion(d,plane(p,vec4(-1.0,0.0,0.0,8.0)));  
    
    d = boolUnion(d,rbox(vec3(0.75,-0.51,0.45)-p,vec3(0.1,0.5,0.1)));    
    d = boolUnion(d,rbox(vec3(0.75,-0.51,-0.45)-p,vec3(0.1,0.5,0.1)));
    d = boolUnion(d,rbox(vec3(-0.75,-0.51,0.45)-p,vec3(0.1,0.5,0.1)));    
    d = boolUnion(d,rbox(vec3(-0.75,-0.51,-0.45)-p,vec3(0.1,0.5,0.1)));
    d = boolUnion(d,rbox(vec3(0.0,-0.06,0.0)-p,vec3(0.85,0.05,0.55)));
    
    d = boolUnion(d,quad(vec3(0.0,0.0,0.0)-p,HOLO_SIZE));
    return d;
}

// tracing
vec3 getNormal(vec3 p, float dens) {
    vec3 n;
    n.x = map(vec3(p.x+EPSILON,p.y,p.z));
    n.y = map(vec3(p.x,p.y+EPSILON,p.z));
    n.z = map(vec3(p.x,p.y,p.z+EPSILON));
    return normalize(n-dens);
}
float getAO(vec3 p,vec3 n) {
    float r = 0.0;
    for(int i = 0; i < AO_SAMPLES; i++) {
        float f = float(i)*INV_AO_SAMPLES;
        float h = 0.01+f*AO_RADIUS;
        float d = map(p + n * h) - TRESHOLD;
        r += clamp(h-d,0.0,1.0) * (1.0-f);
    }    
    return pow(clamp(1.0-r*INV_AO_SAMPLES*AO_DARKNESS,0.0,1.0),0.5);
}
float spheretracing(vec3 ori, vec3 dir, out vec3 p) {
    float t = 0.0;
    float d = 0.0;
    for(int i = 0; i < NUM_STEPS; i++) {
        p = ori + dir * t;
        d = map(p);
        if(d < TRESHOLD) break;
        t += max(d-TRESHOLD,EPSILON);
    } 
    return d;
}

// holo
float projectLine(vec3 o, vec2 uv, vec3 v0,vec3 v1) {
    v0 = intersectPlane(o,v0-o,vec4(0.0,1.0,0.0,0.0));
    v1 = intersectPlane(o,v1-o,vec4(0.0,1.0,0.0,0.0));
    v0.xy = v0.xz / HOLO_SIZE; v1.xy = v1.xz / HOLO_SIZE;
    v0.x *= HOLO_ASPECT; v1.x *= HOLO_ASPECT;
    return line(uv,v0.xy,v1.xy);
}

void projectCircle(vec3 o,vec2 uv,vec3 v,inout vec3 c){
    vec3 d = v-o;
    v = intersectPlane(o,d,vec4(0.0,1.0,0.0,0.0));
    v.xz /= HOLO_SIZE; v.x *= HOLO_ASPECT;
    
    float r = length(uv-v.xz) * length(d) * 0.75;
    float circle = clamp(sin(r*40.0) * 5.0 * 0.5 + 0.5, 0.0,1.0);
    c = mix(c, vec3(1.0,circle,circle), smoothstep(0.50,0.48,r));
}

vec3 holoGetColor(mat4 head, vec2 p) {
    float time = iGlobalTime * 0.3;
    vec2 uv = p; uv.x *= HOLO_ASPECT;    
    vec3 pos = vec3(head[0][3],head[1][3],head[2][3]);
    
#ifdef PIXELIZE
    uv = floor(uv*HOLO_RESOLUTION) / HOLO_RESOLUTION;
#endif
    
    float i = 0.0;    
    for(int it = 0; it < HOLO_LINES; it++) {
        // vertical
        vec3 v0 = vec3(-HOLO_SIZE.x + dxdy.x * float(it+1),0.0,-HOLO_SIZE.y);
        vec3 v1 = vec3(v0.x,-HOLO_DEPTH,v0.z);
    	i += projectLine(pos,uv,v0,v1);
        
        v0 = vec3(-HOLO_SIZE.x + dxdy.x * float(it),0.0, HOLO_SIZE.y);
        v1 = vec3(v0.x,-HOLO_DEPTH,v0.z);
    	i += projectLine(pos,uv,v0,v1);      
        
        v0 = vec3(-HOLO_SIZE.x, 0.0, -HOLO_SIZE.y + dxdy.y * float(it));
        v1 = vec3(v0.x,-HOLO_DEPTH,v0.z);
    	i += projectLine(pos,uv,v0,v1);  
        
        v0 = vec3(HOLO_SIZE.x, 0.0, -HOLO_SIZE.y + dxdy.y * float(it+1));
        v1 = vec3(v0.x,-HOLO_DEPTH,v0.z);
    	i += projectLine(pos,uv,v0,v1);
        
        // horizontal
        float h = -float(it)*HOLO_DDEPTH;
        v0 = vec3(-HOLO_SIZE.x,h,-HOLO_SIZE.y);
        v1 = vec3(-v0.x,v0.y,v0.z);
    	i += projectLine(pos,uv,v0,v1);
        
        v0 = vec3(-HOLO_SIZE.x,h,HOLO_SIZE.y);
        v1 = vec3(-v0.x,v0.y,v0.z);
    	i += projectLine(pos,uv,v0,v1);
        
        v0 = vec3(-HOLO_SIZE.x,h,-HOLO_SIZE.y);
        v1 = vec3(v0.x,v0.y,-v0.z);
    	i += projectLine(pos,uv,v0,v1);
        
        v0 = vec3(HOLO_SIZE.x,h,-HOLO_SIZE.y);
        v1 = vec3(v0.x,v0.y,-v0.z);
    	i += projectLine(pos,uv,v0,v1);       
    }
    
    vec3 color = vec3(min(i,1.0));    
    projectCircle(pos,uv,vec3(-0.5,-3.0,0.0),color);
    projectCircle(pos,uv,vec3( 0.5,-1.0,0.0),color);
    projectCircle(pos,uv,vec3( 0.0, 1.0,0.0),color);
    color += texture2D(iChannel0,uv*0.5).z * 0.3;
    return color;
}

vec3 holoGetColor(mat4 head, vec3 p) {
    return holoGetColor(head,p.xz / HOLO_SIZE);
}

// main
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;    
    float time = iGlobalTime * 0.3;
        
    // ray
    vec3 ang = vec3(0.0,0.7,time);
    if(iMouse.z > 0.0) ang = vec3(0.0,clamp(2.0-iMouse.y*0.01,-0.3,PI),iMouse.x*0.01);
	mat4 rot = fromEuler(ang);
    
    vec3 ori = vec3(0.0,0.0,2.0+sin(time)*0.5);
    vec3 dir = normalize(vec3(uv.xy,-2.0));    
    ori = rotate(ori,rot);
    dir = rotate(dir,rot);
    mat4 head = rot * getPosMatrix(ori);
    
    // change camera
#ifdef CAMERA_CHANGE
    rot = fromEuler(vec3(0.0,1.0,0.0));
    vec3 ori2 = vec3(0.0,0.0,2.0);
    vec3 dir2 = normalize(vec3(uv.xy,-2.0));    
    ori2 = rotate(ori2,rot);
    dir2 = rotate(dir2,rot);
    
    float camera_change_factor = clamp((sin(time)-0.8)*10.0,-1.0,1.0) * 0.5 + 0.5;
    ori = mix(ori,ori2,camera_change_factor);
    dir = normalize(mix(dir,dir2,camera_change_factor));
#endif
    
    // tracing
    vec3 p;
    float dens = spheretracing(ori,dir,p);
    vec3 n = getNormal(p,dens);
    float ao = getAO(p,n);
         
    // color
    vec3 color = vec3(0.6+texture2D(iChannel0,(p.xz+p.y*0.2)*0.1).x * 0.05);
    if(p.y >= -EPSILON && dot(p.xz,p.xz) < 1.0) color = holoGetColor(head,p);
    color *= 1.0-pow(dot(p,p)*0.01,0.4);
    
    // lighting
    vec3 l0 = normalize(vec3(0.0,0.5,0.7));
    vec3 l1 = normalize(vec3(0.5,0.5,-0.7));    
    color += vec3((diffuse(n,l0,3.0) + specular(n,l0,dir,20.0)) * RED);
    color += vec3((diffuse(n,l1,3.0) + specular(n,l1,dir,20.0)) * BLUE);    
    color = clamp(color*ao*0.9,0.0,1.0);
    color = mix(vec3(0.3),color,step(dens,1.0));
        
    //color = vec3(ao);
    //color = n * 0.5 + 0.5;
	
	fragColor = vec4(color,1.0);
}