// Shader downloaded from https://www.shadertoy.com/view/ltBGzc
// written by shadertoy user yaro_b
//
// Name: DF car
// Description: My first experiment with ray marching of distance fields.
//    Target: nice car on the ground, with PBS BRDF shading &amp; materials, soft shadows, AO, AA, and gamma-correction.

// sd - signed distance
// ud - unsigned distance

float dot2(vec3 v)
{
    return dot(v,v);
}

float length_n(vec2 v, float n)
{
    return pow(pow(v.x, n) + pow(v.y, n), 1.0 / n);
}

// polynomial smooth min (k = 0.1);
float smin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// Schlick's approximation
vec3 fresnel(vec3 f0, vec3 l, vec3 h)
{
    return f0 + (1.0 - f0) * pow(1.0 - max(0.0, dot(l, h)), 5.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

struct DistanceField
{
    float distance;
    int id;
};

struct Material
{
    vec3 ambient;
    vec3 specular;
    vec3 diffuse;
    float m;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// primitives
////////////////////////////////////////////////////////////////////////////////////////////////////

float sd_sphere(vec3 p, float radius)
{
    return length(p) - radius;
}

float sd_box(vec3 p, vec3 b)
{
    vec3 diff = abs(p) - b;
    return min(max(diff.x,max(diff.y, diff.z)), 0.0) + length(max(diff, 0.0));
}

float ud_box(vec3 p, vec3 box)
{
    return length(max(abs(p) - box, 0.0));
}

float ud_round_box(vec3 p, vec3 box, float radius)
{
    return length(max(abs(p) - box, 0.0)) - radius;
}

float sd_plane(vec3 p, vec4 n)
{
    // n must be normalized
    return dot(p, n.xyz) + n.w;
}

float sd_torus(vec3 p, vec2 t)
{
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

float sd_torus82(vec3 p, vec2 t)
{
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length_n(q, 8.0) - t.y;
}

float sd_torus82_z(vec3 p, vec2 t)
{
    vec2 q = vec2(length(p.xy) - t.x, p.z);
    return length_n(q, 8.0) - t.y;
}

float sd_cylinder(vec3 p, vec3 c)
{
    return length(p.xz - c.xy) - c.z;
}

float sd_capped_cylinder(vec3 p, vec2 h)
{
    vec2 d = abs(vec2(length(p.xz), p.y)) - h;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sd_capped_cylinder_z(vec3 p, vec2 h)
{
    vec2 d = abs(vec2(length(p.xy), p.z)) - h;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sd_cone(vec3 p, vec2 c)
{
    // c must be normalized
    float q = length(p.xy);
    return dot(c, vec2(q, p.z));
}

float sd_capped_cone(vec3 p, vec3 c)
{
    vec2 q = vec2(length(p.xz), p.y );
    vec2 v = vec2(c.z * c.y / c.x, -c.z);

    vec2 w = v - q;

    vec2 vv = vec2(dot(v,v), v.x * v.x);
    vec2 qv = vec2(dot(v,w), v.x * w.x);

    vec2 d = max(qv,0.0) * qv / vv;

    return sqrt(dot(w,w) - max(d.x, d.y)) * sign(max(q.y * v.x - q.x * v.y, w.y));
}

float sd_hex_prism(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z - h.y, max((q.x * 0.866025 + q.y * 0.5), q.y) - h.x);
}

float sd_tri_prism(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z - h.y, max(q.x * 0.866025 + p.y * 0.5, -p.y) - h.x * 0.5);
}

float sd_capsule(vec3 p, vec3 a, vec3 b, float r)
{
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

float ud_triangle(vec3 p, vec3 a, vec3 b, vec3 c)
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross( ba, ac );

    return sqrt(
            (sign(dot(cross(ba, nor), pa)) +
             sign(dot(cross(cb, nor), pb)) +
             sign(dot(cross(ac, nor), pc)) < 2.0)
            ?
            min(min(
                    dot2(ba * clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
                    dot2(cb * clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
                dot2(ac * clamp(dot(ac, pc) / dot2(ac), 0.0, 1.0) - pc))
            :
            dot(nor, pa) * dot(nor, pa) / dot2(nor));
}

float ud_quad(vec3 p, vec3 a, vec3 b, vec3 c, vec3 d)
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 dc = d - c; vec3 pc = p - c;
    vec3 ad = a - d; vec3 pd = p - d;
    vec3 nor = cross( ba, ad );

    return sqrt(
            (sign(dot(cross(ba,nor),pa)) +
             sign(dot(cross(cb,nor),pb)) +
             sign(dot(cross(dc,nor),pc)) +
             sign(dot(cross(ad,nor),pd)) < 3.0)
            ?
            min(min(min(
                        dot2(ba * clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
                        dot2(cb * clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
                    dot2(dc * clamp(dot(dc, pc) / dot2(dc), 0.0, 1.0) - pc)),
                dot2(ad * clamp(dot(ad, pd) / dot2(ad), 0.0, 1.0) - pd))
            :
            dot(nor, pa) * dot(nor, pa) / dot2(nor));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// operations
////////////////////////////////////////////////////////////////////////////////////////////////////

DistanceField df_union(DistanceField d1, DistanceField d2)
{
    if (d1.distance <= d2.distance)
        return d1;
    else
        return d2;
}

float op_union(float d1, float d2)
{
    return min(d1, d2);
}

float op_smooth_union(float d1, float d2, float r)
{
    return smin(d1, d2, r);
}

float op_subtraction(float d1, float d2)
{
    // return (d1.distance >= -d2.distance) ? d1 : d2;
    return max(d1, -d2);
}

float op_intersection(float d1, float d2)
{
    // return (d1.distance >= d2.distance) ? d1 : d2;
    return max(d1, d2);
}

/*
float op_repeat(vec3 p, vec3 c)
{
    vec3 q = mod(p, c) - 0.5 * c;
    return primitve(q);
}

// rotation/translation
vec3 op_transform(vec3 p, mat4 m)
{
    vec3 q = invert(m) * p;
    return primitive(q);
}

float op_scale(vec3 p, float s)
{
    return primitive(p / s) * s;
}

float op_displace(vec3 p)
{
    float d1 = primitive(p);
    float d2 = displacement(p);
    return d1 + d2;
}

float op_blend(vec3 p)
{
    float d1 = primitiveA(p);
    float d2 = primitiveB(p);
    return smin(d1, d2);
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// scene
////////////////////////////////////////////////////////////////////////////////////////////////////

#define SCENE_WHITE_PLASTIC 1
#define SCENE_RED_PLASTIC 2
#define SCENE_GOLD 3
#define SCENE_FLOOR 4

void df_material(vec3 pos, int id, inout Material mtl)
{
    if (id == SCENE_WHITE_PLASTIC)
    {
        mtl.ambient = vec3(0.0625, 0.0625, 0.0625);
        mtl.specular = vec3(0.05, 0.05, 0.05);
        mtl.diffuse = vec3(1.0, 1.0, 1.0) - mtl.specular;
        mtl.m = 128.0;
    }
    else if (id == SCENE_RED_PLASTIC)
    {
        mtl.ambient = vec3(0.0625, 0.0625, 0.0625);
        mtl.specular = vec3(0.05, 0.05, 0.05);
        mtl.diffuse = vec3(1.0, 0.0, 0.0) - mtl.specular;
        mtl.m = 128.0;
    }
    else if (id == SCENE_GOLD)
    {
        mtl.ambient = vec3(0.0625, 0.0625, 0.0625);
        mtl.specular = vec3(1.022, 0.782, 0.344);
        mtl.diffuse = vec3(0.0, 0.0, 0.0);
        mtl.m = 8.0;
    }
    else if (id == SCENE_FLOOR)
    {
        float checker_size = 0.5;
        float alpha = floor(pos.x / checker_size) + floor(pos.z / checker_size);
        alpha = abs(alpha);
        alpha -= 2.0 * floor(alpha / 2.0);

        mtl.ambient = vec3(0.0625, 0.0625, 0.0625);
        mtl.specular = vec3(0.05, 0.05, 0.05);
        /* mtl.diffuse = mix(vec3(0.95, 0.95, 0.95), vec3(0.25, 0.25, 0.25), alpha); */
        mtl.diffuse = mix(vec3(0.25, 0.25, 0.95), vec3(0.95, 0.95, 0.25), alpha);
        mtl.m = 128.0;
    }
    else
    {
        mtl.ambient = vec3(0.0625, 0.0625, 0.0625);
        mtl.specular = vec3(0.05, 0.05, 0.05);
        mtl.diffuse = vec3(1.0, 0.0, 1.0) - mtl.specular;
        mtl.m = 128.0;
    }
}

DistanceField df_scene(vec3 p)
{
    // Base chassis.
    float chassis = op_smooth_union(
        sd_sphere(p - vec3(0.0, 0.25, 0.0), 0.5),
        //sd_box(p, vec3(1.0, 0.2, 0.4)),
        ud_round_box(p, vec3(1.0, 0.2, 0.6), 0.05),
        0.1);
    // Cut out wheel arcs.
    chassis = op_subtraction(
        chassis,
        sd_capped_cylinder_z(p - vec3(-0.75, -0.2,  0.5), vec2(0.4, 0.2)));
    chassis = op_subtraction(
        chassis,
        sd_capped_cylinder_z(p - vec3(-0.75, -0.2, -0.5), vec2(0.4, 0.2)));
    chassis = op_subtraction(
        chassis,
        sd_capped_cylinder_z(p - vec3( 0.75, -0.2,  0.5), vec2(0.4, 0.2)));
    chassis = op_subtraction(
        chassis,
        sd_capped_cylinder_z(p - vec3( 0.75, -0.2, -0.5), vec2(0.4, 0.2)));

    float wheels = op_union(
        op_union(
            sd_torus82_z(p - vec3(-0.75, -0.2,  0.5), vec2(0.2, 0.1)),
            sd_torus82_z(p - vec3(-0.75, -0.2, -0.5), vec2(0.2, 0.1))),
        op_union(
            sd_torus82_z(p - vec3( 0.75, -0.2,  0.5), vec2(0.2, 0.1)),
            sd_torus82_z(p - vec3( 0.75, -0.2, -0.5), vec2(0.2, 0.1))));

    DistanceField d1 = DistanceField(chassis, SCENE_WHITE_PLASTIC);
    DistanceField d2 = DistanceField(wheels, SCENE_GOLD);

    DistanceField d3 = DistanceField(sd_sphere(p - vec3(0.75, 0.25, 0.0), 0.25), SCENE_RED_PLASTIC);
    DistanceField d4 = DistanceField(sd_plane(p, vec4(0.0, 1.0, 0.0, 0.5)), SCENE_FLOOR);

    return df_union(df_union(df_union(d1, d2), d3), d4);
}

int raymarch(vec3 ray_pos, vec3 ray_dir, out vec3 pos, out vec3 normal)
{
    float t = 0.0;
    for (int i = 0; i < 64; ++i)
    {
        vec3 pt = ray_pos + ray_dir * t;
        DistanceField df = df_scene(pt);
        float h = df.distance;
        if (h < 0.001)
        {
            vec3 x_axis = 0.001 * vec3(1.0, 0.0, 0.0);
            vec3 y_axis = 0.001 * vec3(0.0, 1.0, 0.0);
            vec3 z_axis = 0.001 * vec3(0.0, 0.0, 1.0);
            normal.x = df_scene(pt + x_axis).distance - df_scene(pt - x_axis).distance;
            normal.y = df_scene(pt + y_axis).distance - df_scene(pt - y_axis).distance;
            normal.z = df_scene(pt + z_axis).distance - df_scene(pt - z_axis).distance;
            normal = normalize(normal);
            pos = pt;
            return df.id;
        }

        t += h;
    }

    return 0;
}

float raymarch_shadow(vec3 ray_pos, vec3 ray_dir, float t_min, float t_max, float resolution)
{
    float result = 1.0;
    float t = t_min;
    for (int i = 0; i < 64; ++i)
    {
        if (t >= t_max) break;

        vec3 pt = ray_pos + ray_dir * t;
        float h = df_scene(pt).distance;
        if (h < 0.001)
        {
            return 0.0;
        }

        result = min(result, resolution * h / t);
        t += h;
    }

    return result;
}

#define PI 3.14159265359

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    float x_angle = PI / 6.0;
    vec3 camera_pos = vec3(0.0, cos(-PI / 2.0 + x_angle), sin(-PI / 2.0 + x_angle));
    vec3 camera_dir = vec3(0.0, cos(PI / 2.0 + x_angle), sin(PI / 2.0 + x_angle));
    vec3 camera_up = vec3(0.0, cos(x_angle), sin(x_angle));

    // vec3 light_pos = vec3(1.0, 1.0, -1.0);
    // vec3 light_pos = vec3(cos(2.0 * PI * iGlobalTime), sin(2.0 * PI * iGlobalTime), -1.0);
    vec3 light_pos = 2.0 * vec3(cos(2.0 * PI * iGlobalTime / 2.0), 1.0, sin(2.0 * PI * iGlobalTime / 2.0));

    // 2x2 anti-aliasing.
    const int aa_count = 2;
    for (int aa_x = 0; aa_x < aa_count; ++aa_x)
    {
        for (int aa_y = 0; aa_y < aa_count; ++aa_y)
        {
            vec2 aa_sample_offset = vec2(aa_x, aa_y) / float(aa_count);
            vec2 uv = (fragCoord.xy + aa_sample_offset) / iResolution.xy;
            uv = 2.0 * uv - 1.0;
            uv.x *= iResolution.x / iResolution.y;

            vec3 ray_pos = camera_pos + uv.x * cross(camera_up, camera_dir) + uv.y * camera_up;
            vec3 ray_dir = camera_dir;
            vec3 pos, normal;
            float t;

            int id = raymarch(ray_pos, ray_dir, pos, normal);
            if (id > 0)
            {
                Material mtl;
                df_material(pos, id, mtl);

                vec3 l = normalize(light_pos - pos);
                vec3 v = normalize(camera_pos - pos);
                vec3 h = normalize(v + l);
                float n_l = max(0.0, dot(normal, l));
                float n_h = max(0.0, dot(normal, h));

                float shadow = raymarch_shadow(light_pos, -l, 0.0, 0.9 * distance(light_pos, pos), 32.0);

                // Lambertian BRDF diffuse + Blinn-Phong BRDF specular
                fragColor.rgb += mtl.ambient + shadow * n_l * (mtl.diffuse + (mtl.m + 2.0) / 8.0 * pow(n_h, mtl.m) * fresnel(mtl.specular, l, h));
            }
            // else
            // {
            //     fragColor.rgb += vec3(0.0, 0.0, 0.0);
            // }
        }
    }

    fragColor.rgb /= float(aa_count * aa_count);

    // Linear to gamma (sRGB) color space conversion (approximated).
    float inv_gamma = 1.0 / 2.2;
    fragColor.rgb = pow(fragColor.rgb, vec3(inv_gamma, inv_gamma, inv_gamma));
}
