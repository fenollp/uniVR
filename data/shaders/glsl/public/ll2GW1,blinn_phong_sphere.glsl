// Shader downloaded from https://www.shadertoy.com/view/ll2GW1
// written by shadertoy user cgikoray
//
// Name: blinn-phong sphere
// Description: An adaption of the Blinn-Phong shading model for use in education.
# define PI 3.14159265358979323846
# define TEXTURING 1

struct Ray {
    vec3 origin;
    vec3 direction;
};

struct Contact {
    vec3 normal;
    vec3 position;
};

struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float high_light;
};
    
struct Sphere {
    Material material;
    vec3 position;
    float radius;
};

struct Light {
    vec3 direction;
    float occlusion;
};

struct Fragment {
    vec3 color;
    vec3 gamma;
};
  
float intersect(in Ray ray, in Sphere sphere) {
    vec3 look = -sphere.position;
	float a = dot(look, ray.direction);
	float t = a * a - (dot(look,look) - sphere.radius * sphere.radius);
	if(t <= 0.0) return -1.0;
	return -a - sqrt(t);
}

vec3 ray_position(in Ray ray, float t) {
    return ray.origin + ray.direction * t;
}

vec3 spherical_texturing(in vec3 normal, in sampler2D texture, float delta) {
     float u = atan(normal.z, normal.x) / PI * 2.0 + delta;
	 float v = asin(normal.y) / PI * 2.0;
     return texture2D(texture, vec2(u, v)).xyz;
}

vec3 blinn_phong(in Contact contact, in Ray eye, in Sphere sphere, in Light light, float t, float delta) {
    Fragment fragment;
    fragment.color = vec3(0.15);
    fragment.gamma = vec3(1.0);
    
    if(t > 0.0) {
        float ambient = clamp(0.5 + 0.5 * contact.normal.y, 0.0, 1.0);
        float diffuse = clamp(dot(light.direction, contact.normal), 0.0, 1.0);
        vec3 half_way = normalize(-eye.direction + light.direction);
        float specular = pow(clamp(dot(half_way, contact.normal), 0.0, 1.0), sphere.material.high_light);
        
        fragment.color = ambient * sphere.material.ambient * light.occlusion;
        fragment.color += diffuse * sphere.material.diffuse * light.occlusion;
        fragment.color += diffuse * specular * sphere.material.specular * light.occlusion;
#if TEXTURING
        fragment.color *= spherical_texturing(contact.normal, iChannel0, delta * 0.05);
#endif
    }
    
    return pow(fragment.color, fragment.gamma);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {   
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    float delta = iGlobalTime;
    
    Ray eye;
    eye.origin = vec3(0.0);
    eye.direction = normalize(vec3(uv.xy, -1.0));
    
    Material material;
    material.ambient = vec3(0.2, 0.2, 0.2);
    material.diffuse = vec3(0.9, 0.9, 0.9);
    material.specular = vec3(0.45, 0.45, 0.45);
    material.high_light = 25.0;
    
    Sphere sphere;
    sphere.position = vec3(0.0, 0.0, -10.0);
    sphere.radius = 5.0;
    sphere.material = material;
    
    float t = intersect(eye, sphere); 
    
    Contact contact;
    contact.position = ray_position(eye, t);
    contact.normal = normalize(contact.position - sphere.position);
    
    Light light;
    light.direction = normalize(vec3(0.0, 5.0, 5.0));
    light.direction.x = sin(delta);
    light.occlusion = 0.5 + 0.5 * contact.normal.y;

    fragColor = vec4(blinn_phong(contact, eye, sphere, light, t, delta), 1.0);
}