// Shader downloaded from https://www.shadertoy.com/view/4sy3zG
// written by shadertoy user Takoa
//
// Name: Ray Marching Practice 2
// Description: Quite simple one, just for practicing
//    
//    Replace Lambertian BRDF with Oren-Nayar BRDF
//    
//    1: [url]https://www.shadertoy.com/view/XdK3WW[/url]
// Sphere with Oren-Nayar BRDF
// 
// Paper: http://www1.cs.columbia.edu/CAVE/publications/pdfs/Oren_SIGGRAPH94.pdf
// Ref: http://shaderjvo.blogspot.jp/2011/08/van-ouwerkerks-rewrite-of-oren-nayar.html
//
// Note: 0.33 in coefficient A has been replaced with 0.57
//       according to the footnote in the paper.

#define PI 3.141592653
#define INV_PI 0.3183098861
#define GAMMA 2.2
#define INV_GAMMA 0.4545454545

#define EPSILON 0.001

vec3 cameraPosition = vec3(0.0, 0.0, 2.0);
vec3 cameraUp = vec3(0.0, 1.0, 0.0);
vec3 cameraLookingAt = vec3(0.0, 0.0, -100.0);

float albedo = 0.9;
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

float getOrenNayarReflectance(vec3 normal, vec3 lightDirection, vec3 viewDirection, float roughness, float albedo)
{
    float roughness2 = roughness * roughness;
    float orenNayarA = 1.0 - 0.5 * roughness2 / (roughness2 + 0.57);
    float orenNayarB = 0.45 * roughness2 / (roughness2 + 0.09);
    float orenNayarL = max(0.0, dot(normal, lightDirection));
    float orenNayarV = max(0.0, dot(normal, viewDirection));
    float orenNayarP = max(0.0, dot(normalize(lightDirection - normal * orenNayarL), normalize(viewDirection - normal * orenNayarV)));
    float orenNayarL2 = orenNayarL * orenNayarL;
    float orenNayarV2 = orenNayarV * orenNayarV;
        
    return albedo * INV_PI * orenNayarL * (orenNayarA + orenNayarB * orenNayarP * sqrt((1.0 - orenNayarL2) * (1.0 - orenNayarV2)) / max(orenNayarL, orenNayarV));
}

vec3 pow(vec3 color, float g)
{
    return vec3(pow(color.x, g), pow(color.y, g), pow(color.z, g));
}

vec3 correctGamma(vec3 color, float reflectance)
{
   return pow(vec3(0.3, 0.9, 0.6) * reflectance, INV_GAMMA);
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
        float diffuse = getOrenNayarReflectance(getNormal(p), normalize(lightPosition - p), -rayDirection, roughness, albedo);
        
        fragColor = vec4(correctGamma(vec3(0.0, 1.0, 1.0), diffuse), 1.0);
    }
    else
    {
        fragColor = vec4(0.2, 0.2, 0.2, 1.0);
    }
}