// Shader downloaded from https://www.shadertoy.com/view/XtlXRM
// written by shadertoy user codywatts
//
// Name: Standing in the Water
// Description: This was my first time playing with raymarching. Somehow it turned into... this. Click and drag the mouse to move the camera.
#define PI 3.14159265359
#define TWO_PI 6.28318530718
#define EPSILON 0.005
#define X_AXIS vec3(1, 0, 0)
#define Y_AXIS vec3(0, 1, 0)
#define Z_AXIS vec3(0, 0, 1)

const int RaysPerFragment = 10;
const float MaxRaymarchingDistance = 400.0;
const float CameraHeight = 11.0;
const float CameraRadius = 4.0;
const float MinWaterHeight = 3.2;
const float MaxWaterHeight = 3.8;
const float WaveSpeed = 1.5;
const float WavePeriod = 0.4;
const float GroundTextureSize = 15.0;
const float WaterTransparency = 0.3;
const float WaterRefractionIndex = 0.3;
const vec3 SunColor = vec3(1.0, 1.0, 0.8);
const float SunSize = 0.03;
const vec3 SkyColor = vec3(255.0 / 255.0, 199.0 / 255.0, 99.0 / 255.0);
const vec3 HighSkyColor = vec3(0.0, 0.0, 0.8);
const vec3 WaterColor = vec3(0.8, 0.8, 1);
const float MinFadeDistance = 0.0;
const float MaxFadeDistance = MaxRaymarchingDistance - 50.0;

struct Material
{
	vec3 diffuseColor;
	vec3 specularColor;
	float shininess;
};

struct Plane
{
	vec3 point;
	vec3 normal;
	Material material;
};

struct Ray
{
	vec3 origin;
	vec3 direction;
};

struct Intersection
{
	bool hit;
	vec3 position;
	vec3 normal;
	Material material;
};

struct Camera
{
	vec3 position;
	vec3 forward;
	vec3 up;
	vec3 right;
};

struct Light
{
	vec3 position;
};

Intersection rayPlaneIntersection(in Ray ray, in Plane plane)
{
	Intersection i;
	i.hit = false;
	
	float dotProduct = dot(ray.direction, plane.normal);
	if (dotProduct == 0.0)
	{
		return i;
	}
	
	float distanceToHit = dot(plane.point - ray.origin, plane.normal)/dotProduct;
	if (distanceToHit < 0.0)
	{
		return i;
	}
	i.position = ray.origin + (ray.direction * distanceToHit);
	i.normal = plane.normal;
	i.material = plane.material;
	i.hit = true;
	return i;
}

void blinnPhong(in vec3 lightPosition, in vec3 cameraPosition, in vec3 objectPosition, in vec3 objectNormal, in Material material, out float diffuse, out float specular)
{
	vec3 fromObjectToLight = normalize(lightPosition - objectPosition);
	diffuse = clamp(dot(fromObjectToLight, objectNormal), 0.0, 1.0);
	vec3 fromObjectToCamera = normalize(cameraPosition - objectPosition);
	vec3 half_way = normalize(fromObjectToCamera + fromObjectToLight);
	specular = pow(clamp(dot(half_way, objectNormal), 0.0, 1.0), material.shininess);
}

float waterHeight(in float x, in float z)
{  
    float r = distance(vec2(x, z), vec2(0, 0));

    float xComponent = cos(-r * WavePeriod + iGlobalTime * WaveSpeed);
    float zComponent = sin(-r * WavePeriod + iGlobalTime * WaveSpeed);
    return MinWaterHeight + ((xComponent + zComponent) + 2.0) / 4.0 * (MaxWaterHeight - MinWaterHeight);
}

vec3 getNormal(in vec3 p)
{
    vec3 n = vec3(waterHeight(p.x - EPSILON, p.z) - waterHeight(p.x + EPSILON, p.z), 2.0 * EPSILON, waterHeight(p.x, p.z - EPSILON) - waterHeight(p.x, p.z + EPSILON));
    return normalize(n);
}

Intersection castRayAgainstWater(in Ray ray)
{
    Intersection i;
    i.hit = false;
    
    const int iterations = 20;  
    const float minDistance = 0.001;

    vec3 upperPoint = ray.origin + ray.direction * minDistance;
    vec3 lowerPoint = ray.origin + ray.direction * MaxRaymarchingDistance;
    if (sign(upperPoint.y - waterHeight( upperPoint.x, upperPoint.z )) == sign(lowerPoint.y - waterHeight( lowerPoint.x, lowerPoint.z )))
    {
        return i;
    }
   
	vec3 midPoint;
    for (int x = 0; x < iterations; ++x)
    {
        float upperPointHeight = waterHeight( upperPoint.x, upperPoint.z );
        float lowerPointHeight = waterHeight( lowerPoint.x, lowerPoint.z );
		midPoint = (upperPoint + lowerPoint) / 2.0;

		if (distance(upperPoint, lowerPoint) <= EPSILON)
		{
			break;
		}
		float midPointHeight = waterHeight( midPoint.x, midPoint.z );
		if (abs(midPoint.y - midPointHeight) <= EPSILON)
		{
			break;
		}
		else if (midPoint.y > midPointHeight)
		{
			upperPoint = midPoint;
		}
		else
		{
			lowerPoint = midPoint;
		}
    }
    
    i.hit = true;
    i.position = midPoint;
    i.normal = getNormal(i.position);
    i.material.shininess = 10.0;
    i.material.diffuseColor = WaterColor;
    i.material.specularColor = SunColor;
    return i;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Define our sun
	Light sun;
	sun.position = vec3(300000.0, 30000.0, 0.0);
    
	// Define our ground
    Plane ground;
    ground.normal = Y_AXIS;
    ground.point = vec3(0, 0, 0);
	
	// Set up our camera
	Camera camera;
	camera.position = vec3(0.0, CameraHeight, 0.0);
	
	// This is just a little hack to make the view look nice before the user has clicked on the screen.
	vec2 mouseCoords = iMouse.xy / iResolution.xy;
    if (mouseCoords.x <= 0.0 && mouseCoords.y <= 0.0)
    {
        mouseCoords = vec2(0.5, 1.0);
    }
	
	float cameraRotationAmount = mouseCoords.x * (PI / 2.0) - (PI / 4.0);
    float targetHeight = ((sin(mouseCoords.y * PI / 2.0) - 1.0) / 2.0) * CameraHeight;
    vec3 targetPosition = camera.position + vec3(cos(cameraRotationAmount) * CameraRadius, targetHeight, sin(cameraRotationAmount) * CameraRadius);
	camera.forward = normalize(targetPosition - camera.position);
	camera.right = cross(Y_AXIS, camera.forward);
	camera.up = cross(camera.forward, camera.right);

	// To antialias our image, we cast multiple rays per fragment and average the result.
	vec3 accumulatedColor = vec3(0, 0, 0);
	float accumulatedSignificance = 0.0;
	
	for (int i = 0; i < RaysPerFragment; ++i)
	{
		float t = float(i) / float(RaysPerFragment);
		
        float significance = 1.0;
		
		vec2 fragCoordOffset = vec2(cos(t * TWO_PI) * t, sin(t * TWO_PI) * t);
		vec2 uv = 2.0 * (fragCoord + fragCoordOffset) / iResolution.xy - 1.0;
		uv.x *= iResolution.x / iResolution.y;
		
		Ray ray;
		ray.origin = camera.position;
		ray.direction = normalize(camera.forward + camera.right * uv.x + camera.up * uv.y);
        
		Intersection waterIntersection = castRayAgainstWater(ray);
        Intersection groundIntersection;
        groundIntersection.hit = false;

		float angleToSun = acos(dot(normalize(sun.position - camera.position), ray.direction));
        
        Plane horizon;
        horizon.point = sun.position;
        horizon.normal = -camera.forward;
		Intersection horizonIntersection = rayPlaneIntersection(ray, horizon);      
        
        vec3 skyColor = mix(SkyColor, HighSkyColor, clamp(horizonIntersection.position.y / 500000.0 - 0.1, 0.0, 1.0));
		skyColor = mix(skyColor, SunColor, smoothstep(0.05, 0.0, angleToSun - SunSize));
		
		vec3 objectColor = skyColor;
        
        if (waterIntersection.hit == true)
        {         
            Ray refractionRay;
            refractionRay.origin = waterIntersection.position;
            refractionRay.direction = refract(ray.direction, waterIntersection.normal, WaterRefractionIndex);
            groundIntersection = rayPlaneIntersection(refractionRay, ground);
            if (groundIntersection.hit == true)
            {
            	vec3 fromPointToIntersection = groundIntersection.position - ground.point;
            	vec2 textureCoordinates = vec2(dot(fromPointToIntersection, X_AXIS), dot(fromPointToIntersection, Z_AXIS)) * (1.0 / GroundTextureSize);
                objectColor = texture2D(iChannel0, textureCoordinates).xyz;
                objectColor *= skyColor; // This tints the ground texture to match the sun.
            }
			
			float diffuse;
			float specular;
			blinnPhong(sun.position, camera.position, waterIntersection.position, waterIntersection.normal, waterIntersection.material, diffuse, specular);

            objectColor = (waterIntersection.material.diffuseColor * diffuse) * WaterTransparency + (waterIntersection.material.specularColor * specular) + objectColor * (1.0 - WaterTransparency);

			float distanceFromCamera = clamp((distance(waterIntersection.position.xz, camera.position.xz) - MinFadeDistance)/MaxFadeDistance, 0.0, 1.0);
            objectColor = mix(objectColor, skyColor, vec3(distanceFromCamera)); // This causes the water to fade into the horizon.
        }

		accumulatedColor += objectColor * significance;
		accumulatedSignificance += significance;
	}
	
	accumulatedColor /= accumulatedSignificance;
	accumulatedColor = pow(accumulatedColor, vec3(1.0/2.2)); // Gamma correction
	fragColor = vec4(accumulatedColor, 1.0);
}