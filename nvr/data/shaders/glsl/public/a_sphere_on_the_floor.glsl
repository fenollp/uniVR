// Shader downloaded from https://www.shadertoy.com/view/XllSRN
// written by shadertoy user codywatts
//
// Name: A Sphere on the Floor
// Description: A raycaster which casts multiple rays per fragment in order to achieve basic antialiasing. Click and drag the mouse to move the camera.
#define PI 3.14159265359
#define TWO_PI 6.28318530718
#define X_AXIS vec3(1, 0, 0)
#define Y_AXIS vec3(0, 1, 0)
#define Z_AXIS vec3(0, 0, 1)

struct Material
{
	vec3 diffuseColor;
	vec3 specularColor;
	float shininess;
};

struct Sphere
{
	vec3 center;
	float radius;
	Material material;
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

struct Spotlight
{
	vec3 position;
	vec3 direction;
	float angle;
};

Intersection raySphereIntersection(in Ray ray, in Sphere sphere)
{
	Intersection i;
	i.hit = false;
	
	vec3 centerToOrigin = ray.origin - sphere.center;
	float dotProduct = dot(ray.direction, centerToOrigin);
	float squareRootTerm = pow(dotProduct, 2.0) - pow(length(centerToOrigin), 2.0) + pow(sphere.radius, 2.0);
	if (squareRootTerm < 0.0)
	{
		return i;
	}
	
	float distanceToHit = (-dotProduct) - sqrt(squareRootTerm);
	if (distanceToHit < 0.0)
	{
		return i;
	}
	i.position = ray.origin + (ray.direction * distanceToHit);
	i.normal = normalize(i.position - sphere.center);
	i.material = sphere.material;
	i.hit = true;
	return i;
}

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

vec3 blinnPhong(in vec3 lightPosition, in vec3 cameraPosition, in vec3 objectPosition, in vec3 objectNormal, in Material material)
{
	vec3 fromObjectToLight = normalize(lightPosition - objectPosition);
	float lambertian = dot(fromObjectToLight, objectNormal);
	float specularIntensity = 0.0;
    
    if (lambertian > 0.0) // = diffuseIntensity > 0.0
    {
        vec3 fromObjectToCamera = normalize(cameraPosition - objectPosition);
        vec3 halfwayVector = normalize(fromObjectToLight + fromObjectToCamera);
        float specTmp = max(dot(objectNormal, halfwayVector), 0.0);
        specularIntensity = pow(specTmp, material.shininess);
    }
    
    return lambertian * material.diffuseColor + specularIntensity * material.specularColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Declare constants
    const int RaysPerFragment = 5;
	const vec3 BallColorOne = vec3(1, 0, 0);
	const vec3 BallColorTwo = vec3(1, 1, 1);
	const int BallSegmentCount = 3;
	const float BallSegmentTransitionFactor = 0.05;
	const float DistanceFromBall = 50.0;
	const float PlaneTextureSize = 12.0;
	const float SpotlightSoftness = 0.2;
		
	// Define our sphere
	Sphere s;
	s.center = vec3(0, 0, 0);
	s.radius = 12.0;
	s.material.specularColor = vec3(0, 0, 0);
	s.material.shininess = 100.0;
	
	// Define our plane
	Plane p;
	p.point = s.center - vec3(0, s.radius, 0);
	p.normal = Y_AXIS;
	p.material.specularColor = vec3(1, 1, 1);
	p.material.shininess = 1000.0;
	
	// Define our spotlight
	Spotlight spotlight;
	spotlight.position = vec3(10.0, 20.0, 10.0);
	spotlight.direction = normalize(s.center - spotlight.position);
	spotlight.angle = PI / 5.0;
	
	// Define our camera
	Camera camera;
	float cameraRotationValue = (iMouse.xy == vec2(0) ? 0.8 * -iGlobalTime : (iMouse.x / iResolution.x) * TWO_PI);
	camera.position = s.center + vec3(cos(cameraRotationValue) * DistanceFromBall, DistanceFromBall * (1.0 - (iMouse.y / iResolution.y)), sin(cameraRotationValue) * DistanceFromBall);
	
	vec3 targetPosition = s.center;
	camera.forward = normalize(targetPosition - camera.position);
	camera.right = cross(Y_AXIS, camera.forward);
	camera.up = cross(camera.forward, camera.right);
	
	// To antialias our image, we cast multiple rays per fragment and "average" the result.
	vec3 accumulatedColor = vec3(0, 0, 0);
	float accumulatedSignificance = 0.0;
	
	for (int i = 0; i < RaysPerFragment; ++i)
	{
		float t = float(i) / float(RaysPerFragment);
		
		float significance = (1.0 - t);
		
		vec2 fragCoordOffset = vec2(cos(t * TWO_PI) * t, sin(t * TWO_PI) * t);
		vec2 uv = 2.0 * (fragCoord + fragCoordOffset) / iResolution.xy - 1.0;
		uv.x *= iResolution.x / iResolution.y;
		
		Ray r;
		r.origin = camera.position;
		r.direction = normalize(camera.forward + camera.right * uv.x + camera.up * uv.y);
		
		float percentLit = 1.0;
		
		Intersection intersection = raySphereIntersection(r, s);
		// If our ray hit the sphere...
		if (intersection.hit == true)
		{
			vec2 flattenedNormal = normalize(vec2(intersection.normal.x, intersection.normal.z));  
			float polarCoordinate = atan(flattenedNormal.y, flattenedNormal.x);
			polarCoordinate += PI; // polarCoordinate is now between (0, 2*PI)
			polarCoordinate = pow(sin(float(BallSegmentCount) * polarCoordinate), 2.0); // polarCoordinate is now between (0, 1)
			
			float smoothFactor = smoothstep(0.5 - BallSegmentTransitionFactor, 0.5 + BallSegmentTransitionFactor, polarCoordinate);
			intersection.material.diffuseColor = BallColorOne * smoothFactor + BallColorTwo * (1.0 - smoothFactor);
		}
		// If the ray didn't hit the sphere, test to see if it hits the plane.
		else
		{
			intersection = rayPlaneIntersection(r, p);
			
			if (intersection.hit == true)
			{
				vec3 fromPointToIntersection = intersection.position - p.point;
				vec2 textureCoordinates = vec2(dot(fromPointToIntersection, X_AXIS), dot(fromPointToIntersection, Z_AXIS)) * (1.0 / PlaneTextureSize);
				
				intersection.material.diffuseColor = texture2D(iChannel0, textureCoordinates).xyz;
				
				// We cast a ray from the intersection point back to the light to test whether this position lies in shadow.
				Ray shadowRay;
				shadowRay.origin = intersection.position;
				shadowRay.direction = normalize(spotlight.position - intersection.position);
				
				Intersection shadowIntersection = raySphereIntersection(shadowRay, s);
				if (shadowIntersection.hit == true)
				{
					percentLit = 0.0;
				}
			}
		}
		
		vec3 objectColor = vec3(0, 0, 0);
		
		// If the ray hit the sphere or the plane...
		if (intersection.hit == true)
		{
			if (percentLit > 0.0)
			{
				vec3 fromLightToObject = normalize(intersection.position - spotlight.position);
				float angleFromLightToObject = acos(dot(fromLightToObject, spotlight.direction));
				
				// Smoothstep softens the edges of the spotlight
				percentLit = smoothstep(-SpotlightSoftness, SpotlightSoftness, spotlight.angle - angleFromLightToObject);
				
				objectColor = blinnPhong(spotlight.position, camera.position, intersection.position, intersection.normal, intersection.material);
			}
			
			objectColor = max(objectColor * percentLit, intersection.material.diffuseColor * 0.0025);
			objectColor *= clamp((60000.0 / pow(distance(s.center, intersection.position), 2.0)), 0.0, 1.0);
		}
		
		accumulatedColor += objectColor * significance;
		accumulatedSignificance += significance;
	}
	
	accumulatedColor /= accumulatedSignificance;
	accumulatedColor = pow(accumulatedColor, vec3(1.0/2.2)); // Gamma correction
	fragColor = vec4(accumulatedColor, 1.0);
}