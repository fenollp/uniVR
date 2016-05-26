// Shader downloaded from https://www.shadertoy.com/view/Mst3DB
// written by shadertoy user marty1885
//
// Name: The simplest path tracer
// Description: Click and move you mouse to move the triangle and see what happens!
//TODO: Apply FXAA to decrease noise.

#define M_PI           3.14159265358979323846  /* pi */
#define SAMPLE_NUM 86
#define MAX_BOUNCE_DEPTH 8
#define LIGHT_EMIT_STRENGTH 20.0
#define GAMMA 2.2

//NOTE : NEVER make this over 3. It crashes my AMD HD 7850 GPU.
#define TRIANGLE_NUM 3

struct Camera
{
    vec3 position;
    vec3 direction;
    vec3 up;
};
    
struct Ray
{
    vec3 origin;
    vec3 direction;
};
    
struct Triangle
{
    vec3 vertex[3];
    vec3 reflectColor;
    vec3 emitColor;
};

Triangle sceneTriangle[TRIANGLE_NUM];

Camera lookAt(vec3 position, vec3 direction, vec3 up)
{
    Camera cam;
    cam.position = position;
    cam.direction = normalize(direction - position);
    cam.up = normalize(up);
    return cam;
}

Ray createRay(vec3 origin, vec3 direction)
{
	Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    return ray;
}

Ray createCameraRay(Camera cam, vec2 uv)
{
    vec3 right = normalize(cross(cam.direction,cam.up));
    vec3 direction = cam.direction
        + cam.up * 2.0 * (uv.y - 0.5)
        + right * 2.0 * (0.5 - uv.x);
    Ray ray;
    ray = createRay(cam.position, direction);
    return ray;
}

//return val => mat4 [0] = vec4(u,v,distance,0)
//						 		   [1] = vec4(normal,0)
//						 		   [2] = vec4(reflectColor,1)
//						 		   [3] = vec4(emitColor,1)
mat4 findIntersection(Ray ray, Triangle triangle)
{
	vec3 v0v1 = triangle.vertex[1] - triangle.vertex[0];
	vec3 v0v2 = triangle.vertex[2] - triangle.vertex[0];
	vec3 pvec = cross(ray.direction,v0v2);
	float det = dot(v0v1,pvec);
	float u, v, t;

	// ray and triangle are parallel if det is close to 0
	if(det < 1e-7 && det > -1e-7)
		return -1;

	float invDet = 1 / det;

	float4 tvec = ray.origin - triangle.vertex[0];
	u = dot(tvec, pvec) * invDet;
	if(u < 0 || u > 1)
		return -1;

	float4 qvec = cross(tvec, v0v1);
	v = dot(ray.direction, qvec) * invDet;
	if(v < 0 || u + v > 1)
		return -1;

	t = dot(v0v2, qvec) * invDet;

	if(uv != 0)
		*uv = float4(u, v, 0.0f, 0.0f);

	if(intersection != 0)
		*intersection = ray.origin + ray.direction*t;

	return t;        
        mat4 result;
        result[0] = vec4(uv,length(intersec - ray.origin),0);
        result[1] = vec4(normal,0);
        result[2] = vec4(triangle.reflectColor,1);
        result[3] = vec4(triangle.emitColor,1);

    
	return result;
}
mat4 findIntersectionScene(Ray ray)
{
    mat4 hit;
    hit[0].z = -1.0;
    
    for(int i=0;i<TRIANGLE_NUM;i++)
    {
        mat4 hitProp = findIntersection(ray,sceneTriangle[i]);
        if((hitProp[0].z < hit[0].z || hit[0].z < 0.0) && hitProp[0].z > 0.0)
        {
            hit = hitProp;
        }
    }
    return hit;
}

vec2 randSeed;
highp float rand()
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(randSeed.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    highp float val = fract(sin(sn) * c);
    randSeed = texture2D(iChannel0,vec2(randSeed)).xy;
    return val;
}

Ray createRandomReflect(Ray ray, mat4 hit)
{
	vec3 normal = hit[1].xyz;
	if(dot(normal,ray.direction) > 0.0)
    	normal = -normal;

    vec3 worldUp = vec3(1,1,0);
	vec3 e0 = normalize(normal);
	vec3 e1 = normalize(cross(e0,worldUp));
	vec3 e2 = normalize(cross(e0,e1));

	//Create evenly distributed ray
	//reference: http://mathworld.wolfram.com/SpherePointPicking.html

    float phi = rand()*M_PI*2.0;
	float x = rand();
	float theta = abs(acos(x));//NOTE : sometimes acos will give a small negiative number.
	vec3 direction = normalize(sin(theta)*cos(phi)*e1 +
		sin(theta)*sin(phi)*e2 +
		abs(cos(theta))*e0);

    vec3 intersection = normalize(ray.direction)*hit[0].z + ray.origin;
	vec3 origin = intersection
		+direction*0.0001; //workaround float point accuracy issue
    
	Ray reflect = createRay(origin, direction);
	return reflect;
}

vec3 trace(Ray ray)
{
    Ray currentRay = ray;
    vec3 renderedColor = vec3(0,0,0);
    vec3 factor = vec3(1,1,1);
    
    for(int i=0;i<MAX_BOUNCE_DEPTH;i++)
    {
        mat4 hit = findIntersectionScene(currentRay);
        if(hit[0].z > 0.0)
        {
            renderedColor += hit[3].xyz*factor;
            factor *= hit[2].xyz;
            currentRay = createRandomReflect(ray,hit);//Ideal Deffuse BRDF
        }
        else
            break;
    }
    
    return renderedColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //create a Camera
    Camera camera = lookAt(vec3(0,4.0,7.0),vec3(0,0.0,0.0),vec3(0,1,0));
    
    //Initlaze rand() using uv coord
	vec2 uv = fragCoord.xy / iResolution.xy;
    randSeed = uv;
    
    Ray ray = createCameraRay(camera,uv);
    
    //TODO : Move the scene initlization to a  buffer so we onlt need to init it once.
    vec2 mouseUV = iMouse.xy/iResolution.xy - vec2(0.5);
    mouseUV *= M_PI * 2.0;
    vec3 offset = vec3(mouseUV.x,mouseUV.y,0);
    if(offset.y < -2.3)
        offset.y = -2.29999;
    if(iMouse.x == 0.0)
        offset = vec3(0,0,0);
    
    //Big Plain
    sceneTriangle[0].vertex[0] = vec3(100,-2,-5);
    sceneTriangle[0].vertex[1] = vec3(-100,-2,-100);
    sceneTriangle[0].vertex[2] = vec3(-5,-2,100);
    sceneTriangle[0].reflectColor = vec3(1,1,1);
    sceneTriangle[0].emitColor = vec3(0,0,0);
   
    //Light Source
    sceneTriangle[1].vertex[0] = vec3(-1.7,1,1.7);
    sceneTriangle[1].vertex[1] = vec3(-1.7,1,0);
    sceneTriangle[1].vertex[2] = vec3(0,1,0);
    sceneTriangle[1].reflectColor = vec3(1,1,1);
    sceneTriangle[1].emitColor = vec3(0.8,0.7,0.65)*LIGHT_EMIT_STRENGTH;

    //Small triangle
    sceneTriangle[2].vertex[0] = vec3(-2.0,0.3,2.0) + offset;
    sceneTriangle[2].vertex[1] = vec3(-2.0,0.3,0) + offset;
    sceneTriangle[2].vertex[2] = vec3(0,0.3,0) + offset;
    sceneTriangle[2].reflectColor = vec3(1,1,1);
    sceneTriangle[2].emitColor = vec3(0,0,0);
    
    vec3 renderColor = vec3(0,0,0);
    for(int i=0;i<SAMPLE_NUM;i++)
    	renderColor += trace(ray);//Recursize Path tracing
    renderColor /= float(SAMPLE_NUM);
    
    //Gamma correction
    renderColor = pow(renderColor,vec3(1.0/GAMMA));
    
    fragColor = vec4(renderColor,0.0);
}																													