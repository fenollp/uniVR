// Shader downloaded from https://www.shadertoy.com/view/MdVGDV
// written by shadertoy user Takoa
//
// Name: Ray Marching Practice 3c
// Description: Quite simple one, just for practicing&lt;br/&gt;Simpler and normalized version of 3b (Disney's diffuse)&lt;br/&gt;&lt;br/&gt;3b: &lt;a href=&quot;https://www.shadertoy.com/view/lsGGR3&quot; class=&quot;regular&quot; target=&quot;_blank&quot;&gt;https://www.shadertoy.com/view/lsGGR3&lt;/a&gt;
// Sphere with simpler Disney's diffuse
// 
// http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf
//
// The diffuse is normalized according to Frostbite course notes.
//
// http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr_v2.pdf

#define PI 3.1415926
#define INV_PI 0.31830988
#define INV_GAMMA 0.45454545

#define EPSILON 0.0001

vec3 sphereColor = vec3(0.3, 0.9, 0.6);

vec3 cameraPosition = vec3(0.0, 0.0, 2.0);
vec3 cameraUp = vec3(0.0, 1.0, 0.0);
vec3 cameraLookingAt = vec3(0.0, 0.0, -100.0);

float roughness = 0.3;

float getDistanceToSphere(vec3 rayPosition, vec3 spherePosition, float radius)
{
    return length(spherePosition - rayPosition) - radius;
}

float getDistance(vec3 position)
{
    return min(
        getDistanceToSphere(position, vec3(-0.5, 0.0, 0.0), 1.0),
        getDistanceToSphere(position, vec3(0.5, 0.0, 0.0), 1.0));
}

vec3 getNormal(vec3 p)
{
    return normalize(vec3(
          getDistance(p + vec3(EPSILON, 0.0, 0.0)) - getDistance(p - vec3(EPSILON, 0.0, 0.0)),
          getDistance(p + vec3(0.0, EPSILON, 0.0)) - getDistance(p - vec3(0.0, EPSILON, 0.0)),
          getDistance(p + vec3(0.0, 0.0, EPSILON)) - getDistance(p - vec3(0.0, 0.0, EPSILON))
        ));
}

vec3 getRayDirection(vec2 screenPosition, vec3 origin, vec3 lookingAt, vec3 up, float fov)
{
    vec3 d = normalize(lookingAt - origin);
    vec3 rayRight = normalize(cross(d, up));
    
    return normalize(screenPosition.x * rayRight + screenPosition.y * up + 1.0 / tan(radians(fov / 2.0)) * d);
}

float rayMarch(inout vec3 p, vec3 rayDirection)
{
    float d;
    
    for (int i = 0; i < 128; i++)
    {
        d = getDistance(p);
        p += d * rayDirection;
    }
    
    return d;
}

vec3 pow(vec3 color, float g)
{
    return vec3(pow(color.x, g), pow(color.y, g), pow(color.z, g));
}

float getSchlicksApproximation(float f)
{
    float g = clamp(1.0 - f, 0.0, 1.0);
    float g2 = g * g;
    
    return g2 * g2 * g;
}

vec3 getDisneysReflectance(
    vec3 normal,
    vec3 lightDirection,
    vec3 viewDirection,
    vec3 baseColor,
    float roughness)
{
    float cosL = dot(normal, lightDirection);
    
    if (cosL < 0.0)
        return vec3(0.0);
    
    float cosV = dot(normal, viewDirection);
    float cosD = dot(lightDirection, normalize(lightDirection + viewDirection));
    float fl = getSchlicksApproximation(cosL);
    float fv = getSchlicksApproximation(cosV);
    float fD90M1 = mix(-1.0, -0.5, roughness) + 2.0 * cosD * cosD * roughness;
    float fD = (1.0 + fD90M1 * fl) * (1.0 + fD90M1 * fv) * mix(1.0, 0.66225165, roughness);
    
    return baseColor * INV_PI * fD * cosL;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 position = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 lightPosition = vec3(10.0 * cos(iGlobalTime), 10.0, 10.0 * sin(iGlobalTime));
    vec3 rayDirection = getRayDirection(position, cameraPosition, cameraLookingAt, cameraUp, 90.0);
    vec3 p = cameraPosition;
    float d = rayMarch(p, rayDirection);
    
    if (d < EPSILON)
    {
        vec3 normal = getNormal(p);
        vec3 lightDirection = normalize(lightPosition - p);
        vec3 diffuse = getDisneysReflectance(
            normal,
            lightDirection,
            -rayDirection,
            sphereColor,
            roughness
		);
        
        fragColor = vec4(pow(diffuse, INV_GAMMA), 1.0);
    }
    else
    {
        fragColor = vec4(0.2, 0.2, 0.2, 1.0);
    }
}
