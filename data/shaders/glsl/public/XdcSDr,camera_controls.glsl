// Shader downloaded from https://www.shadertoy.com/view/XdcSDr
// written by shadertoy user mgattis
//
// Name: Camera Controls
// Description: W, A, S, D, SPACE (ascend), SHIFT (descend). Render options and look inversion are at the top of the Image shader. Enjoy!
#define MAX_DISTANCE            (32.0)
#define MIN_DELTA               (0.01)
#define MAX_RAYITERATIONS       (192)

// Look inversion.
//#define Y_LOOK_INVERSION

// Render options.
#define USE_ANTIALIAS
#define USE_REFLECTION
#define USE_SHADOW

// Debug mode? :3
//     Scale [Zero Iterations] black > red > yellow > white [MAX_DEBUGITERATIONS]
//     Brighter (yellow, white) pixels require more iterations to render, which is a
//     good indicator of relative performance.
//#define DEBUG
#define MAX_DEBUGITERATIONS     (MAX_RAYITERATIONS * 4) /* quarter of max */

// Background
#define BG_DIRECTION            (vec3(0.0, 0.0, 1.0))
#define BG_COLOR1               (vec3(1.0, 1.0, 1.0))
#define BG_COLOR2               (vec3(0.0, 0.5, 1.0))
#define BG_COLOR3               (vec3(1.0, 1.0, 1.0))
//#define USE_CUBEMAP

// Sun
#define SUN_DIRECTION           (normalize(vec3(0.5, 0.5, 1.0)))

// Surface
#define OBJECT_REFLECTIVITY     (0.1)

// Fog
#define FOG_POWER               (32.0)

#ifndef M_PI
#define M_PI                    (3.1415926535897932384626433832795)
#endif

#define VALUE_POSITION          (1)
#define VALUE_ROTATION          (2)

int debugIterationCount;

// Retrieve value from BufferA.
vec4 getValue(int a)
{
    vec2 q = vec2(float(a) + 0.5, 0.0) / iResolution.x;
    return texture2D(iChannel0, q);
}

vec3 vRotateX(vec3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return vec3(p.x, c*p.y + s*p.z, -s*p.y + c*p.z);
}

vec3 vRotateY(vec3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return vec3(c*p.x - s*p.z, p.y, s*p.x + c*p.z);
}

vec3 vRotateZ(vec3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return vec3(c*p.x + s*p.y, -s*p.x + c*p.y, p.z);
}

float sphere(in vec3 p, in float r)
{
    p.xy = mod(p.xy, 4.0) - 2.0;
    return length(p) - r;
}

float getMap(in vec3 p, out int object)
{
    float finalDistance;
    float tempDistance;
    
    finalDistance = sphere(p - vec3(0.0, 4.0, 1.0), 1.0);
    object = 1;
    
    tempDistance = p.z;
    if (tempDistance < finalDistance)
    {
        finalDistance = tempDistance;
        object = 2;
    }
    
    return finalDistance;
}

float ambientOcclusion(vec3 p, vec3 n)
{
	float stepSize = 0.017;
	float t = stepSize;
	float oc = 0.0;
	int object = 0;
	for(int i = 0; i < 8; ++i)
	{
		float d = getMap(p + n * t, object);
		oc += t - d; // Actual distance to surface - distance field value
		t += stepSize;
	}

	return 1.0-clamp(oc, 0.0, 1.0);
}

vec3 getNormal(vec3 p)
{
    vec3 s = p;
    float h = MIN_DELTA;
    int object;
    return normalize(vec3(
            getMap(p + vec3(h, 0.0, 0.0), object) - getMap(p - vec3(h, 0.0, 0.0), object),
            getMap(p + vec3(0.0, h, 0.0), object) - getMap(p - vec3(0.0, h, 0.0), object),
            getMap(p + vec3(0.0, 0.0, h), object) - getMap(p - vec3(0.0, 0.0, h), object)));
}

float castRay(in vec3 origin, in vec3 direction, out int object)
{
    float rayDistance = 0.0;
    float rayDelta = 0.0;
    vec3 rayPosition;
    object = 0;
    
    rayPosition = origin;
    
    for (int i = 0; i < MAX_RAYITERATIONS; i++)
    {
        debugIterationCount++;
        
        rayDelta = getMap(rayPosition, object);
        
        rayDistance += rayDelta;
        rayPosition = origin + direction * rayDistance;
        if (rayDelta <= MIN_DELTA)
        {
            return rayDistance;
        }
        if (rayDistance >= MAX_DISTANCE)
        {
            object = 0;
            return MAX_DISTANCE;
        }
    }
    
    object = 0;
    return MAX_DISTANCE;
}

vec3 getBackground(in vec3 direction)
{
#ifdef USE_CUBEMAP
    return textureCube(iChannel1, -direction.xzy).rgb;
#endif
    
    float bgVal = dot(direction, BG_DIRECTION);
    
    if (bgVal >= 0.0)
    {
        bgVal = pow(1.0 - bgVal, 2.5);
        return mix(BG_COLOR2, BG_COLOR1, bgVal);
    }
    
    return BG_COLOR1;
}

// http://www.pouet.net/topic.php?which=7931&page=1&x=3&y=14
vec3 hsv(float h,float s,float v) {
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}

vec3 getSurfaceColor(in vec3 position, in int object)
{
    
    if (object == 1)
    {
        position.xy = position.xy / 4.0;
        position.xy = position.xy - fract(position.xy);
        position.xy = position.xy / 6.0;
        float dist = abs(position.x) + abs(position.y);
        return hsv(dist, 1.0, 1.0) + vec3(0.2, 0.2, 0.2);
    }
    else if (object == 2)
    {
        return vec3(1.0, 1.0, 1.0);
    }
    
    return vec3(1.0, 1.0, 1.0);
}

vec3 applyLight(in vec3 color, in vec3 normal, in vec3 position, in vec3 direction)
{
    vec3 diffuseColor = vec3(0.0, 0.0, 0.0);
    vec3 specularColor = vec3(0.0, 0.0, 0.0);
    int object = 0;
    
    vec3 SunDirection = SUN_DIRECTION;
    
    vec3 ambientColor = color * 0.2 * ambientOcclusion(position, normal);
    
#ifdef USE_SHADOW
    position = position + normal * MIN_DELTA * 1.1;
    castRay(position, SunDirection, object);
    
    if (object == 0)
#endif
    {
        float diffuse = max(0.0, dot(normal, SunDirection));
        diffuseColor = color * diffuse;
        
        vec3 ref = normalize(reflect(direction, normal));
        float specular = max(0.0, dot(SunDirection, ref));
        specular = pow(specular, 16.0);
        specularColor = vec3(1.0, 1.0, 1.0) * specular;
    }
    
    //float ao = ambientOcclusion(position, normal);
    
    return ambientColor + diffuseColor + specularColor;
}

vec3 drawScene(in vec3 origin, in vec3 direction)
{
    vec3 firstColor = vec3(0.0, 0.0, 0.0);
    vec3 secondColor = vec3(0.0, 0.0, 0.0);
    vec3 finalColor = vec3(0.0, 0.0, 0.0);
    int object = 0;
    
    float firstDistance = castRay(origin, direction, object);
    
    vec3 firstPosition = origin + direction * firstDistance;
    vec3 firstNormal = getNormal(firstPosition);
    
    firstColor = getSurfaceColor(firstPosition, object);
    
    if (object == 0)
    {
        vec3 bgColor = getBackground(direction);
        float fogVal = pow(firstDistance / MAX_DISTANCE, FOG_POWER);
        return mix(firstColor, bgColor, fogVal);
    }
    
    firstColor = applyLight(firstColor, firstNormal, firstPosition, direction);
    
#ifdef USE_REFLECTION
    vec3 secondOrigin = firstPosition + firstNormal * MIN_DELTA * 1.1;
    vec3 secondDirection = normalize(reflect(direction, firstNormal));
    
    float secondDistance = castRay(secondOrigin, secondDirection, object);
    
    if (object != 0)
    {
        vec3 secondPosition = secondOrigin + secondDirection * secondDistance;
        vec3 secondNormal = getNormal(secondPosition);

        secondColor = getSurfaceColor(secondPosition, object);
        secondColor = applyLight(secondColor, secondNormal, secondPosition, secondDirection);
        // We are going to apply some background color to the secondColor.
        vec3 secondReflection = normalize(reflect(secondDirection, secondNormal));
        secondColor = mix(secondColor, getBackground(secondReflection), OBJECT_REFLECTIVITY);
    }
    else
    {
        secondColor = getBackground(secondDirection);
    }
    
    finalColor = mix(firstColor, secondColor, OBJECT_REFLECTIVITY);
#else
    // Finish up first ray (NO_REFLECTION).
    if (object != 0)
    {
        // We are going to apply some background color only if we hit an object.
        vec3 firstReflection = normalize(reflect(direction, firstNormal));
        firstColor = mix(firstColor, getBackground(firstReflection), OBJECT_REFLECTIVITY);
    }
    
    finalColor = firstColor;
#endif
    
    vec3 bgColor = getBackground(direction);
    float fogVal = pow(firstDistance / MAX_DISTANCE, FOG_POWER);
    return mix(finalColor, bgColor, fogVal);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    vec3 cameraPosition = getValue(VALUE_POSITION).xyz;
    vec3 cameraRotation = getValue(VALUE_ROTATION).xyz;
    
#ifdef Y_LOOK_INVERSION
    cameraRotation.x = -cameraRotation.x;
#endif
    
    vec3 origin = vec3(0.0, 0.0, 4.0) - cameraPosition;
    
    debugIterationCount = 0;
    
    // Use simple AA.
#ifdef USE_ANTIALIAS
    for (int i = 0; i < 4; i++)
    {
        vec2 offset = vec2(
            mod(float(i), 2.0),
            float(i / 2)
            ) / 2.0;
        
        vec2 p = 2.0 * (fragCoord.xy + offset) / iResolution.y;
        p -= vec2(iResolution.x / iResolution.y, 1.0);
        
        vec3 direction = vec3(p.x, -1.5, p.y);
        direction = vRotateX(direction, cameraRotation.x);
        direction = vRotateZ(direction, cameraRotation.z);
        direction = normalize(direction);

        color += drawScene(origin, direction) / 4.0;
    }
#else
    vec2 p = 2.0 * fragCoord.xy / iResolution.y;
    p -= vec2(iResolution.x / iResolution.y, 1.0);

    vec3 direction = vec3(p.x, -1.5, p.y);
    direction = vRotateX(direction, cameraRotation.x);
    direction = vRotateZ(direction, cameraRotation.z);
    direction = normalize(direction);

    color += drawScene(origin, direction);
#endif
    
#ifdef DEBUG
    float debug = (float(debugIterationCount) / float(MAX_DEBUGITERATIONS)) * 3.0;
    fragColor = vec4(debug, debug - 1.0, debug - 2.0, 1.0);
    if (fragCoord.y < 1.0)
    {
    	fragColor = texture2D(iChannel0, vec2(fragCoord.x / iResolution.x, 0.0));
    }
    return;
#endif
    
	color = pow(color, vec3(1.0 / 2.2));
    fragColor = vec4(color, 1.0);
}