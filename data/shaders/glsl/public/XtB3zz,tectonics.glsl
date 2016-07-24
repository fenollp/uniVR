// Shader downloaded from https://www.shadertoy.com/view/XtB3zz
// written by shadertoy user leon
//
// Name: Tectonics
// Description: Evolving planet with rising and falling buildings.
//    
// <3 Shadertoy

#define PI 3.141592653589

// Raymarching
const float rayEpsilon = 0.0001;
const float rayMin = 0.1;
const float rayMax = 100.0;
const int rayCount = 64;

// Camera
vec3 eye = vec3(0.01, 0.01, -1.125);
vec3 front = vec3(0.01, 0.01, 0.4);
vec3 right = vec3(1.0, 0.0, 0.0);
vec3 up = vec3(0.0, 1.0, 0.0);

// Animation
vec2 uvScale = vec2(1);
float terrainHeight = 0.09;
float sphereRadius = 0.96;
float translationSpeed = 0.1;
float rotationSpeed = 0.25;
float orbitSpeed = 0.2;

// Heights
float deepWater = .1;
float water = .4;
float ground = .5;
float grass = .6;
float moutain = .9;
float buildingTreshold = 0.6;
float buildingMargin = 0.04;
float buildingHeight = 0.06;
vec3 buildingSize = vec3(0.01, 0.01, 0.1);

// Colors
vec3 skyColor = vec3(0.05, 0, 0);
vec3 shadowColor = vec3(0.1, 0, 0);
vec3 waterColor = vec3(0.6, 0.7, .9);
vec3 groundColor = vec3(.7, .7, .6);
vec3 grassColor = vec3(.6, .65, .1);
vec3 mountainColor = vec3(.8);
vec3 cloudColor = vec3(.99);
vec3 buildingColor = vec3(.7);

vec3 rotateY(vec3 v, float t)
{
    float cost = cos(t); float sint = sin(t);
    return vec3(v.x * cost + v.z * sint, v.y, -v.x * sint + v.z * cost);
}
vec3 rotateX(vec3 v, float t)
{
    float cost = cos(t); float sint = sin(t);
    return vec3(v.x, v.y * cost - v.z * sint, v.y * sint + v.z * cost);
}

float box( vec3 p, vec3 b ) { return length(max(abs(p)-b,0.0)); }

float sphere( vec3 p, float s ) { return length(p)-s; }
vec3 repeat( vec3 p, float c ) { return mod(p, c)-.5*c; }
float inter( float d1, float d2 ) { return max(d1, d2); }
float sub( float d1, float d2 ) { return max(-d1, d2); }
float add( float d1, float d2 ) { return min(d1, d2); }

float posterize( float p, float details ) { return floor(p * details) / details; }
float reflectance(vec3 a, vec3 b) { return dot(normalize(a), normalize(b)); }
vec2 kaelidoGrid(vec2 p) { return vec2(step(mod(p, 2.0), vec2(1.0))); }

float grid(vec2 uv, float thickness, float cellSize) { return min(1., step(mod(uv.x, cellSize), thickness) + step(mod(uv.y, cellSize), thickness)); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // Ray from UV
	vec2 uv = fragCoord.xy * 2.0 / iResolution.xy - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    vec3 ray = normalize(front + right * uv.x + up * uv.y);
    
    // Color    
    vec3 color = skyColor;
    
    // Animation
    float translationTime = iGlobalTime * translationSpeed;
    float rotationTime = iGlobalTime * rotationSpeed;
    float orbitTime = iGlobalTime * orbitSpeed;
    
    // Raymarching
    float t = 0.0;
    for (int r = 0; r < rayCount; ++r)
    {
        // Ray Position
        vec3 p = eye + ray * t;
        vec3 originP = p;
        float d;
        
        // Transformations
       	p = rotateX(p, PI / 2.0);
        
        // Sphere UV
        vec3 n = normalize(p);
        float angleXZ = atan(n.z, n.x) / PI;
        float angleXY = atan(n.y, n.x) / PI;
       	float refl = reflectance(p, eye) / PI;
        
        vec2 sphereP = vec2(angleXY, refl);
        vec2 sP1 = sphereP * uvScale - rotationSpeed * vec2(cos(translationTime), sin(translationTime));
        vec2 sP2 = sphereP * uvScale + rotationSpeed * vec2(cos(translationTime + .5), sin(translationTime + .5));

        vec2 uv1 = mod(mix(sP1, 1.0 - sP1, kaelidoGrid(sP1)), 1.0);
        vec2 uv2 = mod(mix(sP2, 1.0 - sP2, kaelidoGrid(sP2)), 1.0);
        
        // Texture
        vec3 texture1 = texture2D(iChannel0, uv1).rgb;
        vec3 texture2 = 1.0 - texture2D(iChannel0, uv2).rgb;
        vec3 texture3 = texture2D(iChannel1, sphereP).rgb;
        
        // Height from luminance
        float luminance1 = (texture1.r + texture1.g + texture1.b) / 3.0;
        float luminance2 = (texture2.r + texture2.g + texture2.b) / 3.0;
        float luminance3 = (texture3.r + texture3.g + texture3.b) / 3.0;
        float l = (luminance1 + luminance2) / 2.0;
        
        // Displacement
        p += normalize(p) * -terrainHeight * l;
        float planet = sphere(p, sphereRadius);
        
        p = repeat(originP, buildingMargin);
        float building = box(p, buildingSize);
        float canBuild = smoothstep(ground, grass, l);
        building = inter(building, sphere(originP, sphereRadius + canBuild * (buildingHeight + 0.02*posterize(luminance3, 16.0))));
        
        d = add(planet, building);
        
        // Distance min or max reached
        if (d < rayEpsilon || t > rayMax)
        {
            // planet
            color = mix(skyColor, waterColor, smoothstep(deepWater, water, l));
            color = mix(color, groundColor, smoothstep(water, ground, l));
            color = mix(color, grassColor, smoothstep(ground, grass, l));
            color = mix(color, mountainColor, smoothstep(grass, moutain, l));
            
            // building
            color = mix(color, buildingColor, step(building, d));
        		
            // Shadow from ray count
            color = mix(color, shadowColor, float(r) / float(rayCount));
            
            // Sky color from distance
            color = mix(color, skyColor, smoothstep(rayMin, rayMax, t));
                            
            break;
        }
        
        // Distance field step
        t += d;
    }
    
    // Hop
	fragColor = vec4(color, 1);
}