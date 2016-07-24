// Shader downloaded from https://www.shadertoy.com/view/ll2XR1
// written by shadertoy user CaiusTSM
//
// Name: ray trace test
// Description: blah
float sphere(vec3 rayOrigin, vec3 rayDirection, vec3 sphereCenter, float sphereRadius)
{
    vec3 rc = rayOrigin - sphereCenter; // create arrow pointing from sphereCenter to ray origin
    
    float c = dot(rc, rc) - (sphereRadius * sphereRadius); // magnitude of rc minus sphere radius squared
    
    float b = dot(rayDirection, rc); // dot product between ray direction and rc which gives a unit vector along rc's axis
    
    float d = b * b - c; // b squared minus c (gives distance squared)
    
    float t = -b - sqrt(abs(d)); // sqrt to get distance d; -b minus distance d
    
    float st = step(0.0, min(t, d)); // step from 0 the min of distance d or t
    
    return mix(-1.0, t, st); // return the interpolation between t and stepped t (st)
}

vec3 background(float t, vec3 rd)
{
    vec3 light = normalize(vec3(sin(t), 0.6, cos(t)));
    
    float sun = max(0.0, dot(rd, light));
    
    float sky = max(0.0, dot(rd, vec3(0.0, 1.0, 0.0)));
    
    float ground = max(0.0, -dot(rd, vec3(0.0, 1.0, 0.0)));
    
    return (pow(sun, 256.0) + 0.2 * pow(sun, 2.0)) * vec3(2.0, 1.6, 1.0) + pow(ground, 0.5) * vec3(0.4, 0.3, 0.2) + pow(sky, 1.0) * vec3(0.5, 0.6, 0.7);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (-1.0 + 2.0*fragCoord.xy / iResolution.xy) * vec2(iResolution.x/iResolution.y, 1.0);
    
    vec3 ro = vec3(0.0, 0.0, -3.0); // ray origin
    
    vec3 rd = normalize(vec3(uv, 1.0)); // ray direction.
    
    vec3 p = vec3(0.0, 0.0, 0.0); // sphere center
    
    float t = sphere(ro, rd, p, 1.0); // ray trace sphere (get the current float represtenting current distance to sphere surface)
    
    vec3 nml = normalize(p - (ro + rd * t)); // normalize(center - ((ray origin + ray direction) * distance)) 
    
    vec3 bgCol = background(iGlobalTime, rd); // get the bg color
    
    rd = reflect(rd, nml); // relect off of the normal nml (from the sphere)
    
    vec3 col = background(iGlobalTime, rd) * vec3(0.9, 0.8, 1.0); // bg color times the color we want the bg to be (so its not just black and white and grey)
    
    fragColor = vec4( mix(bgCol, col, step(0.0, t)), 1.0 ); // interpolate the background color and the relected color
}