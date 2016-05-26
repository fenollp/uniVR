// Shader downloaded from https://www.shadertoy.com/view/MlXXDB
// written by shadertoy user mgattis
//
// Name: Minimalist
// Description: My first try at path tracing. Casting more rays give amazing results. Had to give it a try. Special thanks to: http://blog.hvidtfeldts.net/. Here is a nice SW rendered image of the above: https://dl.dropboxusercontent.com/u/8746356/minimalist.png.
// mgattis

#define MAX_DISTANCE        (8.0)
#define MIN_DELTA           (0.004)
#define MAX_RAYITERATIONS   (96)
#define MAX_RAYSAMPLES      (4)
#define MAX_RAYREFLECTIONS  (8)

#ifndef M_PI
#define M_PI                (3.1415926535897932384626433832795)
#endif

vec2 seed;

vec2 rand2n() {
    seed+=vec2(-1,1);
	// implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
    return vec2(fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453),
		fract(cos(dot(seed.xy ,vec2(4.898,7.23))) * 23421.631));
}
 
vec3 ortho(vec3 v) {
    //  See : http://lolengine.net/blog/2013/09/21/picking-orthogonal-vector-combing-coconuts
    return abs(v.x) > abs(v.z) ? vec3(-v.y, v.x, 0.0)  : vec3(0.0, -v.z, v.y);
}

vec3 getSampleBiased(vec3  dir, float power) {
	dir = normalize(dir);
	vec3 o1 = normalize(ortho(dir));
	vec3 o2 = normalize(cross(dir, o1));
	vec2 r = rand2n();
	r.x=r.x*2.*M_PI;
	r.y=pow(r.y,1.0/(power+1.0));
	float oneminus = sqrt(1.0-r.y*r.y);
	return cos(r.x)*oneminus*o1+sin(r.x)*oneminus*o2+r.y*dir;
}
 
vec3 getSample(vec3 dir) {
	return getSampleBiased(dir,0.0); // <- unbiased!
}

vec3 getCosineWeightedSample(vec3 dir) {
	return getSampleBiased(dir,1.0);
}

vec3 getConeSample(vec3 dir, float extent) {
    // Formula 34 in GI Compendium
	dir = normalize(dir);
	vec3 o1 = normalize(ortho(dir));
	vec3 o2 = normalize(cross(dir, o1));
	vec2 r =  rand2n();
	r.x=r.x*2.*M_PI;
	r.y=1.0-r.y*extent;
	float oneminus = sqrt(1.0-r.y*r.y);
	return cos(r.x)*oneminus*o1+sin(r.x)*oneminus*o2+r.y*dir;
}

vec3 vRotateY(vec3 p, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec3(c*p.x-s*p.z, p.y, s*p.x+c*p.z);
}

float sphere(in vec3 p, in float r) {
    return length(p) - r;
}

float plane(in vec3 p, in float y) {
    return p.y - y;
}

float udBox(in vec3 p, in vec3 b) {
	return length(max(abs(p)-b,0.0));
}

float getMap(in vec3 position, out int object) {
    float rayDelta;
    float temp;
    
    vec3 p = position;
    
    rayDelta = sphere(p - vec3(0.0, 0.2, 0.0), 1.0);
    object = 1;
    
    temp = udBox(p - vec3(0.0, -1.8, 0.0), vec3(1.0, 1.0, 1.0));
    if (temp < rayDelta) {
        rayDelta = temp;
        object = 1;
    }
    
    temp = plane(p, -1.0);
    if (temp < rayDelta) {
        rayDelta = temp;
        object = 1;
    }
    
    return rayDelta;
}

vec3 getNormal(vec3 p) {
    vec3 s = p;
    float h = MIN_DELTA;
    int object;
    return normalize(vec3(
            getMap(p + vec3(h, 0.0, 0.0), object) - getMap(p - vec3(h, 0.0, 0.0), object),
            getMap(p + vec3(0.0, h, 0.0), object) - getMap(p - vec3(0.0, h, 0.0), object),
            getMap(p + vec3(0.0, 0.0, h), object) - getMap(p - vec3(0.0, 0.0, h), object)));
}

float castRay(in vec3 origin, in vec3 direction, out int object, out int iterations) {
    float rayDistance = 0.0;
    float rayDelta = 0.0;
    vec3 rayPosition;
    
    rayPosition = origin;
    
    for (int i = 0; i < MAX_RAYITERATIONS; i++) {
        iterations += 1;
        
        rayDelta = getMap(rayPosition, object);
        
        rayDistance += rayDelta;
        rayPosition = origin + direction * rayDistance;
        if (rayDelta <= MIN_DELTA) {
            return rayDistance;
        }
        if (rayDistance >= MAX_DISTANCE) {
            object = 0;
			return MAX_DISTANCE;
        }
    }
    
    object = 0;
    return MAX_DISTANCE;
}

vec3 getBackground(in vec3 direction) {
    vec3 color = vec3(0.8, 0.9, 1.0);
    
    vec3 bgDirection = normalize(vec3(1.0, 1.0, -1.0));
    float bgVal = max(0.0, dot(bgDirection, direction));
    color = mix(color, vec3(1.0, 1.0, 1.0), bgVal);
                      
    return color;
}

vec3 getColor(in vec3 position, in vec3 direction, in int object) {
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    if (object == 0) {
        color = getBackground(direction);
    }
    else if (object == 1) {
        color = vec3(1.0, 1.0, 1.0);
    }
    
    return color;
}

vec3 castFullRay(in vec3 origin, in vec3 direction, in int subframe) {
    vec3 color = vec3(1.0, 1.0, 1.0);
    vec3 directLight = vec3(0.0, 0.0, 0.0);
    float Albedo = 0.4;
    int iterations = 0;
    int object = 0;
    
    vec3 rayOrigin = origin;
    vec3 rayDirection = direction;
    
    seed = direction.xy * (float(subframe) + iGlobalTime + 1.0);
    
    for (int i = 0; i < MAX_RAYREFLECTIONS; i++) {
        float rayDistance = castRay(rayOrigin, rayDirection, object, iterations);
        if (object != 0) {            
            vec3 rayPosition = rayOrigin + rayDirection * rayDistance;
            vec3 rayNormal = getNormal(rayPosition);
            vec3 newDirection = normalize(getSample(rayNormal));

            color *= getColor(rayPosition, rayDirection, object) * Albedo * 2.0;
            
            rayOrigin = rayPosition + rayNormal * MIN_DELTA * 4.0;
            rayDirection = newDirection;
            
            vec3 sunDirection = normalize(vec3(1.0, 1.0, -1.0));
            vec3 sunSampleDirection = getConeSample(sunDirection, 0.0001);
            float sunLight = dot(rayNormal, sunSampleDirection);
            if (sunLight > 0.0) {
                castRay(rayOrigin, sunSampleDirection, object, iterations);
                if (object == 0) {
                    directLight += color * sunLight * 1.0;
                    //return vec3(1.0, 0.0, 0.0);
                }
            }
        }
        else {
            return directLight + color * getBackground(rayDirection);
        }
    }
    
    return vec3(0.0, 0.0, 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{    
    vec2 uv = 2.0 * fragCoord.xy / iResolution.y;
    uv -= vec2(iResolution.x / iResolution.y, 1.0);
    
    float myLocalTime = iGlobalTime * 0.2 + 2.0;
    
    vec3 origin = vRotateY(vec3(0.0, 0.0, -4.0), myLocalTime);
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    for (int i = 0; i < MAX_RAYSAMPLES; i++) {
        seed = uv.xy * (float(i) + 1.0);
        vec3 direction = normalize(vec3(uv.xy + rand2n() / iResolution.y * 2.0, 2.0));
        direction = vRotateY(direction, myLocalTime);
    	color += castFullRay(origin, direction, i);
    }
    
    color = color / float(MAX_RAYSAMPLES);
    
    fragColor = vec4(color,1.0);
}