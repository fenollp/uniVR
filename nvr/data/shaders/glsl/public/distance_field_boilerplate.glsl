// Shader downloaded from https://www.shadertoy.com/view/ls3XW2
// written by shadertoy user finalman
//
// Name: Distance Field Boilerplate
// Description: A good place to start for distance field based shaders
const float EPSILON = 1e-5;
const float PI = 3.1415926535897932384626433832795;

float sphere(vec3 pos, float radius, vec3 sample)
{
    return distance(pos, sample) - radius;
}

float plane(vec3 pos, vec3 normal, vec3 sample)
{
    return dot(sample - pos, normal);
}

float map(vec3 sample)
{
    float t = fract(iGlobalTime * 0.5);
    float h = (t - t * t) * 3.0;
    
    return min(
        sphere(vec3(0.0, h, 0.0), 1.0, sample),
        plane(vec3(0, -1, 0), vec3(0, 1, 0), sample)
   	);
}

vec3 normal(vec3 sample)
{
    float RANGE = 0.01;
    float c = map(sample);
    float x = map(sample + vec3(RANGE, 0, 0));
    float y = map(sample + vec3(0, RANGE, 0));
    float z = map(sample + vec3(0, 0, RANGE));
	return normalize(vec3(x, y, z) - c);
}

float occlusion(vec3 sample, vec3 normal)
{
    float RANGE = 0.5;
    return clamp(map(sample + normal * RANGE) / RANGE, 0.0, 1.0);
}

vec3 march(vec3 origin, vec3 direction)
{
    const int MAX_STEPS = 400;
	const float MAX_DIST = 200.0;
    
    vec3 pos = origin;
    float dist = 0.0;
    
    for (int i = 0; i < MAX_STEPS; i++)
    {
        float m = map(pos);
        dist += m;
        pos = origin + direction * dist;
        
        if (m < EPSILON)
        {
            return pos;
        }
        
        if (dist > MAX_DIST)
        {
            break;
        }
    }
    
    return origin + direction * MAX_DIST;
}

float lightContribution(vec3 pos, vec3 normal, vec3 lightDirection, vec3 viewDirection)
{
    const float ROUGHNESS = 80.0;
    const float FRESNEL_POWER = 20.0;
    const float MIN_REFLECTANCE = 0.65;
    const float MAX_REFLECTANCE = 0.99;
    
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float specular = pow(max(dot(reflect(viewDirection, normal), lightDirection), 0.0), ROUGHNESS);
    float fresnel = pow(length(cross(normal, viewDirection)), FRESNEL_POWER);
    float reflectance = mix(MIN_REFLECTANCE, MAX_REFLECTANCE, fresnel);
    
    return mix(diffuse, specular, reflectance);
}

vec3 lighting(vec3 pos, vec3 normal, vec3 viewDirection)
{
    const vec3 LIGHT_1_DIRECTION = normalize(vec3(-0.5, 1.0, -0.7));
    const vec3 LIGHT_2_DIRECTION = normalize(vec3(1.0, 0.1, 0.9));
    const vec3 LIGHT_1_COLOR = vec3(0.90, 0.85, 0.80);
    const vec3 LIGHT_2_COLOR = vec3(0.05, 0.06, 0.07);
    const vec3 AMBIENT_COLOR = vec3(0.02, 0.02, 0.03);
    
    float ambient = occlusion(pos, normal);
	float light1 = lightContribution(pos, normal, LIGHT_1_DIRECTION, viewDirection);
    float light2 = lightContribution(pos, normal, LIGHT_2_DIRECTION, viewDirection);
    
    return ambient * AMBIENT_COLOR + 
        light1 * LIGHT_1_COLOR + 
        light2 * LIGHT_2_COLOR;
}

vec3 fog(vec3 c, float dist)
{
    const float FOG_DENSITY = 0.1;
    const vec3 FOG_COLOR = vec3(0.01, 0.02, 0.02);
    
    float fogAmount = 1.0 - exp(-dist * FOG_DENSITY);
        
    return mix(c, FOG_COLOR, fogAmount);
}

vec3 render(vec3 origin, vec3 direction)
{
    vec3 p = march(origin, direction);
    vec3 n = normal(p);
    vec3 c = lighting(p, n, direction);
    return fog(c, distance(origin, p));
}

vec3 gammaCorrect(vec3 c)
{
    return pow(c, vec3(1.0 / 2.2));
}

vec3 camera(vec3 origin, vec3 lookAt, vec3 up, float fov, vec2 fragCoord)
{
    lookAt -= origin;
    vec3 forward = normalize(lookAt);
    vec3 right = normalize(cross(up, forward));
    up = normalize(cross(forward, right));
    vec2 screen = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    float viewPlane = -tan(fov * PI / 360.0 + PI * 0.5);
    return normalize(right * screen.x + up * screen.y + forward * viewPlane);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec3 origin = vec3(0, 0, -4);
    vec3 direction = camera(origin, vec3(0, 0.1, 0), vec3(0, 1, 0), 90.0, fragCoord);
	vec3 color = render(origin, direction);
    
    fragColor = vec4(gammaCorrect(color), 1.0);
}