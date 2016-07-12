// Shader downloaded from https://www.shadertoy.com/view/lllSR7
// written by shadertoy user janneasdf
//
// Name: Materials (Tutorial)
// Description: This shader demonstrates a way to handle shading different materials. Basically the map function returns also the material of the closest object (&quot;hitMaterial&quot;), which will be used to decide shading logic.
// Materials
const int MAT_BACKGROUND = 0;
const int MAT_SPHERE1 = 1;
const int MAT_SPHERE2 = 2;

// Helper function for updating nearest scene hit material
void distCheck(float newDist, inout float minDist, int newMaterial, inout int minMaterial)
{
    if (newDist < minDist)
    {
    	minDist = newDist;
        minMaterial = newMaterial;
    }
}

// Distance closest distance from point to sphere
float sdSphere(vec3 rayPos, vec3 spherePos, float sphereRadius)
{
	float dist = length(rayPos - spherePos) - sphereRadius;
    return dist;
}

// Distance to closest scene object. Also sets closest object material into "hitMaterial".
float map(vec3 rayPos, out int hitMaterial)
{
    float minDist = 99999.0;
    hitMaterial = MAT_BACKGROUND;
    
    float tempDist = sdSphere(rayPos, vec3(0.3, 0.0, 0.0), 0.2);
    distCheck(tempDist, minDist, MAT_SPHERE1, hitMaterial);
    tempDist = sdSphere(rayPos, vec3(-0.3, 0.0, 0.0), 0.2);
    distCheck(tempDist, minDist, MAT_SPHERE2, hitMaterial);
    
    return minDist;
}

// Helper function for map that doesn't need to return hitMaterial.
float map(vec3 rayPos)
{
	int tempHitMaterial;
    return map(rayPos, tempHitMaterial);
}

// Uses map function (smallest distance to scene) for
// approximating normal at pos
vec3 approxNormal(vec3 pos)
{
    float epsilon = 0.001;
	vec2 t = vec2(0.0, epsilon);
    vec3 n = vec3(map(pos + t.yxx) - map(pos - t.yxx),
           	  map(pos + t.xyx) - map(pos - t.xyx),
              map(pos + t.xxy) - map(pos - t.xxy));
    return normalize(n);
}

// Computes background color
vec3 shadeBackground(vec3 rayPos, vec3 normal)
{
    return vec3(0.2, 0.2, 0.2);
}

// Computes sphere1 color
vec3 shadeSphere1(vec3 rayPos, vec3 normal)
{
    return vec3(1.0, 0.0, 0.0);
}

// Computes sphere2 color
vec3 shadeSphere2(vec3 rayPos, vec3 normal)
{
    return vec3(0.0, 1.0, 0.0);
}

// Computes color for ray with origin "rayPos" and direction "rayDir"
vec3 getColor(vec3 rayPos, vec3 rayDir)
{
    int hitMaterialTemp;
    int hitMaterial = MAT_BACKGROUND;
    for (int i = 0; i < 128; ++i)
    {
        float d = map(rayPos, hitMaterialTemp);
        rayPos += d * rayDir;
        if (d < 0.001)
        {
            hitMaterial = hitMaterialTemp;
            break;
        }
    }
    vec3 normal = approxNormal(rayPos);
    vec3 color;
    if (hitMaterial == MAT_BACKGROUND)
        color = shadeBackground(rayPos, normal);
    else if (hitMaterial == MAT_SPHERE1)
        color = shadeSphere1(rayPos, normal);
    else if (hitMaterial == MAT_SPHERE2)
        color = shadeSphere2(rayPos, normal);
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float aspect = iResolution.x / iResolution.y;
    
    // Make uv go [-0.5, 0.5] and scale uv.x according to aspect ratio
    uv -= .5;
    uv.x = aspect * uv.x;
    
    // Initialize camera stuff
    vec3 camPos = vec3(0., 0., -1.);
    vec3 camTarget = vec3(0., 0., 0.);
    vec3 camUp = vec3(0., 1., 0.);
    vec3 camDir = normalize(camTarget - camPos);
    vec3 camRight = normalize(cross(camUp, camDir));
    camUp = normalize(cross(camDir, camRight));
    
    vec3 rayPos = camPos;
    vec3 rayDir = normalize(camDir + uv.x * camRight + uv.y * camUp);
    
    // Raymarch scene to get pixel color
    vec3 color = getColor(rayPos, rayDir);
    
    // Set pixel color
	fragColor = vec4(color, 1.0);
}