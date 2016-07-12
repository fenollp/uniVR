// Shader downloaded from https://www.shadertoy.com/view/MllGW2
// written by shadertoy user heyx3
//
// Name: Experiment  terrain lighting
// Description: Experimenting with a new idea for lighting terrain without any extra sampling of heightmaps.
//If this token is defined, lighting will be based on the difference in height on the last march step.
//Otherwise, it will be based on the average height difference of every step,
//    with special weight placed on the later steps.
//Comment this out to use a less accurate but smoother approximation of the surface brightness.
#define USE_SIMPLER_LIGHTING


#define SAMPLE_NOISE(coords, offsetX, offsetY, scale) texture2D(iChannel0, (coords * scale) + vec2(offsetX, offsetY)).x
float getHeight(vec2 inPos)
{
    const float baseScale = 0.002;
    const float terrainHeight = 30.0;
    const float terrainHeightPullDown = 2.0;
    return terrainHeight *
              pow(//0.50 * SAMPLE_NOISE(inPos, 0.0, 0.0, baseScale * 			0.125) +
           	      0.25 * SAMPLE_NOISE(inPos, 0.253, 0.8812, baseScale *     0.25) +
                  0.125 * SAMPLE_NOISE(inPos, 0.01, 0.9999, baseScale *	    0.5) +
                  0.0625 * SAMPLE_NOISE(inPos, 0.363, 0.346346, baseScale * 1.5),
                  terrainHeightPullDown);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    
    //Cam data.
    const float camSpeed = 0.5;
    float camHorzPos = iGlobalTime * camSpeed;
    vec2 chp = vec2(camHorzPos);
    vec3 camPos = vec3(chp, getHeight(chp) + 3.0),
         camForward = normalize(vec3(1.0, 1.0, -0.5)),
         camUp = vec3(0.0, 0.0, 1.0),
         camSide = cross(camForward, camUp);
    camUp = cross(camSide, camForward);
    
    
    //Ray data.
    const float fovScale = 1.0;
    vec2 uvNormalized = -1.0 + (2.0 * uv);
    vec3 rayStart = camPos + (camForward * fovScale) +
        			(camSide * uvNormalized.x) +
        			(camUp * uvNormalized.y * (iResolution.y / iResolution.x));
    vec3 rayDir = normalize(rayStart - camPos);
    
    
    //Ray marching.
    
    #define MAX_ITERATIONS 500
    #define MAX_ITERATIONS_F float(MAX_ITERATIONS)
    #define STEP_DISTANCE 0.04
    
    float distCounter = 0.0;
    vec3 rayCounter = rayStart;
    
    //Track how much the height changes during iterations..
    //Used for approximating lighting.
    float lastHeight = 0.0;
    float heightChange = 0.0;
    
    for (int i = 0; i < MAX_ITERATIONS; ++i)
    {
        float nextHeight = getHeight(rayCounter.xy);
        
        
#ifdef USE_SIMPLER_LIGHTING
    	#define MAX_HEIGHT_CHANGE 0.03
        heightChange = nextHeight - lastHeight;
#else
    	#define MAX_HEIGHT_CHANGE 0.005
        //Values closer to the intersection with the terrain are worth more.
        #define DIST_COUNTER_IMPORTANCE 0.5
        heightChange += pow(distCounter, DIST_COUNTER_IMPORTANCE) *
            			(nextHeight - lastHeight);
#endif
        
        if (nextHeight >= rayCounter.z)
        {
            break;
        }
        
        lastHeight = nextHeight;
        
        rayCounter += (rayDir * STEP_DISTANCE);
        distCounter += STEP_DISTANCE;
    }
    
#ifndef USE_SIMPLER_LIGHTING
    heightChange /= MAX_ITERATIONS_F;
#endif
    
    
    //Calculate fog.
    #define FOG_DROPOFF 1.0
    #define FOG_COLOR vec3(1.0, 0.8, 0.3)
    float fog = pow(distCounter / (MAX_ITERATIONS_F * STEP_DISTANCE),
                    FOG_DROPOFF);
    
    //Calculate surface brightness.
    #define AMBIENT_LIGHT 0.0
    #define DIFFUSE_LIGHT (1.0 - AMBIENT_LIGHT)
    float diffuseFactor = min(heightChange, MAX_HEIGHT_CHANGE) / MAX_HEIGHT_CHANGE;
    float brightness = AMBIENT_LIGHT +
        			   (DIFFUSE_LIGHT * diffuseFactor);
    
    //Calculate surface color.
    //Choose either a flat color to accentuate the lighting stuff, or a textured color to look nicer.
    #define SURFACE_TEX_SCALE 0.25
#if 1
    vec3 surfaceColor = vec3(0.9, 0.5, 0.2) *
        				texture2D(iChannel1, rayCounter.xy * SURFACE_TEX_SCALE).xyz;
#else
    vec3 surfaceColor = vec3(0.9, 0.5, 0.2);
#endif
    
    
    //Output final color.
    fragColor = vec4(mix(surfaceColor * brightness, FOG_COLOR, fog),
                     1.0);
    
    
    //Debug coloring.
    //fragColor = vec4(getHeight(uv), 0.0, 0.0, 1.0);
    //fragColor = vec4(camForward, 1.0);
}