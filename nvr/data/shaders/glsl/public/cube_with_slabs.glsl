// Shader downloaded from https://www.shadertoy.com/view/XlBSWd
// written by shadertoy user fischel
//
// Name: cube with slabs
// Description: This is my second shader. I wantet to build a simple cube with colors. So the easiest way was to use slabs (I think). To save the color of the slabs I build the struct. So it was not necessary to calc the color later (find the slab).
//
// This is my second shader. I wantet to build a simple cube with colors.
// So the easiest way was to use slabs (I think).
// To save the color of the slabs I build the struct. So it was
// not necessary to calc the color later (find the slab).
//
// The cam (eye) is flying around the cube. The cube is fix.
//
// some tutorials and docs
// https://www.shadertoy.com/view/Md23DV - GLSL Turorials
// https://www.shadertoy.com/view/ldfXW2 - Distance function with normals
// https://www.opengl.org/sdk/docs/man/

// struct of a slab
struct slab
{
  vec3 dir; // direction (perpendicular of the layer)
  float t; // 't' of the ray crossing the slab
  vec3 color; // color of the slab
};

slab z1 = slab(vec3(0,0, 1), 0.0, vec3(1,0,0));
slab z2 = slab(vec3(0,0,-1), 0.0, vec3(1,0,0));

slab x1 = slab(vec3( 1,0,0), 0.0, vec3(0,1,0));
slab x2 = slab(vec3(-1,0,0), 0.0, vec3(0,1,0));

slab y1 = slab(vec3(0, 1,0), 0.0, vec3(1,1,0));
slab y2 = slab(vec3(0,-1,0), 0.0, vec3(1,1,0));

// min function for slab
slab minSlab(in slab s1, in slab s2)
{
    if (s2.t < s1.t) {
        return s2;
    }
    return s1;
}

// max function for slab
slab maxSlab(in slab s1, in slab s2)
{
    if (s2.t > s1.t) {
        return s2;
    }
    return s1;
}

bool intersect(out vec4 color, in vec3 ro, in vec3 d)
{   
    // z slab
    z1.t = (z1.dir.z - ro.z) / d.z; // div by zero, not nice, but works :)
    z2.t = (z2.dir.z - ro.z) / d.z;
    slab zmin = minSlab(z1, z2);
    slab zmax = maxSlab(z1, z2);
    
    // x slab
    x1.t = (x1.dir.x - ro.x) / d.x;
    x2.t = (x2.dir.x - ro.x) / d.x;
    slab xmin = minSlab(x1, x2);
    slab xmax = maxSlab(x1, x2);
    
    // y slab
    y1.t = (y1.dir.y - ro.y) / d.y;
    y2.t = (y2.dir.y - ro.y) / d.y;
    slab ymin = minSlab(y1, y2);
    slab ymax = maxSlab(y1, y2);
   
    slab tmin = maxSlab(zmin, maxSlab(ymin, xmin));
    slab tmax = minSlab(zmax, minSlab(ymax, xmax));
    
    // hit or not hit :)
    if (tmin.t > tmax.t) {
        return false;
    }
    
    vec3 p = tmin.t * d; // ray to the hit-point
    // angle between ray and layer
    float h = dot(p, tmin.dir)/(length(p) * length(tmin.dir));
    h = 1.0 - smoothstep(0.0, 0.5, (h + 1.0) / 2.0);
    color = vec4(h * tmin.color, 1.0);
    return true;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{ 
    vec2 uv = 2.0 * (fragCoord.xy / iResolution.xy) - 1.0;
    uv.x *= iResolution.x / iResolution.y; // aspect ratio
    
    float height = iMouse.y / iResolution.y * 2.0;
    float angle = iGlobalTime;
    if (iMouse.z > 0.0) {
    	angle = iMouse.x / iResolution.x * 4.0;
    }
    
    vec3 ro = 4.0 * vec3(sin(angle), cos(angle), 0.5 + height); // eye
    vec3 d = normalize(-ro); // direction - looks to 0,0,0
    vec3 k = vec3(ro.xy, 0) - ro; // vec to down
    vec3 x = cross(d, normalize(k)); // x is the ray left/right to the eye
    vec3 y = cross(d, x); // y is the ray up/down to the eye
    d = normalize(d + x * uv.x + y * uv.y); // result to dir
    
    if (!intersect(fragColor, ro, d)) {
        // blue background
        fragColor = vec4(0.0, 0.0, fragCoord.y / iResolution.y, 1.0);
    }
}