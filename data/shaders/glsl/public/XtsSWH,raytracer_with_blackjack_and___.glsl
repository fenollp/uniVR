// Shader downloaded from https://www.shadertoy.com/view/XtsSWH
// written by shadertoy user yaro_b
//
// Name: raytracer with blackjack and...
// Description: My first raytracer.
//    
//    NOTE: Click&amp;drag mouse to change camera position.
// My first raytracer.

#define MAX_BOUNCE_COUNT 16

// NxN anti-aliasing.
#define AA_COUNT 4

#define ENABLE_SHADOWS 1

#define PI 3.14159265359

// Index of refraction.
float eta_air = 1.00029;
float eta_glass = 1.5;

float camera_orbit_radius = 2.5;
float camera_elevation = PI / 4.0; // radians
float camera_azimuth = 0.0; // radians;
vec3 camera_pos;
vec3 camera_dir;
vec3 camera_up;

float camera_aspect_ratio = iResolution.x / iResolution.y;
float camera_fov_y = PI / 3.0; // radians
float camera_near = 0.1;
float camera_far = 10.0;
float camera_far_half_height = tan(0.5 * camera_fov_y) * camera_far;
float camera_far_half_width = camera_far_half_height * camera_aspect_ratio;

// vec3 light_pos = vec3(1.0, 1.0, -1.0);
// vec3 light_pos = vec3(cos(2.0 * PI * iGlobalTime), sin(2.0 * PI * iGlobalTime), -1.0);
vec3 light_pos = 2.0 * vec3(cos(2.0 * PI * iGlobalTime / 8.0), 1.0, sin(2.0 * PI * iGlobalTime / 8.0));
vec3 light_radiance = vec3(1.0, 1.0, 1.0);

////////////////////////////////////////////////////////////////////////////////////////////////////

struct Material
{
    vec3 specular;
    vec3 diffuse;
    float alpha; // width parameter aka roughness
    float eta;   // index of refraction
    int scatter_mask;
};

struct Sphere
{
    vec3 origin;
    float radius;
};

struct Plane
{
    // dot(normal, X) = d
    vec3 normal;
    float d;
};

float spacing_angle = 2.0 / 3.0 * PI; // radians
float spacing_radius = 1.0;

// Scene objects:
Sphere diffuse_ball = Sphere(spacing_radius * vec3(cos(0.0 * spacing_angle), 0.5, sin(0.0 * spacing_angle)), 0.5);
Sphere specular_ball = Sphere(spacing_radius * vec3(cos(1.0 * spacing_angle), 0.5, sin(1.0 * spacing_angle)), 0.5);
Sphere glass_ball = Sphere(spacing_radius * vec3(cos(2.0 * spacing_angle), 0.5, sin(2.0 * spacing_angle)), 0.5);
Plane checker_floor = Plane(vec3(0.0, 1.0, 0.0), 0.0);

////////////////////////////////////////////////////////////////////////////////////////////////////

#define SCENE_GLASS_BALL 1
#define SCENE_PLASTIC_BALL 2
#define SCENE_GOLDEN_BALL 3
#define SCENE_FLOOR 4

#define SCATTER_DIFFUSE 1
#define SCATTER_SPECULAR 2
#define SCATTER_TRANSPARENT 4

void get_material(vec3 pos, int id, inout Material mtl)
{
    if (id == SCENE_GLASS_BALL)
    {
        mtl.specular = vec3(0.04, 0.04, 0.04);
        mtl.diffuse = vec3(1.0, 1.0, 1.0) - mtl.specular;
        mtl.alpha = 0.05;
        mtl.eta = 1.5;
        mtl.scatter_mask = SCATTER_TRANSPARENT;
    }
    else if (id == SCENE_PLASTIC_BALL)
    {
        mtl.specular = vec3(0.04, 0.04, 0.04);
        mtl.diffuse = vec3(1.0, 0.0, 0.0) - mtl.specular;
        mtl.alpha = 0.25;
        mtl.eta = 1.46; // PLA (pure); TODO: Pick something better for colored plastic.
        mtl.scatter_mask = SCATTER_DIFFUSE;
    }
    else if (id == SCENE_GOLDEN_BALL)
    {
        mtl.specular = vec3(1.022, 0.782, 0.344);
        mtl.diffuse = vec3(0.0, 0.0, 0.0);
        mtl.alpha = 0.35;
        mtl.eta = 1.47;
        mtl.scatter_mask = SCATTER_SPECULAR;
    }
    else if (id == SCENE_FLOOR)
    {
        float checker_size = 0.5;
        float alpha = floor(pos.x / checker_size) + floor(pos.z / checker_size);
        alpha = abs(alpha);
        alpha -= 2.0 * floor(alpha / 2.0);

        mtl.specular = vec3(0.04, 0.04, 0.04);
        /* mtl.diffuse = mix(vec3(0.95, 0.95, 0.95), vec3(0.25, 0.25, 0.25), alpha); */
        mtl.diffuse = mix(vec3(0.25, 0.25, 0.95), vec3(0.95, 0.95, 0.25), alpha);
        mtl.alpha = 0.25;
        mtl.eta = 1.46; // PLA (pure); TODO: Pick something better for colored plastic.
        mtl.scatter_mask = SCATTER_DIFFUSE;
    }
    else
    {
        mtl.specular = vec3(0.05, 0.05, 0.05);
        mtl.diffuse = vec3(1.0, 0.0, 1.0) - mtl.specular;
        mtl.alpha = 1.0;
        mtl.eta = 1.46; // PLA (pure); TODO: Pick something better for colored plastic.
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Schlick's approximation
vec3 fresnel(vec3 f0, float i_dot_n)
{
    return f0 + (1.0 - f0) * pow(1.0 - max(0.0, i_dot_n), 5.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#if 0
// BSDF = BRDF + BTDF

// BRDF (reflection):
f_r(i, o, n) = F(i, h) * G(i, o, h) * D(h) / (4 * |i.n| * |o.n|)
h = h_r
// with Smith G
f_r(i, o, n) = F(i, h) * G1(i, h) * G1(o, h) * D(h) / (4 * |i.n| * |o.n|)



// BTDF (refraction):
f_t(i, o, n) = (|i.h| * |o.h|) / (|i.n| * |o.n|) * eta_o^2 * (1 - F(i, h)) * G(i, o, h) * D(h) / (eta_i * i.h + eta_o * o.h)^2
h = h_t
// with Smith G
f_t(i, o, n) = (|i.h| * |o.h|) / (|i.n| * |o.n|) * eta_o^2 * (1 - F(i, h)) * G1(i, h) * G1(o, h) * D(h) / (eta_i * i.h + eta_o * o.h)^2



// GGX distribution:
D(m) = a_g^2 * chi_plus(m.n) / (PI * cos^4(theta_m) * (a_g^2 + tan^2(theta_m))^2)
G1(v, m) = chi_plus(v.m / v.n) * 2.0 / (1.0 + sqrt(1.0 + a_g^2 * tan^2(theta_v)))

theta_m = arccos(m.n)
theta_v = arccos(v.n)
chi_plus(a) = step(0.0, a)



p_m(m) = D(m) * |m.n|
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////

float D_ggx(float m_dot_n, Material mtl)
{
    float theta_m = acos(m_dot_n);
    float result = pow(mtl.alpha, 2.0) * step(0.0, m_dot_n) / (PI * pow(m_dot_n, 4.0) * pow(pow(mtl.alpha, 2.0) + pow(tan(theta_m), 2.0), 2.0));
    /* float result = pow(mtl.alpha, 2.0) / (PI * pow(pow(m_dot_n, 2.0) * (pow(mtl.alpha, 2.0) - 1.0) + 1.0, 2.0)); */
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Using Smith G approximation scheme:
// G(i, o, n) = G1(i, n) * G1(o, n)
float G1_ggx(float v_dot_m, float v_dot_n, Material mtl)
{
    float theta_v = acos(v_dot_n);
    float result = step(0.0, v_dot_m / v_dot_n) * 2.0 / (1.0 + sqrt(1.0 + pow(mtl.alpha, 2.0) * pow(tan(theta_v), 2.0)));
    /* float result = 2.0 * v_dot_n / (v_dot_n + sqrt(pow(mtl.alpha, 2.0) + (1.0 - pow(mtl.alpha, 2.0)) * pow(v_dot_n, 2.0))); */
    return result;
}

// Lambertian diffure BRDF.
vec3 diffuse_brdf(vec3 i, vec3 o, vec3 n, Material mtl)
{
    vec3 f_r = mtl.diffuse / PI;
    return f_r;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Microfacet BRDF with GGX distribution.
vec3 specular_brdf(vec3 i, vec3 o, vec3 n, Material mtl)
{
    float i_dot_n = dot(i, n);
    float o_dot_n = dot(o, n);

    vec3 h_r = sign(i_dot_n) * normalize(i + o);

    float i_dot_h = dot(i, h_r);
    float o_dot_h = dot(o, h_r);
    float h_dot_n = dot(h_r, n);

    vec3 F = fresnel(mtl.specular, i_dot_h);
    float G1_i = G1_ggx(i_dot_h, i_dot_n, mtl);
    float G1_o = G1_ggx(o_dot_h, o_dot_n, mtl);
    float D = D_ggx(h_dot_n, mtl);

    vec3 f_r = F * G1_i * G1_o * D / (4.0 * max(0.0, i_dot_n) * max(0.0, o_dot_n));
    return clamp(f_r, 0.0, 1.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

vec3 btdf(vec3 i, vec3 o, vec3 n, float eta_i, float eta_o, Material mtl)
{
    float i_dot_n = dot(i, n);
    float o_dot_n = dot(o, n);

    vec3 h_t = -normalize(eta_i * i + eta_o * o);

    float i_dot_h = dot(i, h_t);
    float o_dot_h = dot(o, h_t);
    float h_dot_n = dot(h_t, n);

    vec3 F = fresnel(mtl.specular, i_dot_h);
    float G1_i = G1_ggx(i_dot_h, i_dot_n, mtl);
    float G1_o = G1_ggx(o_dot_h, o_dot_n, mtl);
    float D = D_ggx(h_dot_n, mtl);

    vec3 f_t = (max(0.0, i_dot_h) * max(0.0, o_dot_h)) / (max(0.0, i_dot_n) * max(0.0, o_dot_n)) *
        pow(eta_o / eta_i, 2.0) * (1.0 - F) * G1_i * G1_o * D / pow(eta_i * i_dot_h + eta_o * o_dot_h, 2.0);
    return clamp(f_t, 0.0, 1.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void setup_camera_orbit(
        float radius,
        float azimuth,
        float elevation,
        out vec3 cam_pos,
        out vec3 cam_dir,
        out vec3 cam_up)
{
    float cos_az = cos(azimuth);
    float sin_az = sin(azimuth);

    float cos_el = cos(elevation);
    float sin_el = sin(elevation);

    cam_pos = radius * vec3(
            cos_az * cos_el,
            sin_el,
            sin_az * cos_el);
    cam_dir = -normalize(cam_pos);
    // up = vec3(
    //          cos(az) * cos(el + PI),
    //          sin(el + PI),
    //          sin(az) * cos(el + PI)),
    // where
    //          cos(el + PI) == -sin(el)
    //          sin(el + PI) == cos(el)
    cam_up = vec3(
            cos_az * -sin_el,
            cos_el,
            sin_az * -sin_el);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// ray-plane intersection:
/* r = ray_pos + t * ray_dir */
/* dot(n, r) = d */
/* dot(n, r.pos + t * r.dir) = d */
/* dot(n, r.pos) + t * dot(n, r.dir) = d */
/* => t = (d - dot(n, r.pos)) / dot(n, r.dir) */
bool intersect_ray_plane(vec3 ray_pos, vec3 ray_dir, Plane p, out float t)
{
    bool result = false;

    float n_dot_dir = dot(p.normal, ray_dir);
    if (abs(n_dot_dir) > 0.000001)
    {
        float n_dot_pos = dot(p.normal, ray_pos);
        float t1 = (p.d - n_dot_pos) / n_dot_dir;
        if (t1 >= 0.0)
        {
            t = t1;
            result = true;
        }
    }

    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// ray-sphere intersection:
/* r = ray_pos + t * ray_dir */
/* ||r - origin|| == radius^2 */
/* v = r - origin = r.pos + t * r.dir - origin = (r.pos - origin) + t * r.dir = a + t * b */
/* dot(v, v) = R^2 */
/* dot(a + t * b, a + t * b) = dot(a,a) + 2*t*dot(a,b) + t*t*dot(b,b) = R^2 */
/* A = dot(b,b) */
/* B = 2*dot(a,b) */
/* C = dot(a,a)-R^2 */
/* => t = (-B +- sqrt(B*B - 4*A*C)) / (2*A) */
bool intersect_ray_sphere(vec3 ray_pos, vec3 ray_dir, Sphere s, out float t)
{
    bool result = false;

    float A = dot(ray_dir, ray_dir);
    float B = 2.0 * dot(ray_pos - s.origin, ray_dir);
    float C = dot(ray_pos - s.origin, ray_pos - s.origin) - s.radius * s.radius;
    float det = B * B - 4.0 * A * C;
    if (abs(A) > 0.0 && det >= 0.0)
    {
        float t1 = (-B - sqrt(det)) / (2.0 * A);
        float t2 = (-B + sqrt(det)) / (2.0 * A);

        if (t1 >= 0.0 && t2 >= 0.0)
        {
            t = min(t1, t2);
            result = true;
        }
        else if (t1 >= 0.0)
        {
            t = t1;
            result = true;
        }
        else if (t2 >= 0.0)
        {
            t = t2;
            result = true;
        }
    }

    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// NOTE: We use prev_id to identify an object the ray collided with on the previous trace step.
// In general this approach is wrong, because objects should be allowed to cast shadows on themselves,
// but in our scene all objects are either convex (spheres) and flat (plane). So, self-shadowing is
// not possible anyway.
int raytrace(int prev_id, vec3 ray_pos, vec3 ray_dir, out vec3 pos, out vec3 normal)
{
    int id = 0;
    float t_min = 1000.0;// camera_far;
    float t;

    if (prev_id != SCENE_PLASTIC_BALL && intersect_ray_sphere(ray_pos, ray_dir, diffuse_ball, t))
    {
        t_min = t;
        pos = ray_pos + t * ray_dir;
        normal = normalize(pos - diffuse_ball.origin);
        id = SCENE_PLASTIC_BALL;
    }
    if (prev_id != SCENE_GOLDEN_BALL && intersect_ray_sphere(ray_pos, ray_dir, specular_ball, t) && t < t_min)
    {
        t_min = t;
        pos = ray_pos + t * ray_dir;
        normal = normalize(pos - specular_ball.origin);
        id = SCENE_GOLDEN_BALL;
    }
    if (prev_id != SCENE_GLASS_BALL && intersect_ray_sphere(ray_pos, ray_dir, glass_ball, t) && t < t_min)
    {
        t_min = t;
        pos = ray_pos + t * ray_dir;
        normal = normalize(pos - glass_ball.origin);
        id = SCENE_GLASS_BALL;
    }
    if (prev_id != SCENE_FLOOR && intersect_ray_plane(ray_pos, ray_dir, checker_floor, t) && t < t_min)
    {
        t_min = t;
        pos = ray_pos + t * ray_dir;
        normal = checker_floor.normal;
        id = SCENE_FLOOR;
    }

    return id;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    camera_azimuth = 2.0 * PI * (0.5 + iMouse.x / iResolution.x);
    camera_elevation = 0.5 * PI * (0.25 + iMouse.y / iResolution.y);

    setup_camera_orbit(
        camera_orbit_radius,
        camera_azimuth,
        camera_elevation,
        camera_pos,
        camera_dir,
        camera_up);
    vec3 camera_right = cross(camera_up, camera_dir);

    // NxN anti-aliasing.
    vec3 pixel_radiance = vec3(0.0, 0.0, 0.0);
    for (int aa_x = 0; aa_x < AA_COUNT; ++aa_x)
    {
        for (int aa_y = 0; aa_y < AA_COUNT; ++aa_y)
        {
            vec2 aa_sample_offset = vec2(aa_x, aa_y) / float(AA_COUNT);
            vec2 uv = (fragCoord.xy + aa_sample_offset) / iResolution.xy;
            // uv = 2.0 * uv - 1.0;
            // uv.x *= camera_aspect_ratio;

            vec3 ray_pos = camera_pos;
            vec3 ray_far = camera_pos +
                camera_far * camera_dir +
                camera_far_half_width * (-1.0 + 2.0 * uv.x) * camera_right +
                camera_far_half_height * (-1.0 + 2.0 * uv.y) * camera_up;
            vec3 ray_dir = normalize(ray_far - ray_pos);

            vec3 radiance = vec3(0.0, 0.0, 0.0);
            vec3 L_i = light_radiance;

            int id = 0;
            for (int bounce = 0; bounce < MAX_BOUNCE_COUNT; ++bounce)
            {
                vec3 pos, n;
                id = raytrace(id, ray_pos, ray_dir, pos, n);

                if (id > 0)
                {
                    Material mtl;
                    get_material(pos, id, mtl);

                    vec3 l = normalize(light_pos - pos);
                    /* vec3 v = normalize(camera_pos - pos); */
                    vec3 i = -ray_dir;

                    // TODO
#if ENABLE_SHADOWS
                    vec3 dummy_pos, dummy_normal;
                    int shadow_id = raytrace(id, pos, l, dummy_pos, dummy_normal);
                    float shadow = (shadow_id == 0) ? 1.0 : 0.0;
#else
                    float shadow = 1.0;
#endif

                    if (mtl.scatter_mask == SCATTER_DIFFUSE)
                    {
                        radiance += L_i * shadow * PI * max(0.0, dot(l, n)) * diffuse_brdf(i, l, n, mtl);
                        L_i = vec3(0.0, 0.0, 0.0);

                        break;
                    }
                    else if (mtl.scatter_mask == SCATTER_SPECULAR)
                    {
                        radiance += L_i * shadow * PI * max(0.0, dot(l, n)) * specular_brdf(i, l, n, mtl);

                        vec3 m = n;
                        vec3 R_theta = fresnel(mtl.specular, dot(i, m));
                        R_theta = clamp(R_theta, 0.0, 1.0);

                        bvec3 flags = greaterThan(R_theta, vec3(0.0, 0.0, 0.0));
                        if (any(flags))
                        {
                            vec3 o_r = 2.0 * max(0.0, dot(i, m)) * m - i;
                            vec3 f_r = specular_brdf(i, o_r, m, mtl);

                            L_i *= R_theta;//f_r;
                            ray_pos = pos;
                            ray_dir = o_r;
                        }
                    }
                    else if (mtl.scatter_mask == SCATTER_TRANSPARENT)
                    {
                        float eta_i = eta_air;
                        float eta_o = mtl.eta;
                        if (dot(i, n) <= 0.0) // Ray exiting the object?
                        {
                            float eta_i = mtl.eta;
                            float eta_o = eta_air;
                            n = -n;
                        }

                        radiance += L_i * shadow * PI * max(0.0, dot(l, n)) * btdf(i, l, n, eta_i, eta_o, mtl);
                        id = 0;

                        vec3 m = n;
                        vec3 R_theta = fresnel(mtl.specular, dot(i, m));
                        R_theta = clamp(R_theta, 0.0, 1.0);

                        bvec3 flags = greaterThan(vec3(1.0, 1.0, 1.0) - R_theta, vec3(0.0, 0.0, 0.0));
                        if (any(flags))
                        {
                            float c = dot(i, m);
                            float eta = eta_i / eta_o;

                            vec3 o_t = (eta * c - sign(dot(i, n)) * sqrt(1.0 + eta * (c * c - 1.0))) * m - eta * i;
                            vec3 f_t = btdf(i, o_t, m, eta_i, eta_o, mtl);

                            L_i *= vec3(1.0, 1.0, 1.0) - R_theta;//f_t;
                            ray_pos = pos + 0.000001 * o_t;
                            ray_dir = o_t;
                            id = 0;
                        }
                    }
                }
                else
                {
                    break;
                }
            }

            pixel_radiance += radiance;
        }
    }

    fragColor.rgb = pixel_radiance / float(AA_COUNT * AA_COUNT);

    // TODO: Tonemapping.

    // Linear to gamma (sRGB) color space conversion (approximated).
    float inv_gamma = 1.0 / 2.2;
    fragColor.rgb = pow(fragColor.rgb, vec3(inv_gamma, inv_gamma, inv_gamma));
}
