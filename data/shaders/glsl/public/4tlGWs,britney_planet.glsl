// Shader downloaded from https://www.shadertoy.com/view/4tlGWs
// written by shadertoy user leon
//
// Name: Britney Planet
// Description: Learning raymarching distance fields with experiments
// <3 Shadertoy
// thank to @uint9 -> http://9bitscience.blogspot.fr/2013/07/raymarching-distance-fields_14.html

#define PI 3.141592653589

// Raymarching
const float rayEpsilon = 0.001;
const float rayMin = 0.1;
const float rayMax = 10.0;
const int rayCount = 24;

// Camera
vec3 eye = vec3(0, 0, -1.5);
vec3 front = vec3(0, 0, 1);
vec3 right = vec3(1, 0, 0);
vec3 up = vec3(0, 1, 0);

// Animation
vec2 uvScale1 = vec2(2.0);
vec2 uvScale2 = vec2(2.0);
float terrainHeight = 0.2;
float sphereRadius = 0.9;
float translationSpeed = 0.4;
float rotationSpeed = 0.1;

// Colors
vec3 skyColor = vec3(0, 0, 0.1);
vec3 shadowColor = vec3(0.1, 0, 0);

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

float sphere( vec3 p, float s ) { return length(p)-s; }
float reflectance(vec3 a, vec3 b) { return dot(normalize(a), normalize(b)) * 0.5 + 0.5; }
vec2 kaelidoGrid(vec2 p) { return vec2(step(mod(p, 2.0), vec2(1.0))); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // Ray from UV
	vec2 uv = fragCoord.xy * 2.0 / iResolution.xy - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    vec3 ray = normalize(front + right * uv.x + up * uv.y);
    
    // Color
    vec3 color = shadowColor;
    
    // Animation
    float translationTime = iGlobalTime * translationSpeed;
    
    // Raymarching
    float t = 0.0;
    for (int r = 0; r < rayCount; ++r)
    {
        // Ray Position
        vec3 p = eye + ray * t;
        vec3 originP = p;
        
        // Transformations
        p = rotateY(p, PI / 2.0);
       	p = rotateX(p, PI / 2.0);
        vec2 translate = vec2(0.0, translationTime);
        
        // Sphere UV
        float angleXY = atan(p.y, p.x);
        float angleXZ = atan(p.z, p.x);
        vec2 sphereP1 = vec2(angleXY / PI, 1.0 - reflectance(p, eye)) * uvScale1;
        vec2 sphereP2 = vec2(angleXY / PI, reflectance(p, eye)) * uvScale2;
        sphereP1 += 0.5;
        sphereP2 += mix(vec2(translationTime), vec2(-translationTime), 
                        vec2(step(angleXY, 0.0), step(angleXZ, 0.0)));
        vec2 uv1 = mod(mix(sphereP1, 1.0 - sphereP1, kaelidoGrid(sphereP1)), 1.0);
        vec2 uv2 = mod(mix(sphereP2, 1.0 - sphereP2, kaelidoGrid(sphereP2)), 1.0);
        
        // Texture
        vec3 texture = texture2D(iChannel0, uv1).rgb;
        vec3 texture2 = texture2D(iChannel1, uv2).rgb;
        
        // Height from luminance
        float luminance = (texture.r + texture.g + texture.b) / 3.0;
        texture = mix(texture, texture2, 1.0 - step(texture.g - texture.r - texture.b, -0.3));
        color = texture;
        luminance = (texture.r + texture.g + texture.b) / 3.0;
        
        // Displacement
        p -= normalize(p) * terrainHeight * luminance * reflectance(originP, eye);
        
        // Distance to Sphere
        float d = sphere(p, sphereRadius);
        
        // Distance min or max reached
        if (d < rayEpsilon || t > rayMax)
        {
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