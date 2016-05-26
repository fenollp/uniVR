// Shader downloaded from https://www.shadertoy.com/view/MlsGDS
// written by shadertoy user heyx3
//
// Name: Water3D
// Description: Raymarched water.
#define WATER_HEIGHT 7.0
#define CAM_HEIGHT_MIN 8.0
#define CAM_HEIGHT_MAX 12.0

#define MARCH_ITERATIONS 250

#define MARCH_STEP_DIST 0.02
#define MARCH_STEP_DIST_INCREMENT 0.00075

//Fog stuff.
#define MARCH_MAX_DIST 25.0
#define FOG_DROPOFF_EXPONENT 1.0

//Used for computing normals.
#define HEIGHTMAP_EPSILON 0.005
 
#define FOG_COLOR vec3(0.6)
#define WATER_COLOR vec3(0.1, 0.2, 1.0)

vec3 LIGHT_DIR = normalize(vec3(-1.0, -1.0, -1.0));
#define AMBIENT_LIGHT 0.6
#define DIFFUSE_LIGHT (1.0 - AMBIENT_LIGHT)
#define SPECULAR_LIGHT 0.5
#define SPECULAR_INTENSITY 4.0

#define FLOOR_DEPTH -6.0
#define FLOOR_TEX_SCALE 0.08

#define WATER_TRANSPARENCY 0.65



//Returns noise from 0 to 1.
float noiseBasic(float seed)
{
    return fract(sin(seed * -34.0514) * 707.13618);
}

//Returns a randomized, normalized gradient vector that shifts over time.
vec2 noiseGradient(vec2 seed, float timeScale)
{
    float noise1 = noiseBasic(seed.x * seed.y);
    vec2 noised = vec2(noise1, noiseBasic(noise1));
    
    //Change the noise based on elapsed time.
    //The first few seconds of water look weird, so skip them.
    float time = iGlobalTime + 2.0;
    return sin(timeScale * time * noised);
}


//Returns smooth Perlin noise shifting over time.
float noiseSmooth(vec2 seedPos, vec2 gridInterval, float timeScale)
{
    seedPos *= gridInterval;
    
    vec2 fracPart = fract(seedPos),
         lessPos = floor(seedPos),
         morePos = ceil(seedPos);
         
    
    vec2 minXMaxY = vec2(lessPos.x, morePos.y),
         maxXMinY = vec2(morePos.x, lessPos.y);
    
    vec2 minXYGradient = noiseGradient(lessPos, timeScale),
         maxXYGradient = noiseGradient(morePos, timeScale),
         minXMaxYGradient = noiseGradient(minXMaxY, timeScale),
         maxXMinYGradient = noiseGradient(maxXMinY, timeScale);
    
    float minXYDot = dot(minXYGradient, seedPos - lessPos),
          maxXYDot = dot(maxXYGradient, seedPos - morePos),
          minXMaxYDot = dot(minXMaxYGradient, seedPos - minXMaxY),
          maxXMinYDot = dot(maxXMinYGradient, seedPos - maxXMinY);
    
    float val = mix(mix(minXYDot, maxXMinYDot,
                        smoothstep(0.0, 1.0, fracPart.x)),
                    mix(minXMaxYDot, maxXYDot,
                        smoothstep(0.0, 1.0, fracPart.x)),
                    smoothstep(0.0, 1.0, fracPart.y));
    return smoothstep(0.0, 1.0, 0.5 + (0.5 * val));
}

float getHeightmap(vec2 inPos)
{
    float noise = 0.0;
    
#define ADD_INTERVAL(weight, offset, 		     scale, 	 timeScale) noise += weight * noiseSmooth(inPos + offset, scale, timeScale);
    ADD_INTERVAL(	 1.0,    vec2(0.0, 0.0),   	 vec2(0.025), 1.5)
    ADD_INTERVAL(	 0.016,    vec2(9.1, -5.2611), vec2(0.5),  5.0)
    ADD_INTERVAL(    0.005,   vec2(-5.51, 0.1812),vec2(2.5),  12.0)
        
    return noise * WATER_HEIGHT;
}

vec3 getHeightmapNormal(vec2 inPos)
{
    vec3 pos = vec3(inPos, getHeightmap(inPos));
    vec2 moreX_2 = vec2(inPos.x + HEIGHTMAP_EPSILON, inPos.y),
         moreY_2 = vec2(inPos.x, inPos.y + HEIGHTMAP_EPSILON);
    vec3 moreX = vec3(moreX_2, getHeightmap(moreX_2));
    vec3 moreY = vec3(moreY_2, getHeightmap(moreY_2));
    
    return cross(normalize(moreY - pos),
                 normalize(moreX - pos));
}

struct HitData
{
    vec3 pos;
    float dist;
};
HitData marchRay(vec3 startPos, vec3 dir)
{
    HitData hitDat;
    hitDat.pos = startPos;
    hitDat.dist = 0.0;
    
    float distStep = MARCH_STEP_DIST;
    
    for (int i = 0; i < MARCH_ITERATIONS; ++i)
    {
        float height = getHeightmap(hitDat.pos.xy);
        if (height >= hitDat.pos.z)
        {
            break;
        }
        
        hitDat.pos += dir * distStep;
        hitDat.dist += distStep;
        
        distStep += MARCH_STEP_DIST_INCREMENT;
    }
    
    return hitDat;
}


float getBrightness(vec3 camPos, vec3 surfacePos, vec3 surfaceNormal)
{
    float dotted = max(dot(surfaceNormal, LIGHT_DIR), 0.0);
    
    vec3 fragToEye = normalize(camPos - surfacePos);
    vec3 lightReflect = normalize(reflect(LIGHT_DIR, surfaceNormal));
    
    float specFactor = max(0.0, dot(fragToEye, lightReflect));
    specFactor = pow(specFactor, SPECULAR_INTENSITY);
    
    return AMBIENT_LIGHT + (dotted * DIFFUSE_LIGHT) +
           (specFactor * SPECULAR_LIGHT);
}


//Gets the color of the floor below the water.
vec3 getWaterRefractColor(vec3 rayDir, vec3 waterPos, vec3 waterSurfaceNormal)
{
    //Refract the ray downward.
	rayDir = -normalize(refract(rayDir, waterSurfaceNormal, 1.0 / 1.333));
    
    //Trace downwards until the floor is hit.
    float t = (FLOOR_DEPTH - waterPos.z) / rayDir.z;
    vec2 horizontalPos = waterPos.xy + (t * rayDir.xy);
    
    //Sample the texture at that floor.
    return texture2D(iChannel0, horizontalPos * FLOOR_TEX_SCALE).xyz;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    
    //Compute the camera positioning stuff.
    vec3 camPos = vec3(0.0);
	camPos.xy += iGlobalTime * 2.0;
    camPos.z = mix(CAM_HEIGHT_MIN, CAM_HEIGHT_MAX,
                   0.5 + (0.5 * sin(iGlobalTime * 0.5)));
    vec3 camForward = normalize(vec3(cos(0.005 * iMouse.x),
                                     sin(0.005 * iMouse.x),
                                     -0.5));
    vec3 camUpwards = vec3(0.0, 0.0, 1.0);
    vec3 camSideways = cross(camForward, camUpwards);
    camUpwards = -cross(camForward, camSideways);
    
    //Compute the ray-march data.
    const float camToViewPlaneDist = 1.0;
    vec2 uvRemapped = (-1.0 + (2.0 * uv));
    vec3 rayStart = camPos + (camForward * camToViewPlaneDist);
    rayStart += (uvRemapped.x * camSideways) +
                (uvRemapped.y * camUpwards * iResolution.y / iResolution.x);
    vec3 rayDir = normalize(rayStart - camPos);

    //March the ray forward until the heightmap is hit.
    HitData waterHit = marchRay(rayStart, rayDir);
    vec3 normal = getHeightmapNormal(waterHit.pos.xy);

    //Compute the water surface's brightness.
    float brightness = getBrightness(camPos, waterHit.pos, normal);
    
    //Compute the color of the water surface.
    vec3 waterColor = mix(WATER_COLOR,
                          getWaterRefractColor(rayDir, waterHit.pos, normal),
                          WATER_TRANSPARENCY);
    waterColor *= brightness;
	
    
    //Mix in some fog.
    vec3 final = mix(waterColor,
                     FOG_COLOR,
                     clamp(0.0, 1.0,
                           pow(waterHit.dist / MARCH_MAX_DIST,
                         	   FOG_DROPOFF_EXPONENT)));
    
    //Output the final color.
    fragColor = vec4(final, 1.0);
    
    
    //Below are some debug shader outputs
    //   that were used for testing various things.
    
    //uv *= 5.0;
    
    //float noise = getHeightmap(uv);
    //fragColor = vec4(noise, noise, noise, 1.0);
    
    //vec3 norm = getHeightmapNormal(uv);
    //fragColor = vec4(0.5 + (0.5 * -norm), 1.0);
    
    //vec3 refrct = getWaterRefractColor(rayDir, waterHit.pos, normal);
    //fragColor = vec4(refrct, 1.0);
}