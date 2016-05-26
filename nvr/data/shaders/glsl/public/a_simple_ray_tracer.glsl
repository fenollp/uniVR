// Shader downloaded from https://www.shadertoy.com/view/Xls3DM
// written by shadertoy user AxleMike
//
// Name: A Simple Ray Tracer
// Description: My first ray tracer.  Basically a testbed to mess around in.
// Alexander Lemke, 2015

// A rough draft of a ray tracer, I need to go back through and fix some artifacts and optimize

// References:
// Used iq's noise example and anji's ray tracer as initial examples

// https://www.shadertoy.com/view/lsf3WH
// https://www.shadertoy.com/view/4dsGRn

//////////////////////////////////////////////////
// Settings
//////////////////////////////////////////////////
#define     NUMBER_OF_BOUNCES   	4
#define     MATERIALS_ENABLED   	1
#define     SHADOWS_ENABLED     	1
#define     SOFT_SHADOWS_ENABLED	1
#define 	SOFT_SHADOW_SAMPLES		26 // 100 looks nice but is slow, need to optimize
#define     SHOW_NORMALS        	0

//////////////////////////////////////////////////
// Constants
//////////////////////////////////////////////////
const float     PI 				 = 3.14159265359;
const float     MAX_DISTANCE 	 = 1000.0;
const float     EPSILON 		 = 0.001;

//////////////////////////////////////////////////
// Helpers
//////////////////////////////////////////////////  
float Saturate(in float f)
{
    return clamp(f, 0.0, 1.0);
}

vec3 Saturate(in vec3 v)
{
    return clamp(v, 0.0, 1.0);
}

float Noise(in vec2 uv)
{ 
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453); 
} 

float ComputeFresnel(in float NdotV)
{
	const float fresnelReflectionIndex = 0.01;
	float fresnel = fresnelReflectionIndex + (1.0 - fresnelReflectionIndex) * pow((1.0 - NdotV), 5.0);
    return fresnel;
}

mat3 Create3x3RotationMatrix(in vec3 axis, in float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float rc = 1.0 - c;
    
    return mat3(rc * axis.x * axis.x + c,          rc * axis.x * axis.y - axis.z * s, rc * axis.z * axis.x + axis.y * s,
                rc * axis.x * axis.y + axis.z * s, rc * axis.y * axis.y + c,          rc * axis.y * axis.z - axis.x * s,
                rc * axis.z * axis.x - axis.y * s, rc * axis.y * axis.z + axis.x * s, rc * axis.z * axis.z + c);
}

//////////////////////////////////////////////////
// Materials
//////////////////////////////////////////////////  
struct Material
{
    vec3    mAlbedo;
    vec3    mSpecular;
    float   mMicrosurface;
};
    
const int NUMBER_OF_MATERIALS = 5;
Material gMaterials[NUMBER_OF_MATERIALS];

void InitializeMaterials()
{
    gMaterials[0] = Material(vec3(0.8, 0.8, 0.8), vec3(0.80), 1.0);
    gMaterials[1] = Material(vec3(0.1, 1.0, 0.1), vec3(0.32), 0.3);
    gMaterials[2] = Material(vec3(1.0, 0.7, 0.0), vec3(0.42), 0.1);
    gMaterials[3] = Material(vec3(0.4, 0.4, 0.8), vec3(0.05), 0.2); 
    gMaterials[4] = Material(vec3(0.9, 0.1, 0.1), vec3(0.02), 0.2); 
}

//////////////////////////////////////////////////
// Geometry
//////////////////////////////////////////////////
struct Ray
{
    vec3    mPosition;
    vec3    mDirection;
};    

struct Sphere
{
    vec3    mCenter;
    float   mRadius;

#if MATERIALS_ENABLED
    Material    mMaterial;
#endif // MATERIALS_ENABLED
};

struct Plane
{
    vec3    mNormal;
    float   mD;
    
#if MATERIALS_ENABLED
    Material    mMaterial;
#endif // MATERIALS_ENABLED
};
        
//////////////////////////////////////////////////
// Intersection Helpers
//////////////////////////////////////////////////   
struct IntersectionPoint
{
    vec3        mPoint;
    vec3        mNormal;
    float       mT;
    
#if MATERIALS_ENABLED
    Material    mMaterial;
#endif // MATERIALS_ENABLED
};
    
IntersectionPoint GetClosestIntersection(in IntersectionPoint a, in IntersectionPoint b)
{
    if(a.mT < b.mT)
    {
        return a;
    }
    return b;  
}
  
bool IsIntersectionValid(in IntersectionPoint a)
{
    return (a.mT < (MAX_DISTANCE - EPSILON));  
}

//////////////////////////////////////////////////
// Creation Helpers
////////////////////////////////////////////////// 
#if MATERIALS_ENABLED
#define CREATE_SPHERE(position, radius, material) Sphere(position, radius, material)
#define CREATE_PLANE(normal, d, material) Plane(normalize(normal), d, material)
#define CREATE_TRIANGLE(a, b, c, material) Triangle(a, b, c, material)
#define INVALID_INTERSECTION IntersectionPoint(vec3(0.0), vec3(0.0), MAX_DISTANCE, gMaterials[0])
#else
#define CREATE_SPHERE(position, radius, material) Sphere(position, radius)    
#define CREATE_PLANE(normal, d, material) Plane(normalize(normal), d)   
#define CREATE_TRIANGLE(a, b, c) Triangle(a, b, c)
#define INVALID_INTERSECTION IntersectionPoint(vec3(0.0), vec3(0.0), MAX_DISTANCE) 
#endif // MATERIALS_ENABLED  

//////////////////////////////////////////////////
// Intersection Tests
////////////////////////////////////////////////// 
IntersectionPoint RayPlaneIntersectionTest(in Ray ray, in Plane plane)
{
    IntersectionPoint intersection = INVALID_INTERSECTION;
    
    float numerator = plane.mD - dot(plane.mNormal, ray.mPosition);
    float denominator = dot(plane.mNormal, ray.mDirection);
    if(abs(denominator) > EPSILON)
    {
        float t = numerator / denominator;
        if(t > EPSILON)
        {
            intersection.mPoint = ray.mPosition + ray.mDirection * t;
            intersection.mNormal = plane.mNormal;
            intersection.mT = t;

#if MATERIALS_ENABLED
            intersection.mMaterial = plane.mMaterial;
#endif // MATERIALS_ENABLED   
        }
    }
    return intersection;
}

IntersectionPoint RaySphereIntersectionTest(in Ray ray, in Sphere sphere)
{   
    IntersectionPoint intersection = INVALID_INTERSECTION;

    float sRadiusSquared = sphere.mRadius * sphere.mRadius;
    vec3 eDistance = ray.mPosition - sphere.mCenter;
    
    float b = dot(eDistance, ray.mDirection);
    float c = dot(eDistance, eDistance) - sRadiusSquared;
    
    if((c > 0.0 && b > 0.0) == false)
    {   
        float discriminant = (b * b) - c;
        float t = max(-b - sqrt(discriminant), 0.0); // clamp t to zero incase it started inside the sphere
           
        if(discriminant >= EPSILON)
        {
            intersection.mPoint = ray.mPosition + ray.mDirection * t;
            intersection.mNormal = normalize(intersection.mPoint - sphere.mCenter);
            intersection.mT = t;
      
#if MATERIALS_ENABLED
            intersection.mMaterial = sphere.mMaterial;
#endif // MATERIALS_ENABLED          
       }      
    }
    return intersection;
}

IntersectionPoint CheckSceneForIntersection(in Ray currentRay)
{
    // Spheres
    Sphere sphere0 = CREATE_SPHERE(vec3(-1.3, -0.2, -0.2), 0.2 + pow(abs(sin(iGlobalTime * PI * 0.4 + 0.2) * 0.4), 2.0), gMaterials[1]);  
    Sphere sphere1 = CREATE_SPHERE(vec3(-0.1, (sin(iGlobalTime * PI * 0.4) * 0.75) + 0.35, -0.5), 0.7, gMaterials[2]);  
    Sphere sphere2 = CREATE_SPHERE(vec3(0.9, -0.05, 0.2), 0.4, gMaterials[3]);
    Sphere sphere3 = CREATE_SPHERE(vec3(0.1 + (cos(iGlobalTime * PI * 0.4)), 0.8, 0.7), 0.5, gMaterials[4]);

    // Check scene for intersection   
    IntersectionPoint sphereIntersection0 = RaySphereIntersectionTest(currentRay, sphere0);
    IntersectionPoint sphereIntersection1 = RaySphereIntersectionTest(currentRay, sphere1);
    IntersectionPoint closestIntersection = GetClosestIntersection(sphereIntersection0, sphereIntersection1);
    sphereIntersection0 = RaySphereIntersectionTest(currentRay, sphere2);
    closestIntersection = GetClosestIntersection(closestIntersection, sphereIntersection0);
    sphereIntersection0 = RaySphereIntersectionTest(currentRay, sphere3);
    closestIntersection = GetClosestIntersection(closestIntersection, sphereIntersection0);
   
    // Ground Plane
    Plane plane0 = CREATE_PLANE(vec3(0.0, 1.0, 0.0), -1.1, gMaterials[0]);  
    IntersectionPoint planeIntersection = RayPlaneIntersectionTest(currentRay, plane0);
    closestIntersection = GetClosestIntersection(closestIntersection, planeIntersection);
     
    return closestIntersection;
}

//////////////////////////////////////////////////
// Lighting Helpers
//////////////////////////////////////////////////
struct DirectionalLight
{
    vec3 mDirection;
    vec3 mColor;
}; 
    
vec3 ApplyDirectionalLight(in DirectionalLight light, in IntersectionPoint geometryIntersection, in vec3 startingPoint)
{
    // Determine some values
    vec3 normal = normalize(geometryIntersection.mNormal);
    vec3 lightDirection = normalize(-light.mDirection);
    vec3 viewVector = normalize(startingPoint - geometryIntersection.mPoint);
    vec3 halfVector = normalize(lightDirection + viewVector);
    
    // Wolfgang's cook torrence approach from Programming Vertex and Pixel shaders 
    float NdotL = Saturate(dot(normal, lightDirection));
    float NdotH = Saturate(dot(normal, halfVector));
    float NdotV = Saturate(dot(normal, viewVector));
    float VdotH = Saturate(dot(viewVector, halfVector));
    float NHSquared = NdotH * NdotH;
    float roughnessSquared = geometryIntersection.mMaterial.mMicrosurface * geometryIntersection.mMaterial.mMicrosurface;
    
    float microfacets = 0.0;
    float geometricAttenuation = 0.0;
    vec3 specular = vec3(0.0);
    
    float denom0 = roughnessSquared * NHSquared;
    float denom1 = denom0 * NHSquared;
    
    if((abs(denom0) > EPSILON) && (abs(denom1) > EPSILON))
    {
    	microfacets = (1.0 / denom1) * (exp(-((1.0 - NHSquared) / denom0))); // D
    }
   	if(abs(VdotH) > EPSILON)
    {
    	geometricAttenuation = min(1.0, min((2.0 * NdotH * NdotL) / VdotH, (2.0 * NdotH * NdotV) / VdotH)); // G
    }
    float fresnel = ComputeFresnel(NdotV); // F
    
    float denom2 = PI * NdotL * NdotV;
    if(abs(denom2) > EPSILON)
    {
    	specular = (fresnel * microfacets * geometricAttenuation) / denom2 * geometryIntersection.mMaterial.mSpecular;
    }
    vec3 lighting = ((NdotL * Saturate(1.5 * ((0.7 * NdotL * geometryIntersection.mMaterial.mAlbedo + specular)))))  * light.mColor;
        
    // Cast a ray to check for shadows
    float shadow = 1.0;
#if SHADOWS_ENABLED
   
#if SOFT_SHADOWS_ENABLED  
    // Create slight varations around the incomming light direction for sampling
    vec3 axis0 = normalize(cross(lightDirection, vec3(0.0, 1.0, 0.0)));
    vec3 axis1 = normalize(cross(lightDirection, axis0));
                       
    for(int i = 0; i < SOFT_SHADOW_SAMPLES; ++i)
    {   
        float index = float(i);
        float sampleIndex = index / float(SOFT_SHADOW_SAMPLES / 4) * 2.0 * PI + Noise(startingPoint.xz);
     	float pushAmount = (mod(index, 4.0) + 1.0) * 0.25;
        vec3 offset = (cos(sampleIndex) * axis0 + sin(sampleIndex) * axis1) * pushAmount * 0.01;
        
    	Ray shadowRay = Ray(geometryIntersection.mPoint + (EPSILON * normal), (lightDirection + offset));
    	IntersectionPoint lightIntersection = CheckSceneForIntersection(shadowRay);
        shadow += IsIntersectionValid(lightIntersection) ? 0.0 : 1.0; // Determine if we hit an object and are in a shadow region
    }
    shadow /= float(SOFT_SHADOW_SAMPLES);
#else
    Ray shadowRay = Ray(geometryIntersection.mPoint + (EPSILON * normal), lightDirection);
    IntersectionPoint lightIntersection = CheckSceneForIntersection(shadowRay);
    shadow = IsIntersectionValid(lightIntersection) ? 0.0 : shadow; // Determine if we hit an object and are in a shadow region
#endif // SOFT_SHADOWS_ENABLED
    
#endif // SHADOWS_ENABLED
    
    return (lighting * shadow);
}

vec3 CalculateLighting(in IntersectionPoint intersection, in vec3 startingPoint)
{
    DirectionalLight directionalLight = DirectionalLight(vec3(0.4, -1.0, -0.8), vec3(1.0));    
    return ApplyDirectionalLight(directionalLight, intersection, startingPoint);
}

//////////////////////////////////////////////////
// Implementation
//////////////////////////////////////////////////
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    InitializeMaterials();

    // Adjust UVs for for the resolution so our world goes from [-1,-1] to [1,1]
    float aspectRatio = (iResolution.x / iResolution.y);
    vec2 uv =  2.0 * (fragCoord.xy / iResolution.xy) - 1.0;
    vec2 aspectRatioAdjustedUVs = vec2(uv.x * aspectRatio, uv.y);
       
    // Rotate the scene
    float rotationValue = (iMouse.z > 0.0) ? (iMouse.x / iResolution.x) * PI * 2.0 : (iGlobalTime * PI) * 0.1; // Multiply by 0.1 to slow down the rotation ;   
    mat3 rotationMatrix = Create3x3RotationMatrix(vec3(0.0, -1.0, 0.0), rotationValue);
    vec3 cameraPosition = vec3(2.0 * sin(rotationValue), 0.0, 2.0 * cos(rotationValue));
    
    // Determine the inital ray, the camera ray 
    vec3 cameraRayDirection = normalize(vec3(aspectRatioAdjustedUVs.xy, -1.0));
    cameraRayDirection = (rotationMatrix * cameraRayDirection);
    Ray ray = Ray(cameraPosition, cameraRayDirection);
          
    vec3 color = vec3(0.0);
    
    // Find the first collision
    IntersectionPoint currentIntersection = CheckSceneForIntersection(ray);

#if SHOW_NORMALS    
    vec3 normal = currentIntersection.mNormal;
#endif // SHOW_NORMALS
    
    vec3 specular = vec3(1.0); // Specular starts at one and will decrease with every bounce
	vec3 lighting = vec3(1.0); // Lighting starts at one so background cubemap will be lit
 
    for(int i = 0; i < NUMBER_OF_BOUNCES; ++i)
    {
        // Only apply the bounces if we actually hit something
        if(IsIntersectionValid(currentIntersection))
        {
            lighting = CalculateLighting(currentIntersection, ray.mPosition);
            color += (lighting * specular);
            
            specular *= (currentIntersection.mMaterial.mSpecular); 

            // Determine the bounce direction of the ray and update the structure
            ray.mDirection = reflect(ray.mDirection, currentIntersection.mNormal);
            ray.mPosition = currentIntersection.mPoint + ray.mDirection * EPSILON;

            // Trace the ray forward
            currentIntersection = CheckSceneForIntersection(ray);
        }
        else
        {
            // We didn't hit anything, so return the texture cube color and break out!
            color.rgb += textureCube(iChannel0, ray.mDirection).rgb * specular; 
            break; 
        }
    }
    
#if SHOW_NORMALS    
    fragColor = vec4(normal * 0.5 + 0.5, 1.0); // Modify the normal to go from [0,0] to [1,1]
#else
    fragColor = vec4(color.rgb, 1.0);
#endif 
}