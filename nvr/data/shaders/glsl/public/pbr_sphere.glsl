// Shader downloaded from https://www.shadertoy.com/view/MtBGWW
// written by shadertoy user cgikoray
//
// Name: pbr sphere
// Description: An adaption of physically-based shading for use in education.
/* Thank you TDM for inspiration: https://www.shadertoy.com/view/XsfXWX */

# define PI 3.14159265358979323846
# define GEOMETRY 1
# define TEXTURING 1
# define ENVIRONMENT 1
# define FISHEYE 1
# define REFLECT 1
# define BLURRED 1
# define FRESNEL 1
# define HDR 1

struct Ray {
    vec3 origin;
    vec3 direction;
};
    
struct Contact {
    vec3 normal;
    vec3 position;
};

struct Material {
    vec3 diffuse;
    float roughness;
    float fresnel;
};
    
struct Sphere {
    Material material;
    vec3 position;
    float radius;
};
    
struct Light {
    vec3 direction;
    vec3 color;
};
    
struct Fragment {
    vec3 color;
    float gamma;
};
    
void fish_eye(out Ray ray, in vec2 perspective){
    float fish_eye = length(perspective.xy);
    ray.direction.z += fish_eye * 0.3;
    ray.direction = normalize(ray.direction);
}
    
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

void horizontal_rotation(out vec3 vec, float delta) {
    float c = cos(delta);
    float s = sin(delta);
    vec.xz = vec2(vec.x * c - vec.z * s, vec.x * s + vec.z * c);
}

vec3 spherical_texturing(in vec3 normal, in sampler2D texture, float delta) {
     float u = atan(normal.z, normal.x) / PI * 2.0 + delta;
     float v = asin(normal.y) / PI * 2.0;
     return texture2D(texture, vec2(u, v)).xyz;
}

vec3 tone_map(in Fragment fragment, float luma)
{
    fragment.color = exp(-1.0 / (2.72 * fragment.color + 0.15));
    fragment.color = pow(fragment.color, vec3(1.0 / (fragment.gamma * luma)));
    return fragment.color;
}

vec3 hdr(in Fragment fragment) {
    float luma = dot(fragment.color, vec3(0.2126, 0.7152, 0.0722));
    return mix(fragment.color, tone_map(fragment, luma), 1.0 - luma);
}

float some_step(float t) {
    return pow(t, 4.0);
}

vec3 texture_average(samplerCube texture, vec3 tc) {
    const float diff0 = 0.35;
    const float diff1 = 0.12;
    vec3 s0 = textureCube(texture, tc).xyz;
    vec3 s1 = textureCube(texture, tc + vec3(diff0)).xyz;
    vec3 s2 = textureCube(texture, tc + vec3(-diff0)).xyz;
    vec3 s3 = textureCube(texture, tc + vec3(-diff0, diff0, -diff0)).xyz;
    vec3 s4 = textureCube(texture, tc + vec3(diff0, -diff0, diff0)).xyz;
    vec3 s5 = textureCube(texture, tc + vec3(diff1)).xyz;
    vec3 s6 = textureCube(texture, tc + vec3(-diff1)).xyz;
    vec3 s7 = textureCube(texture, tc + vec3(-diff1, diff1,- diff1)).xyz;
    vec3 s8 = textureCube(texture, tc + vec3(diff1, -diff1, diff1)).xyz;
     
    return (s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8) * 0.111111111;
}

vec3 texture_blurred(samplerCube texture, vec3 tc) {
#if BLURRED
    vec3 r = texture_average(texture, vec3(1.0, 0.0, 0.0));
    vec3 t = texture_average(texture, vec3(0.0, 1.0, 0.0));
    vec3 f = texture_average(texture, vec3(0.0, 0.0, 1.0));
    vec3 l = texture_average(texture, vec3(-1.0, 0.0, 0.0));
    vec3 b = texture_average(texture, vec3(0.0, -1.0, 0.0));
    vec3 a = texture_average(texture, vec3(0.0, 0.0, -1.0));
        
    float kr = dot(tc,vec3(1.0,0.0,0.0)) * 0.5 + 0.5; 
    float kt = dot(tc,vec3(0.0,1.0,0.0)) * 0.5 + 0.5;
    float kf = dot(tc,vec3(0.0,0.0,1.0)) * 0.5 + 0.5;
    float kl = 1.0 - kr;
    float kb = 1.0 - kt;
    float ka = 1.0 - kf;
    
    kr = some_step(kr);
    kt = some_step(kt);
    kf = some_step(kf);
    kl = some_step(kl);
    kb = some_step(kb);
    ka = some_step(ka);    
    
    float d = 0.0;
    vec3 ret = vec3(0.0);
    ret  = f * kf; d  = kf;
    ret += a * ka; d += ka;
    ret += l * kl; d += kl;
    ret += r * kr; d += kr;
    ret += t * kt; d += kt;
    ret += b * kb; d += kb;
    
    return ret / d;
#else
    return textureCube(texture, tc).xyz;
#endif
}

vec3 bdrf(in Contact contact, in Ray eye, in Sphere sphere, in Light light, float t, float delta) {
    Fragment fragment;
#if ENVIRONMENT
    fragment.color = textureCube(iChannel0, eye.direction).xyz;
    fragment.gamma = 2.3;
#else
    fragment.color = vec3(0.0);
    fragment.gamma = 0.0;
#endif
    
    if(t > 0.0) {
        float ndotv = clamp(dot(contact.normal, -eye.direction), 0.0, 1.0);
        float ndotl = clamp(dot(light.direction, contact.normal), 0.0, 1.0);
        vec3 rrefn = reflect(eye.direction, contact.normal);
        float ldotr = clamp(dot(light.direction, rrefn), 0.0, 1.0);
        float specular_mod = 1.0 - sphere.material.roughness;
        float specular_power = clamp(pow(ldotr, 1.0 / specular_mod) * specular_mod, 0.0, 1.0);
        vec3 material_reflection = texture_blurred(iChannel0, rrefn);
#if FRESNEL
        float fresnel_base = ndotv;
        float fresnel_exp = pow(fresnel_base, sphere.material.fresnel);
        float fresnel_term = specular_power + fresnel_exp;
#else
        float fresnel_term = 0.0;
#endif
        float normalization_term = ((specular_power + 4.0) / 4.0 * PI);
        float specular_term = normalization_term * specular_power;
        float vis_alpha = 1.0 / (sqrt((PI / 4.0) * specular_power + (PI / 2.0)));
        float vis_term = clamp((ndotl * (1.0 - vis_alpha) + vis_alpha) * (ndotv * (1.0 - vis_alpha) + vis_alpha), 0.0, 1.0);
#if REFLECT
        vec3 reflection = textureCube(iChannel0, rrefn).xyz;
        reflection = mix(reflection, material_reflection, 1.0 - vis_term);
        reflection = mix(reflection, material_reflection, sphere.material.roughness);
#endif
        vec3 specular_color = specular_term * fresnel_term * vis_term * light.color;
#if REFLECT
        vec3 diffuse_color = mix(sphere.material.diffuse, reflection, vis_term);
#else 
        vec3 diffuse_color = sphere.material.diffuse;
#endif   
        fragment.color = diffuse_color + specular_color;
#if HDR
        fragment.color = hdr(fragment);
#endif
    }
    
    return fragment.color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {   
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float delta = iGlobalTime;
    float half_delta = delta * 0.5;
    float quarter_delta = delta * 0.25;
    float rotation_delta = delta / 20.0;
    
    Ray eye;
    eye.origin = vec3(0.0);
    eye.direction = normalize(vec3(uv.xy, -1.0));
    
    Material material;
    material.roughness = sin(half_delta) * 0.5 + 0.5;
    material.fresnel = 35.0;
    
    Sphere sphere;
#if GEOMETRY
    sphere.position = vec3(0.0, 0.0, -10.0);
    sphere.radius = 6.0;
#else
    sphere.position = vec3(0.0);
    sphere.radius = 0.0;
#endif

#if FISHEYE
    fish_eye(eye, uv);
#endif    
    
    horizontal_rotation(eye.direction, rotation_delta);
    horizontal_rotation(sphere.position, rotation_delta);
    
    float t = intersect(eye, sphere);
    
    Contact contact;
    contact.position = ray_position(eye, t);
    contact.normal = normalize(contact.position - sphere.position);
    
#if TEXTURING
    material.diffuse = spherical_texturing(contact.normal, iChannel1, rotation_delta);
#else
    material.diffuse = vec3(0.2);
#endif
    sphere.material = material;
    
    Light light;
    light.direction = normalize(vec3(0.5, 1.0, 0.0));
    light.color = texture_blurred(iChannel0, eye.direction).xyz;
    
    fragColor = vec4(bdrf(contact, eye, sphere, light, t, quarter_delta), 1.0);
}