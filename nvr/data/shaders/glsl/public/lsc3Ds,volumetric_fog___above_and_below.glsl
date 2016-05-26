// Shader downloaded from https://www.shadertoy.com/view/lsc3Ds
// written by shadertoy user trapzz
//
// Name: volumetric fog - above and below
// Description: Shadertoy has been inspiring so I wanted to add something fun.  Here's some simple but cool looking (I think) volumetric fog - you can find references and descriptions at the top of the file.  Thanks for looking!
//No license, if you like anything here feel free to use it - credit would be nice but not necessary
//Shoutout to IQ, his work is simply incredible 

//There are a lot of things this volumetric fog doesn't do; but I think it still gives a pretty nice result
//and it runs well on my Intel Sandy Bridge integrated graphics, so that's a plus :)
//What it does:
//  Marches two 'fog volumes' (separated by a plane) and accumulates lighting according to the density of the fog
//  It stops the march once the volume is complete or if it intersects an object
//  It uses a random noise texture to vary the density of the fog which I think gives a nice "northern lights" effect.
//A more complex solution would:
//  integrate scattering and occlusion from neighbouring fog and other objects
//  Sébastien Hillaire's paper is an excellent reference:
//      http://advances.realtimerendering.com/s2015/Frostbite%20PB%20and%20unified%20volumetrics.pptx    

//References:
//
//SIGNED DISTANCE FIELD
//  http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
//GENERATING NORMALS
// TEKF https://www.shadertoy.com/view/lslXRj
//PBR
//  http://renderwonk.com/publications/s2010-shading-course/gotanda/course_note_practical_implementation_at_triace.pdf
//  http://simonstechblog.blogspot.com/2011/12/microfacet-brdf.html
//  http://www.cs.virginia.edu/~jdl/bib/appearance/analytic%20models/schlick94b.pdf
//  http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
//FOG
//  http://advances.realtimerendering.com/s2015/Frostbite%20PB%20and%20unified%20volumetrics.pptx

#define CAMERA_STATIC	0
#define CAMERA_ROTATE	1
#define CAMERA_MANUAL	2
#define CAMERA_SCRIPTED	3

#define RAYMARCH_STEPS	100
#define ROTATE_LIGHT
#define CAMERA	CAMERA_SCRIPTED

//fog
#define FOG
#define FOG_VOLUME                  20
#define FOG_DENSITY                 1.80 //1 == looking through the fog volume an 
                                         //unoccluded pixel will be fully fogged by the end of the volume
#define RAYMARCH_FOG_RESOLUTION     .2
#define RAYMARCH_FOG_STEPS          int(float(FOG_VOLUME) / RAYMARCH_FOG_RESOLUTION)
#define FOG_VOXEL_DENSITY           float(FOG_DENSITY) / float(RAYMARCH_FOG_STEPS)
#define RAYMARCH_FOG_LIGHTING_STEPS 15
#define FOG_LIGHTING_MAX_DISTANCE  20.0

const float SIGNED_DISTANCE_EPSILON = 0.0001;
const float PI = 3.1415926535897932384626433832795;

const int g_num_materials = 2;
const int g_num_spheres = 4;
const int g_num_point_lights = 2;
const int g_num_light_descs = g_num_point_lights;

struct Ray
{
    vec3 origin;
    vec3 direction;
};

struct Material
{
    vec4 color;
    float emissive;
    float roughness;
    float metallic;
};

struct Sphere
{
    vec3 center;
    float radius;
    Material material;
};  

struct RayHit
{
    Material material;
    vec3 position;
    vec3 normal;
    float n_dot_v;
    float dist;
    bool valid;
};

struct TraceResult
{
    vec4 color;
    RayHit ray_hit;
};

struct SignedDistanceResult
{
    float d;
    Material m;
};

struct PointLight
{
    vec3 position;
    vec3 color;
    
    float radius;
    float n_dot_l;
    float n_dot_h;
    float v_dot_h;
};

struct LightDesc
{
    vec3 color;
    
    float n_dot_l;
    float n_dot_h;
    float v_dot_h;   
};

Material g_materials[g_num_materials];
Sphere g_spheres[g_num_spheres];

PointLight g_point_lights[g_num_point_lights];
LightDesc g_light_desc[g_num_light_descs];

vec3 g_ambient_light;

vec3 RotateYaw( vec3 position, float yaw )
{
    vec3 center = position;
    center.x = cos(yaw) * position.x + - sin(yaw) * position.z;
    center.z = sin(yaw) * position.x +   cos(yaw) * position.z;   

    return center;
}

vec3 RotatePitch( vec3 position, float pitch )
{
    vec3 center = position;
    center.y = cos(pitch) * position.y + - sin(pitch) * position.z;
    center.z = sin(pitch) * position.y +   cos(pitch) * position.z;   

    return center;
}

vec3 TransformPosition( vec3 position, vec3 center, float yaw )
{
    return RotateYaw( position - center, yaw ) + center;
}

vec4 saturate(vec4 v)
{
    return clamp(v, 0.0, 1.0);
}

vec3 saturate(vec3 v)
{
    return clamp(v, 0.0, 1.0);
}

float saturate(float f)
{
    return clamp(f, 0.0, 1.0);
}

void Init()
{
    float time_cos_0_point_5 = cos(iGlobalTime * 0.5);
    float time_cos_1_point_0 = cos(iGlobalTime * 1.0);
    float time_sin_0_point_5 = sin(iGlobalTime * 0.5);
    
    // material for two spheres
    g_materials[0].color = vec4(1.0, 1.0, 1.0, 1.0);
    g_materials[0].emissive = 0.0;
    g_materials[0].metallic = 0.0;   
    g_materials[0].roughness = 0.5;
    
    // materials - emissive (for lights)
    g_materials[1].color = vec4(1.0, 1.0, 0.30, 1.0);
    g_materials[1].emissive = 1.0;
    g_materials[1].roughness = 1.0;
    g_materials[1].metallic = 1.00;   

    // rotating sphere
    g_spheres[0].center = vec3(time_sin_0_point_5 * 12.0, -6.0, time_cos_0_point_5 * 12.0);
    g_spheres[0].radius = 1.0;
    g_spheres[0].material = g_materials[0];
    
    // up / down sphere sphere
    g_spheres[1].center = vec3(0.0, time_cos_1_point_0 * 10.0, 0.0);
    g_spheres[1].radius = 2.0;
    g_spheres[1].material = g_materials[0];

    // lights
    g_point_lights[0].position = vec3(0.0, 0.0, -15.0);
    g_point_lights[0].color = vec3(174.0 / 255.0 * 2.0, 174.0 / 255.0 * 2.0, 255.0 / 255.0 * 2.0);
    g_point_lights[0].radius = .2;

    g_point_lights[1].position = vec3(0.0, 0.0, 15.0);
    g_point_lights[1].color = vec3(175.0 / 255.0 * 2.0, 151.0 / 255.0 * 2.0, 175.0 / 255.0 * 2.0);
    g_point_lights[1].radius = .2;
    
#ifdef ROTATE_LIGHT
    g_point_lights[0].position = RotateYaw(g_point_lights[0].position, -time_cos_1_point_0);
    g_point_lights[0].position = RotatePitch(g_point_lights[0].position, time_cos_0_point_5);
    g_point_lights[1].position = RotateYaw(g_point_lights[1].position, -time_cos_0_point_5);
    g_point_lights[1].position = RotatePitch(g_point_lights[1].position, -time_cos_1_point_0);
#endif
    
    g_spheres[2].center = g_point_lights[0].position;
    g_spheres[2].radius = g_point_lights[0].radius;
    g_spheres[2].material = g_materials[1];
    g_spheres[2].material.color.rgb = g_point_lights[0].color;
    
    g_spheres[3].center = g_point_lights[1].position;
    g_spheres[3].radius = g_point_lights[1].radius;
    g_spheres[3].material = g_materials[1];
    g_spheres[3].material.color.rgb = g_point_lights[1].color;

    g_ambient_light = vec3(.075, .09, .075);
}

float sdBox( vec3 p, vec3 b )
{
    vec3 d = abs(p) - b;
    
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdSphere( vec3 p, float s )
{
    return length( p ) - s;
}

SignedDistanceResult sdUnion( SignedDistanceResult r1, SignedDistanceResult r2 )
{
    if (r1.d < r2.d)
        return r1;
    else    
        return r2;
}

SignedDistanceResult SignedDistance( vec3 position )
{
    SignedDistanceResult result;
    
    float d = sdSphere( position - g_spheres[0].center, g_spheres[0].radius );
    result = SignedDistanceResult( d, g_spheres[0].material );

    for ( int i = 1; i < g_num_spheres; i++ )
    {
        d = sdSphere( position - g_spheres[i].center, g_spheres[i].radius );    
        result = sdUnion( result, SignedDistanceResult(d, g_spheres[i].material) );
    }
            
    return result;
}

vec3 CalculateNormal( vec3 ray_direction, vec3 position )
{   
    // from TEKF: https://www.shadertoy.com/view/lslXRj
    // I really liked the results
    float pitch = 0.2 / iResolution.x;
    
    vec2 d = vec2(-1, 1) * pitch;

    vec3 p0 = position + d.xxx; // tetrahedral offsets
    vec3 p1 = position + d.xyy;
    vec3 p2 = position + d.yxy;
    vec3 p3 = position + d.yyx;

    float f0 = SignedDistance(p0).d;
    float f1 = SignedDistance(p1).d;
    float f2 = SignedDistance(p2).d;
    float f3 = SignedDistance(p3).d;
            
    vec3 grad = p0 * f0 + p1 * f1 + p2 * f2 + p3 * f3 - position * (f0 + f1 + f2 + f3);
    
    // prevent normals pointing away from camera (caused by precision errors)
    float gdr = dot (grad, ray_direction);
    grad -= max(0.0, gdr) * ray_direction;

    return normalize(grad);
}

Ray CreateRay(vec3 cam_pos, vec3 cam_euler, vec2 frag_coord)
{
    const float fov_degrees = 45.0;
    
    vec3 eye;
    eye.x = 0.0; eye.y = 0.0; eye.z = - 1.0 / tan(fov_degrees / 2.0 * 0.0174532925);
    
    vec3 pixel;
    pixel.xy = (frag_coord.xy - .5) / iResolution.xy * 2.0 - 1.0;
    pixel.x *= iResolution.x / iResolution.y;
    pixel.z = 0.0;

    vec3 dir = normalize(pixel - eye);

    Ray ray;
    
    ray.direction = dir;
    ray.direction.x = cos(cam_euler.y) * dir.x + - sin(cam_euler.y) * dir.z;
    ray.direction.z = sin(cam_euler.y) * dir.x +   cos(cam_euler.y) * dir.z;
    
    dir = ray.direction;

    ray.direction.y = cos(cam_euler.x) * dir.y + - sin(cam_euler.x) * dir.z;
    ray.direction.z = sin(cam_euler.x) * dir.y +   cos(cam_euler.x) * dir.z;
    
    vec3 origin = cam_pos;

    ray.origin = origin;
    ray.origin.x = cos(cam_euler.y) * cam_pos.x + - sin(cam_euler.y) * cam_pos.z;
    ray.origin.z = sin(cam_euler.y) * cam_pos.x +   cos(cam_euler.y) * cam_pos.z;   

    origin = ray.origin;

    ray.origin.y = cos(cam_euler.x) * origin.y + - sin(cam_euler.x) * origin.z;
    ray.origin.z = sin(cam_euler.x) * origin.y +   cos(cam_euler.x) * origin.z;
    
    ray.origin += ray.direction * - eye.z;
    
    return ray;
}

RayHit CheckHit( vec3 ray_direction, vec3 position )
{
    RayHit ray_hit;
    
    SignedDistanceResult result = SignedDistance( position );
    ray_hit.dist = result.d;
    
    if ( ray_hit.dist < SIGNED_DISTANCE_EPSILON )
    {
        ray_hit.valid = true;
        ray_hit.material = result.m;
        ray_hit.position = position;
        ray_hit.normal = CalculateNormal( ray_direction, position );
    }
    else
    {
        ray_hit.valid = false;
    }

    return ray_hit;
}

RayHit RayMarch( Ray ray )
{
    float dist = 0.0;
    vec3 pos = ray.origin;

    RayHit ray_hit;
    
    for (int i = 0; i < RAYMARCH_STEPS; i++)
    {
        ray_hit = CheckHit( ray.direction, pos );

        if (true == ray_hit.valid)
            break;
        
        dist += ray_hit.dist;
        pos = ray.origin + ray.direction * dist;
    }
        
    return ray_hit;
}

float CalculateSpecDistribution_GGX( float n_dot_h, float roughness )
{
    float a = roughness * roughness;
    float a2 = a * a;
    float d = (n_dot_h * n_dot_h) * (a2 - 1.0) + 1.0;

    d = PI * (d * d);
    
    return a2 / d;
}

float CalculateSpecGeometricAttenuation_Schlick_G1( float d, float k )
{
    float g = d / (d * (1.0 - k) + k);

    return (g);
}

float CalculateSpecGeometricAttenuation_Schlick_G( float n_dot_l, float n_dot_v, float roughness )
{
    float a = (roughness + 1.0) / 2.0;
    float a2 = a * a;
    float k = a2 / 2.0;
    
    k = a2 * sqrt(2.0 / PI);
    
    float g = CalculateSpecGeometricAttenuation_Schlick_G1(n_dot_l, k) * 
              CalculateSpecGeometricAttenuation_Schlick_G1(n_dot_v, k);
              
    return max(0.0, g);//saturate(g);
}

float CalculateFresnel_Schlick(float f0, float c)
{
    return (f0 + (1.0 - f0) * pow(1.0 - c, 5.0));
}

vec3 CalculateLighting( RayHit ray_hit, Material material )
{
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    for (int c = 0; c < g_num_light_descs; c++)
    {
        float d = CalculateSpecDistribution_GGX( g_light_desc[c].n_dot_h, material.roughness );
        float g = CalculateSpecGeometricAttenuation_Schlick_G( g_light_desc[c].n_dot_l, ray_hit.n_dot_v, material.roughness );
        float fd = CalculateFresnel_Schlick( material.metallic, saturate(g_light_desc[c].n_dot_l) );
        float fs = CalculateFresnel_Schlick( material.metallic, saturate(g_light_desc[c].v_dot_h) );
    
        float n_dot_l_sat = saturate(g_light_desc[c].n_dot_l);

        vec3 diffuse = g_light_desc[c].color * n_dot_l_sat / PI * (1.0 - fd);
    
        vec3 brdf = g_light_desc[c].color * (g * d * fs) * n_dot_l_sat / (4.0 * (g_light_desc[c].n_dot_l * ray_hit.n_dot_v));
        
        color += diffuse + brdf;
    }   
    
    return color;
}

TraceResult ProcessRayHit( RayHit ray_hit, Ray ray )
{
    TraceResult result;
    result.ray_hit = ray_hit;
    
    if (false == result.ray_hit.valid)
        return result;
    
    result.ray_hit.n_dot_v = dot(result.ray_hit.normal, -ray.direction);

    for (int c = 0; c < g_num_point_lights; c++)
    {
        vec3 direction = normalize(result.ray_hit.position - g_point_lights[c].position);

        vec3 h = normalize(direction + ray.direction);
    
        g_light_desc[c].n_dot_l = dot(result.ray_hit.normal, -direction);
        g_light_desc[c].n_dot_h = dot(result.ray_hit.normal, h);
        g_light_desc[c].v_dot_h = dot(ray.direction, -h);
        g_light_desc[c].color = g_point_lights[c].color;
    }
    
    vec3 color = CalculateLighting( result.ray_hit, result.ray_hit.material );
    
    result.color.rgb =  color + 
                        result.ray_hit.material.color.rgb * result.ray_hit.material.emissive +  
                        result.ray_hit.material.color.rgb * g_ambient_light;

    result.color.w = result.ray_hit.material.color.w;
    
    return result;
}

vec2 DistanceFromLight(vec3 position, vec3 light_position, float light_radius)
{
    vec3 delta = light_position - position;
    vec3 to_light = normalize(delta);
    
    float distance = dot(to_light, delta) - light_radius;
    
    if (distance > FOG_LIGHTING_MAX_DISTANCE)
        return vec2(FOG_LIGHTING_MAX_DISTANCE, 0.0);
    
    return vec2(distance, 1.0);
}    

vec3 PointOnPlane( vec3 direction, vec3 position, vec4 plane )
{
    float c = dot(-direction, plane.xyz);
    float adj = dot(plane.xyz, position) + plane.w;
    float hyp = adj / c;

    return position + direction * hyp;
}

vec4 TraceFog( Ray ray, float depth )
{
    //A plane at 0,1,0,0 separates two levels of fog
    //the overlap each other between 1 and -1 for blending
    //below the plane being very dense
    //above the plane being just dense enough to scatter some light
    
    vec4 fog_color = vec4( 0, 0, 0, 0 );
    
    vec3 ray_march_start = ray.origin;
    float length = 0.0;

    float plane_w = 1.0;

    //if we're starting below the plane or we will end up below the plane
    if (ray_march_start.y < plane_w || ray.direction.y < 0.0)
    {
        //if we are above the plane move our ray march start down the ray to the plane
        //this way we get as many ray march samples as possible in the plane
        if (ray_march_start.y > plane_w && ray.direction.y < 0.0)
            ray_march_start = PointOnPlane(ray.direction, ray_march_start, vec4(0, 1, 0, -plane_w));
        
        vec3 position = ray_march_start;
        
        //ray march the bottom plane
        for (int i = 0; i < RAYMARCH_FOG_STEPS; i++)
        {
            //if we've gone deep enough that we hit whatever object is at this pixel
            //we have to stop fogging
            if (dot(position - ray.origin, ray.direction) >= depth)
                break;
            
            float density;
            
            //if we're below the plane, calculate the fog
            if (position.y <= plane_w)
            {
                float scale = .001;
                float coeff = iGlobalTime * .005;

                //use t for a slight fade in to our fog
                float t = saturate((plane_w - position.y) / 2.0);
                
                //random noise sampling so the fog isn't so bland
                float d1 = texture2D(iChannel0, position.xz * scale + coeff).g;
                float d2 = texture2D(iChannel0, position.xz * scale + cos(iGlobalTime) * .002).g;
                density = max(FOG_VOXEL_DENSITY * max(d1,d2), FOG_VOXEL_DENSITY * .25) * t;
            }
            else
                density = 0.0;
            
            if (density > 0.0)
            {                
                vec3 light_contribution = vec3(0, 0, 0);
                vec4 voxel_color;
                
                //get the distance to each light and accumulate that in our fog
                for (int k = 0; k < g_num_point_lights; k++)
                {
                    vec2 distance_and_occlusion = DistanceFromLight(position, g_point_lights[k].position, g_point_lights[k].radius);
                    float distance = distance_and_occlusion.x;
                    float occlusion = distance_and_occlusion.y;
                    
                    float dist = distance / FOG_LIGHTING_MAX_DISTANCE;
                    dist = saturate(dist);

                    float d = 1.0 - dist;
                    light_contribution += g_point_lights[k].color * d * d * occlusion;
                }

                voxel_color.rgb = (light_contribution + g_ambient_light) * density;
                voxel_color.w = density;
                
                // accumulate all the voxels into our end fog result
                fog_color += voxel_color;
            }
            
            length += float(RAYMARCH_FOG_RESOLUTION);
            position = ray_march_start + ray.direction * length;
        }
    }
    
    ray_march_start = ray.origin;
    length = 0.0;

    //now we trace into the top plane
    plane_w = -1.0;
    
    //if we're starting above the plane or will end up above it
    if (ray_march_start.y > plane_w || ray.direction.y > 0.0)
    {
        //if we are above the plane move our ray march start up the ray to the plane
        //this way we get as many ray march samples as possible in the plane
        if (ray_march_start.y < plane_w && ray.direction.y > 0.0)
            ray_march_start = PointOnPlane(ray.direction, ray_march_start, vec4(0, -1, 0, plane_w));
        
        vec3 position = ray_march_start;

        for (int i = 0; i < RAYMARCH_FOG_STEPS; i++)
        {
            //if we've gone deep enough that we hit whatever object is at this pixel
            //we have to stop fogging
            if (dot(position - ray.origin, ray.direction) >= depth)
                break;
            
            float density;
            
            if (position.y > plane_w)
            {
                //use t for a slight fade in to our fog
                float t = saturate((position.y - plane_w) / 2.0);
                density = FOG_VOXEL_DENSITY * .25 * t;
            }
            else
                density = 0.0;
            
            if (density > 0.0)
            {                
                vec3 light_contribution = vec3(0, 0, 0);
                vec4 voxel_color;
                
                //get the distance to each light and accumulate that in our fog
                for (int k = 0; k < g_num_point_lights; k++)
                {
                    vec2 distance_and_occlusion = DistanceFromLight(position, g_point_lights[k].position, g_point_lights[k].radius);
                    float distance = distance_and_occlusion.x;
                    float occlusion = distance_and_occlusion.y;
                    
                    float dist = distance / FOG_LIGHTING_MAX_DISTANCE;
                    dist = saturate(dist);

                    float d = 1.0 - dist;
                    light_contribution += g_point_lights[k].color * d * d * occlusion;
                }

                voxel_color.rgb = (light_contribution + g_ambient_light) * density;
                voxel_color.w = density;
                
                // accumulate all the voxels into our end fog result
                fog_color += voxel_color;
            }
            
            length += float(RAYMARCH_FOG_RESOLUTION);
            position = ray_march_start + ray.direction * length;
        }
    }
    
    fog_color.w = saturate(fog_color.w);
    return fog_color;
}

vec4 TraceScene( Ray ray )
{
    TraceResult result = ProcessRayHit( RayMarch(ray), ray );

    if (false == result.ray_hit.valid)
        return vec4(0, 0, 0, 10000.0);

    vec4 color;
    
    color.rgb = result.color.rgb;
    color.w = dot(result.ray_hit.position - ray.origin, ray.direction);

    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    Init();
    
    vec3 cam_rot = vec3(.25, 0, 0);
    vec3 cam_pos = vec3(0, 0, -35.0);
    
    #if CAMERA == CAMERA_ROTATE
        cam_rot = vec3(0, iGlobalTime * .025, 0);
    #elif CAMERA == CAMERA_MANUAL
        cam_rot = vec3(iMouse.y * .02, iMouse.x * .02, 0);
    #elif CAMERA == CAMERA_SCRIPTED
        vec3 rot_up = vec3(0.25, 0.0, 0.0);
        vec3 rot_down = vec3(-0.25, 0.0, 0.0);
        vec3 pos_up = vec3(0.0, 5.0, -35.0);
        vec3 pos_down = vec3(0.0,-10.0, -35.0);
        
        float t = abs(cos(iGlobalTime * .15));
        cam_pos = mix(pos_up, pos_down, 1.0 - t);
        cam_rot = mix(rot_up, rot_down, 1.0 - t);
    #endif
    
    
    Ray ray = CreateRay(cam_pos, cam_rot, fragCoord);

    vec4 pixel_color_and_depth = TraceScene( ray );
    
    #ifdef FOG
        vec4 fog_color = TraceFog( ray, pixel_color_and_depth.w );
    #else
        vec4 fog_color = vec4(0.0, 0.0, 0.0, 0.0);
    #endif
    
    fragColor.rgb = saturate(pixel_color_and_depth.rgb * (1.0 - fog_color.w) + fog_color.rgb);
    fragColor.a = 1.0;
    
    fragColor = sqrt(fragColor);
}

