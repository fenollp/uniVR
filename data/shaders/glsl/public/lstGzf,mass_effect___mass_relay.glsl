// Shader downloaded from https://www.shadertoy.com/view/lstGzf
// written by shadertoy user AxleMike
//
// Name: Mass Effect - Mass Relay
// Description: Messing around with distance fields and trying to create a volumetric effect.
// Alexander Lemke, 2016

//////////////////////////////////////////////////
// Settings
#define     NUMBER_OF_STEPS         50
#define     SHOW_ITERATION_COUNT    0
#define     SHOW_ALBEDO             0
#define     SHOW_NORMALS            0

//////////////////////////////////////////////////
// Constants
const float     MAX_DISTANCE    = 35.0;
const float     EPSILON         = 0.001;
const float     PI              = 3.14159265359;

//////////////////////////////////////////////////
// Helpers
float Saturate(in float f)
{
    return clamp(f, 0.0, 1.0);
}

vec3 Saturate(in vec3 v)
{
    return clamp(v, 0.0, 1.0);
}

float Hash(in vec2 p)
{
    return -1.0 + 2.0 * fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 Hash2D(in vec2 p)
{
    return -1.0 + 2.0 * vec2(fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453), fract(sin(dot(p, vec2(37.271, 377.632))) * 43758.5453));
}

float Noise(in vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(Hash(n), Hash(n + vec2(1.0, 0.0)), u.x),
               mix(Hash(n + vec2(0.0, 1.0)), Hash(n + vec2(1.0)), u.x), u.y);
}

//////////////////////////////////////////////////////
// 3D noise and Voronio from https://www.shadertoy.com/view/4sfGzS and https://www.shadertoy.com/view/ldl3W8
float Noise(in vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    
    vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;
    vec2 rg = texture2D(iChannel0, (uv + 0.5) / 256.0, -100.0).yx;
    return mix(rg.x, rg.y, f.z);
}

vec3 Voronoi(in vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);

    vec2 mg, mr;

    float md = 8.0;
    for(int j = -1; j <= 1; ++j)
    {
        for(int i = -1; i <= 1; ++i)
        {
            vec2 g = vec2(float(i), float(j));
            vec2 o = Hash2D(n + g);

            vec2 r = g + o - f;
            float d = dot(r, r);

            if(d < md)
            {
                md = d;
                mr = r;
                mg = g;
            }
        }
    }
    return vec3(md, mr);
}

//////////////////////////////////////////////////////
// smin from http://iquilezles.org/www/articles/smin/smin.htm
// polynomial smooth min (k = 0.1);
float smin(in float a, in float b, in float k)
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

mat3 Create3x3RotationMatrix(in vec3 axis, in float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,          oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,          oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
}

float LengthN(in vec3 v, in float n)
{
    float inverseN = 1.0 / n; 
    v = abs(v);
    return pow(pow(v.x, n) + pow(v.y, n) + pow(v.z, n), inverseN);
}

float LengthN(in vec2 v, in float n)
{
    float inverseN = 1.0 / n; 
    v = abs(v);
    return pow(pow(v.x, n) + pow(v.y, n), inverseN);
}
    
//////////////////////////////////////////////////////
// Intersection Helpers
struct IntersectionData
{
    float       mT;
    float       mMaterialIndex;
};
    
IntersectionData GetClosestIntersection(in IntersectionData a, in IntersectionData b)
{
    if(a.mT < b.mT)
    {
        return a;
    }
    return b;
}

struct Ray
{
    vec3    mPosition;
    vec3    mDirection;
}; 

//////////////////////////////////////////////////////
// Basic Distance Field Tests
// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdBox(in vec3 p, in vec3 boxSize)
{
  vec3 d = abs(p) - boxSize;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float sdCylinder(in vec3 p, in vec3 cylinderDimensions)
{
  return length(p.xz - cylinderDimensions.xy) - cylinderDimensions.z;
}

float sdSphere(in vec3 p, in float radius)
{
    return length(p) - radius;
}

float sdPipe(in vec3 p, in vec3 cylinderPosition, in vec2 cylinderDimensions)
{
    vec2 d = abs(vec2(length(p.yz + cylinderPosition.yz), p.x + cylinderPosition.x)) - cylinderDimensions;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdVerticalPipe(in vec3 p, in vec3 cylinderPosition, in vec2 cylinderDimensions)
{
    vec2 d = abs(vec2(length(p.xz + cylinderPosition.xz), p.y + cylinderPosition.y)) - cylinderDimensions;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdTorus(in vec3 p, in vec3 torusPosition, in vec2 torusDimensions)
{
    vec2 q = vec2(length(p.xy + torusPosition.xy) - torusDimensions.x, p.z + torusPosition.z);
    return length(q) - torusDimensions.y;
}

float sdTorus82(in vec3 p, in vec3 torusPosition, in vec2 torusDimensions)
{
    vec2 q = vec2(LengthN(p.xy + torusPosition.xy, 2.0) - torusDimensions.x, p.z + torusPosition.z);
    return LengthN(q, 8.0) - torusDimensions.y;
}

float sdTorus42(in vec3 p, in vec3 torusPosition, in vec2 torusDimensions)
{
    vec2 q = vec2(LengthN(p.xy + torusPosition.xy, 2.0) - torusDimensions.x, p.z + torusPosition.z);
    return LengthN(q, 4.0) - torusDimensions.y;
}

float Capsule(in vec3 p, in vec3 pointA, in vec3 pointB, in float radius)
{
    vec3 lineBA = pointB - pointA;
    vec3 linePA = p - pointA;
    float rate = min(max(dot(lineBA, linePA), 0.0) / dot(lineBA, lineBA), 1.0);
    return length(p - (pointA + rate * lineBA)) - radius; 
}

//////////////////////////////////////////////////////
// Scene Elements
vec3 gMassRelayPosition = vec3(1.0, 3.0, 0.0);

IntersectionData CheckMassRelay(in vec3 p)
{
    IntersectionData intersectionData = IntersectionData(MAX_DISTANCE, 1.0);
    
    float intersectionT = sdTorus(p, gMassRelayPosition, vec2(4.5, 0.85));
    intersectionData.mT = intersectionT;

    // Back
    intersectionT = sdBox(p - vec3(7.5, 0.0, 0.0) + gMassRelayPosition, vec3(2.0, 1.8, 0.65));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 3.5);
  
    // rear modifications
    intersectionT = sdBox(p - vec3(10.0, -0.5, 0.0) + gMassRelayPosition, vec3(1.0, 0.5, 3.0));
    intersectionData.mT = max(intersectionData.mT, -intersectionT);
    intersectionT = sdBox(p - vec3(10.0, 1.05, 0.0) + gMassRelayPosition, vec3(1.85, 0.25, 3.0));
    intersectionData.mT = max(intersectionData.mT, -intersectionT);
    
    // top beam
    intersectionT = sdPipe(p, vec3(11.0, -1.5, 0.0) + gMassRelayPosition, vec2(0.8, 7.0));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.8);    
    intersectionT = sdPipe(p, vec3(8.0, -1.8, 0.0) + gMassRelayPosition, vec2(0.8, 3.5));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.8);    
    
    // bottom beam
    intersectionT = sdPipe(p, vec3(11.0, 1.5, 0.0) + gMassRelayPosition, vec2(0.8, 7.0));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.8);
        
    // center hole
    intersectionT = sdBox(p - vec3(-12.0, 0.0, 0.0) + gMassRelayPosition, vec3(10.0, 1.0, 3.0));
    intersectionData.mT = max(intersectionData.mT, -intersectionT);
       
    // rail modifications
    intersectionT = sdBox(p - vec3(-18.0, -2.25, 0.0) + gMassRelayPosition, vec3(1.0, 1.0, 1.0));
    intersectionData.mT = max(intersectionData.mT, -intersectionT);
    intersectionT = sdBox(p - vec3(-18.0, 2.25, 0.0) + gMassRelayPosition, vec3(1.0, 1.0, 1.0));
    intersectionData.mT = max(intersectionData.mT, -intersectionT);
    
    return intersectionData;
}

IntersectionData CheckMassRelayRing(in vec3 p)
{
    IntersectionData intersectionData = IntersectionData(MAX_DISTANCE, 2.0);
    
    // Ring 1
    mat3 rotationMatrix0 = Create3x3RotationMatrix(vec3(0.0, 1.0, 0.0), PI * 0.60 * iGlobalTime);
    vec3 q0 = rotationMatrix0 * (p + gMassRelayPosition);
    float intersectionT = sdTorus42(q0, vec3(0.0), vec2(3.0, 0.2));
    intersectionData.mT = intersectionT;
    
    mat3 rotationMatrix1 = Create3x3RotationMatrix(vec3(0.0, 1.0, 0.0), PI * 0.60 * iGlobalTime);
    mat3 rotationMatrix2 = Create3x3RotationMatrix(vec3(1.0, 0.0, 0.0), PI * 0.80 * iGlobalTime);
    vec3 q = rotationMatrix2 * (rotationMatrix1 * (p + gMassRelayPosition));
    intersectionT = sdTorus42(q, vec3(0.0), vec2(2.5, 0.15));
    intersectionData.mT = min(intersectionData.mT, intersectionT);
    
    return intersectionData;
}

IntersectionData CheckAntennas(in vec3 p)
{
    IntersectionData intersectionData = IntersectionData(MAX_DISTANCE, 3.0);
    
    // Left Attennas
    float intersectionT = sdPipe(p, vec3(11.0, -2.4, -0.35) + gMassRelayPosition, vec2(0.07, 2.5));
    intersectionData.mT = intersectionT;  
    intersectionT = sdVerticalPipe(p, vec3(1.4, -6.8, 0.0) + gMassRelayPosition, vec2(0.2, 3.1));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);
    intersectionT = sdVerticalPipe(p, vec3(1.9, -6.8, 0.0) + gMassRelayPosition, vec2(0.08, 3.6));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);    
    intersectionT = sdVerticalPipe(p, vec3(0.9, -6.8, 0.0) + gMassRelayPosition, vec2(0.1, 3.1));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1); 
    intersectionT = sdVerticalPipe(p, vec3(0.6, -6.8, 0.0) + gMassRelayPosition, vec2(0.08, 1.4));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);
    
    // Right Attennas
    intersectionT = sdVerticalPipe(p, vec3(-1.6, -6.5, 0.0) + gMassRelayPosition, vec2(0.08, 1.4));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1); 
    intersectionT = sdVerticalPipe(p, vec3(-1.6, -5.8, 0.0) + gMassRelayPosition, vec2(0.16, 0.7));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);    
    intersectionT = sdVerticalPipe(p, vec3(-2.2, -6.4, 0.0) + gMassRelayPosition, vec2(0.08, 1.5));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);    
    intersectionT = sdVerticalPipe(p, vec3(-2.2, -5.6, 0.0) + gMassRelayPosition, vec2(0.16, 0.85));
    intersectionData.mT = smin(intersectionData.mT, intersectionT, 0.1);

    return intersectionData;
}

IntersectionData CheckBolt(in vec3 p)
{
    IntersectionData intersectionData = IntersectionData(MAX_DISTANCE, 4.0);
      
    const int NUMBER_OF_BENDS = 5;
    vec2 maxBoltYValues = vec2(-1.25, 1.25); 
    float maxBoltYRange = abs(maxBoltYValues.x - maxBoltYValues.y); 
    float yIncr = maxBoltYRange / float(NUMBER_OF_BENDS);
    
    vec3 q = p + gMassRelayPosition;
    int index = int(clamp((((q.y - maxBoltYValues.x) / maxBoltYRange) * float(NUMBER_OF_BENDS)), 0.0, float(NUMBER_OF_BENDS)));

    float boltArea = mod(iGlobalTime, 15.0);
    if(boltArea < 13.0)
    {
        vec2 currentBoltYValues = vec2((maxBoltYValues.x + float(index) * yIncr), (maxBoltYValues.x + float(index + 1) * yIncr));

        vec3 randomOffsetHigh = (texture2D(iChannel0, vec2(floor(mod(iGlobalTime, 25.0) * 10.0) / 25.0, float(index) / float(NUMBER_OF_BENDS)), -100.0).xyz * 2.0 - 1.0) * vec3(0.25, 0.0, 0.25);
        if(index >= (NUMBER_OF_BENDS - 1))
        	randomOffsetHigh = vec3(0.0);
      
        vec3 randomOffsetLow = (texture2D(iChannel0, vec2(floor(mod(iGlobalTime, 25.0) * 10.0) / 25.0, max(0.0, float(index - 1)) / float(NUMBER_OF_BENDS)), -100.0).xyz * 2.0 - 1.0) * vec3(0.25, 0.0, 0.25);

        intersectionData.mT = Capsule(q, vec3(-4.0 - boltArea, currentBoltYValues.x, 0.0) + randomOffsetLow,
                                      vec3(-4.0 - boltArea, currentBoltYValues.y, 0.0) + randomOffsetHigh, 0.05);
    }
    return intersectionData;
}

IntersectionData CheckSceneForIntersection(in vec3 p)
{
    IntersectionData massRelayIntersection = CheckMassRelay(p);
    IntersectionData antennasIntersection = CheckAntennas(p);    
    IntersectionData intersectionData = GetClosestIntersection(massRelayIntersection, antennasIntersection);   
    
    IntersectionData ringIntersectionData = CheckMassRelayRing(p);
    intersectionData = GetClosestIntersection(intersectionData, ringIntersectionData); 
    
    IntersectionData boltIntersectionData = CheckBolt(p);
    intersectionData = GetClosestIntersection(intersectionData, boltIntersectionData);
    
    return intersectionData;
}

IntersectionData Intersect(in Ray initialRay)
{    
    IntersectionData sceneIntersection = IntersectionData(MAX_DISTANCE, -1.0);
    
    float t = 0.0;   
#if SHOW_ITERATION_COUNT
    int stepsTaken = 0;
#endif // SHOW_ITERATION_COUNT
 
    for(int i = 0; i < NUMBER_OF_STEPS; ++i)
    {
        // Break out if our step size is too small or we've gone out of range
        if(sceneIntersection.mT < EPSILON || t > MAX_DISTANCE) break;
        
        Ray currentRay = Ray(initialRay.mPosition + initialRay.mDirection * t, initialRay.mDirection); // Update our ray     
        sceneIntersection = CheckSceneForIntersection(currentRay.mPosition); // Check the scene for an intersection     
        t += sceneIntersection.mT; // Step forward
        
#if SHOW_ITERATION_COUNT
        stepsTaken = i;
#endif // SHOW_ITERATION_COUNT
    }
    
#if SHOW_ITERATION_COUNT
    sceneIntersection.mT = float(stepsTaken);
#endif // SHOW_ITERATION_COUNT
    
    sceneIntersection.mT = t;
    
    return sceneIntersection;
}

void RaySphereIntersectionTest(in vec3 rayPosition, in vec3 rayDirection, in vec3 spherePosition, in float sphereRadius,
                               out vec3 intersectionNear, out vec3 intersectionFar)
{   
    float sRadiusSquared = sphereRadius * sphereRadius;
    vec3 eDistance = rayPosition - spherePosition;
    
    float b = dot(eDistance, rayDirection);
    float c = dot(eDistance, eDistance) - sRadiusSquared;
    
    if((c > 0.0 && b > 0.0) == false)
    {   
        float discriminant = (b * b) - c;
        float t0 = max(-b - sqrt(discriminant), 0.0); // clamp t0 to zero incase it started inside the sphere
        float t1 = max(-b + sqrt(discriminant), 0.0); // clamp t1 to zero incase it started inside the sphere
           
        if(discriminant >= EPSILON)
        {
            intersectionNear = rayPosition + rayDirection * t0;
            intersectionFar = rayPosition + rayDirection * t1;
       }      
    }
}

//////////////////////////////////////////////////////
// Lighting Helpers
vec3 GetNormal(in vec3 point) 
{
    IntersectionData d0 = CheckSceneForIntersection(point);
    IntersectionData dX = CheckSceneForIntersection(point - vec3(EPSILON, 0.0, 0.0));
    IntersectionData dY = CheckSceneForIntersection(point - vec3(0.0, EPSILON, 0.0));
    IntersectionData dZ = CheckSceneForIntersection(point - vec3(0.0, 0.0, EPSILON));
    return normalize(vec3(dX.mT - d0.mT, dY.mT - d0.mT, dZ.mT - d0.mT));
}

float BeckmannMicrofacetDistribution(in float NdotH, in float m)
{
    float NHSquared = NdotH * NdotH;
    float mSquared = m * m;  
    return (1.0 / mSquared * NHSquared * NHSquared) * (exp(-((1.0 - NHSquared) / (mSquared * NHSquared))));
}

float GGXDistribution(in float NdotH, in float m)
{
    // Divide by PI is applied later
    float m2 = m * m;
    float f = ( NdotH * m2 - NdotH ) * NdotH + 1.0;
    return m2 / (f * f);
}

float CookTorranceGeometricAttenuation(in float NdotH, in float NdotL, in float VdotH, in float NdotV)
{
    return (min(1.0, min((2.0 * NdotH * NdotL) / VdotH, (2.0 * NdotH * NdotV) / VdotH)));
}

float GGXSmithCorrelated(in float NdotL, in float NdotV, in float alphaG)
{
    float alphaG2 = alphaG * alphaG;
    float Lambda_GGXV = NdotL * sqrt((- NdotV * alphaG2 + NdotV) * NdotV + alphaG2);
    float Lambda_GGXL = NdotV * sqrt((- NdotL * alphaG2 + NdotL) * NdotL + alphaG2);
    return 0.5 / ( Lambda_GGXV + Lambda_GGXL );
}

float ComputeSchlickFresnel(in float NdotV, in float fresnelReflectionIndex)
{
    return fresnelReflectionIndex + (1.0 - fresnelReflectionIndex) * pow((1.0 - NdotV), 5.0);
}

//////////////////////////////////////////////////////
// Lighting
vec3 ApplyPointLight(in vec3 point, in vec3 normal, in vec3 eye, in vec3 albedo, 
                       in float roughness, in float metallic, in float reflectance, in float ambient,
                       in vec3 lightPosition, in float lightRadius, in vec3 lightColor)
{       
    vec3 lightDirection = -(lightPosition - point);

    // Apply lighting
    float lightDistance = length(lightDirection);
    lightDirection = normalize(lightDirection);
    float attenutation = Saturate(1.0 - lightDistance / lightRadius); 
    attenutation *= attenutation;
    
    // Determine some values
    vec3 viewVector = normalize(eye - point);
    vec3 halfVector = normalize(lightDirection + viewVector);

    float NdotL = Saturate(dot(normal, lightDirection));
    float NdotH = Saturate(dot(normal, halfVector));
    float NdotV = Saturate(dot(normal, viewVector));
    float VdotH = Saturate(dot(viewVector, halfVector));
    float HdotL = Saturate(dot(halfVector, lightDirection));

    vec3 diffuse = (1.0 - metallic) * albedo;

    // Cook Torence
    float f0 = 0.16 * (reflectance * reflectance);
    float fresnel = ComputeSchlickFresnel(NdotV, f0);    

    float Vis = GGXSmithCorrelated(NdotV, NdotL, roughness);
    float geometricAttenuation = CookTorranceGeometricAttenuation(NdotH, NdotL, VdotH, NdotV);
    float microfacets = GGXDistribution(NdotH, roughness);

    float specular = (fresnel * microfacets * Vis) / PI;

    return ((NdotL * Saturate(1.5 * ((0.7 * NdotL * diffuse + specular))))) * lightColor * attenutation;         
}

vec3 CalculateLighting(in vec3 point, in vec3 normal, in vec3 eye, in vec3 albedo, 
                       in float roughness, in float metallic, in float reflectance, in float ambient)
{       
    vec3 lighting = ApplyPointLight(point, normal, eye, albedo, roughness, metallic, reflectance,
                               0.5, -gMassRelayPosition, 60.0, vec3(0.5, 0.5, 1.0));
    
    // Apply lighting from moving bolt
    float boltArea = mod(iGlobalTime, 15.0);
    if(boltArea < 13.0)
    {
        lighting += ApplyPointLight(point, normal, eye, albedo, roughness, metallic, reflectance,
                               0.5, -gMassRelayPosition + vec3(-4.0 - boltArea, 0.0, 0.0), 8.0, vec3(0.5, 0.5, 1.0));
    }
    return lighting + (albedo * ambient);
}

//////////////////////////////////////////////////////
// Background
vec3 ApplyFog(in vec3 texCoord)
{
    vec3 samplePosition = 8.0 * texCoord.xyz;
    
    float fogAmount = Noise(samplePosition);
    fogAmount += Noise(samplePosition * 3.01) * 0.5;
    fogAmount += Noise(samplePosition * 3.02) * 0.25;
    fogAmount += Noise(samplePosition * 3.03) * 0.125;
    fogAmount += Noise(samplePosition * 3.01) * 0.0625;
    
    vec3 fogColor = vec3(texCoord.xyz + vec3(0.5, 0.0, 0.5))  * 0.1;
    return (fogColor * fogAmount * vec3(0.75));  
}

vec3 AddStarField(in vec2 p, in float threshold)
{
    vec3 starValue = Voronoi(p);
    if(starValue.x < threshold)
    {
        float power = 1.0 - (starValue.x / threshold);
        return vec3(power * power * 0.5);
    }
    return vec3(0.0);
}

//////////////////////////////////////////////////////
// Implementation
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Adjust UVs for for the resolution so our world goes from [-1,-1] to [1,1]
    vec2 screenCoord = (fragCoord.xy / iResolution.xy);
    vec2 aspectRatioAdjustedUVs = vec2((screenCoord.x * 2.0 - 1.0) * (iResolution.x / iResolution.y), (screenCoord.y * 2.0 - 1.0));
    
    float xRotationValue = (iMouse.z > 0.0) ? (iMouse.y / iResolution.y - 0.5) * (PI * 0.5) : 0.0;
    mat3 xRotationMatrix = Create3x3RotationMatrix(vec3(1.0, 0.0, 0.0), xRotationValue);
    float yRotationValue = (iMouse.z > 0.0) ? (iMouse.x / iResolution.x) * (PI * 2.0) : (iGlobalTime * PI) * 0.05; // Multiply by 0.1 to slow down the rotation ;   
    mat3 yRotationMatrix = Create3x3RotationMatrix(vec3(0.0, -1.0, 0.0), yRotationValue);

    // Determine our camera info
    const float distanceFromOrigin = 13.0;
    vec3 cameraPosition = vec3(distanceFromOrigin * sin(yRotationValue) * cos(xRotationValue), distanceFromOrigin * sin(xRotationValue), distanceFromOrigin * cos(yRotationValue) * cos(xRotationValue));
    vec3 cameraDirection = yRotationMatrix * xRotationMatrix * normalize(vec3(aspectRatioAdjustedUVs, -1.0));
    Ray cameraRay = Ray(cameraPosition, cameraDirection);
    
    // Gets the intersection point from the camera ray to camera facing plane that the core is on
    vec3 directionToCore = -normalize(gMassRelayPosition - cameraPosition);
    vec3 coreIntersectionNear = vec3(MAX_DISTANCE);
    vec3 coreIntersectionFar = vec3(MAX_DISTANCE);
    
    const float coreVolumeRadius = 8.0;
    const float solidCoreRadius = 1.25;
    RaySphereIntersectionTest(cameraPosition, cameraDirection, -gMassRelayPosition, coreVolumeRadius, coreIntersectionNear, coreIntersectionFar);
      
    vec3 finalColor = vec3(0.0);

    IntersectionData intersection = Intersect(cameraRay);        
    if(intersection.mT < MAX_DISTANCE)
    {   
        vec3 intersectionPoint = (cameraRay.mPosition + cameraRay.mDirection * intersection.mT);
        vec3 normal = GetNormal(intersectionPoint);

        vec3 diffuse = vec3(1.0);
        float roughness = 0.9;
        float metallic = 1.0;
        float reflectance = 0.2;
        float ambient = 0.2;
        
        if(intersection.mMaterialIndex == 1.0)
        {
            // I'm sure theres a better way to do this
            vec2 texCoords = intersectionPoint.xy;
            if(abs(dot(normal, vec3(1.0, 0.0, 0.0))) > 0.8)
                texCoords =  intersectionPoint.zy;  
            else if(abs(dot(normal, vec3(0.0, 1.0, 0.0))) > 0.8)
                texCoords =  intersectionPoint.xz;

            vec3 textureColor = texture2D(iChannel1, texCoords * 0.125).rgb;
            diffuse = vec3(0.3, 0.3, 0.4);  
            
            if(textureColor.r < 0.4)
            {
                ambient = 1.0;
                diffuse = vec3(1.0);
            }  
        }
        else if(intersection.mMaterialIndex == 2.0 || intersection.mMaterialIndex == 3.0)  
            diffuse = vec3(0.5);               
        else if(intersection.mMaterialIndex == 4.0)
        {
            ambient = 10.0;  
            diffuse = vec3(1.0);
        }

        finalColor += CalculateLighting(intersectionPoint, normal, cameraPosition, diffuse, roughness, metallic, reflectance, ambient);         
#if SHOW_ITERATION_COUNT
        finalColor = vec3(min(intersection.mT, float(NUMBER_OF_STEPS)) / float(NUMBER_OF_STEPS), 0.0, 0.0);
#elif SHOW_ALBEDO
        finalColor = diffuse;
#elif SHOW_NORMALS
        finalColor = vec3(normal * 0.5 + 0.5); //  Modify the normal to go from [0,0] to [1,1]
#endif 
    }
    else
    {   
        // calculate the uv coords for the skybox
        vec2 starFieldCoord = vec2(atan(cameraDirection.x, cameraDirection.z) / (2.0 * PI), asin(cameraDirection.y) / PI);       
        finalColor += AddStarField(starFieldCoord * 80.0, 0.0025);
        finalColor += AddStarField(starFieldCoord * 65.0, 0.0025);
        finalColor += AddStarField(starFieldCoord * 50.0, 0.0007);       
        finalColor += ApplyFog(cameraDirection);
    }

#if !SHOW_ITERATION_COUNT && !SHOW_ALBEDO && !SHOW_NORMALS    
    float lengthToNearVol = min(length(cameraPosition - coreIntersectionNear), intersection.mT);
    float lengthToFarVol = min(length(cameraPosition - coreIntersectionFar), intersection.mT);
    float volumneTravelDistance = abs(lengthToNearVol - lengthToFarVol);
    
    if(volumneTravelDistance < coreVolumeRadius * 2.0)
    {
        vec3 volStartPoint = (cameraRay.mPosition + cameraRay.mDirection * lengthToNearVol);
        float volumeAmount = 0.0;
        
        const int numberOfSteps = 25;
        float stepSize = max(volumneTravelDistance / float(numberOfSteps), EPSILON);

        for(int i = 0; i < numberOfSteps; ++i)
        {
            vec3 currentPoint = volStartPoint + (float(i) * stepSize * cameraDirection);	   
            float distanceFromCenterCore = length(currentPoint + gMassRelayPosition);

            float blueTint = Saturate((coreVolumeRadius - distanceFromCenterCore) / coreVolumeRadius) * 2.0;
            float whiteTint = Saturate((solidCoreRadius - distanceFromCenterCore) / solidCoreRadius) * 200.0;

            if(length(currentPoint) > MAX_DISTANCE)
            {
                break;
            }

            volumeAmount += blueTint + whiteTint;        
        }
        volumeAmount /= float(numberOfSteps);
        vec3 volumeColor = mix(vec3(0.1, 0.1, 1.0), vec3(1.0), vec3(volumeAmount / 2.0));
        finalColor = mix(finalColor, volumeColor, vec3(Saturate(volumeAmount)));
    }
    finalColor *= pow(16.0 * screenCoord.x * screenCoord.y * (1.0 - screenCoord.x) * (1.0 - screenCoord.y), 0.1); // Vigneting
#endif // !SHOW_ITERATION_COUNT
    
    fragColor = vec4(finalColor, 1.0);
}

