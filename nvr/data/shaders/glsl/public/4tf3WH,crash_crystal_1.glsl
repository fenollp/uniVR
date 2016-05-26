// Shader downloaded from https://www.shadertoy.com/view/4tf3WH
// written by shadertoy user janneasdf
//
// Name: Crash Crystal 1
// Description: Crystal from Crash Bandicoot games
// Shader parameters
float crystalScale = 0.1;

// Material types
const int OBJECT_NONE = 0;
const int OBJECT_CRYSTAL = 1;
const int OBJECT_ICE = 2;

// Helper variables and functions
const float INF = 1e10;
bool debug = false;
const float PI = 3.14159265359;

float perlin(vec2 coords, int octaves, float gain, float freq, float amplitude)
{
    float p = 0.0;
    const int max_octaves = 20;
    for (int i = 0; i < max_octaves; ++i)
    {
        if (i >= octaves)
            break;
        p += texture2D(iChannel0, vec2(coords.x * freq, coords.y * freq)).r * amplitude;
        amplitude *= gain;
        freq *= 1.0 / gain;
    }
    return p;   
}

// Shader initialization
vec3 crystal[24 * 3];
vec3 cv[14];
void initCrystalGeometry()
{
    cv[0] = vec3(0.401617, 0.465089, -0.401617);
	cv[1] = vec3(-0.401617, 0.465089, 0.401617);
	cv[2] = vec3(1.000000, 5.081155, -0.999999);
	cv[3] = vec3(0.999999, 5.081155, 1.000001);
	cv[4] = vec3(-1.000000, 5.081155, 1.000000);
	cv[5] = vec3(-1.000000, 5.081155, -1.000000);
	cv[6] = vec3(0.401617, 0.465089, 0.401617);
	cv[7] = vec3(-0.401617, 0.465089, -0.401618);
	cv[8] = vec3(0.000000, -0.11153, -0.000000);
	cv[9] = vec3(0.000000, 6.290121, -1.166347);
	cv[10] = vec3(1.163836, 6.290121, 0.000001);
	cv[11] = vec3(-0.000000, 6.290121, 1.166347);
	cv[12] = vec3(-1.163836, 6.290121, 0.000000);
	cv[13] = vec3(-0.000000, 8.061562, 0.000000);
    
    crystal[0] = cv[10]; crystal[1] = cv[11]; crystal[2] = cv[3]; 
    crystal[3] = cv[10]; crystal[4] = cv[2]; crystal[5] = cv[9]; 
    crystal[6] = cv[9]; crystal[7] = cv[5]; crystal[8] = cv[12]; 
    crystal[9] = cv[11]; crystal[10] = cv[12]; crystal[11] = cv[4]; 
    crystal[12] = cv[5]; crystal[13] = cv[7]; crystal[14] = cv[12]; 
    crystal[15] = cv[11]; crystal[16] = cv[6]; crystal[17] = cv[3]; 
    crystal[18] = cv[10]; crystal[19] = cv[3]; crystal[20] = cv[6]; 
    crystal[21] = cv[2]; crystal[22] = cv[10]; crystal[23] = cv[0]; 
    crystal[24] = cv[2]; crystal[25] = cv[0]; crystal[26] = cv[9]; 
    crystal[27] = cv[9]; crystal[28] = cv[7]; crystal[29] = cv[5]; 
    crystal[30] = cv[1]; crystal[31] = cv[7]; crystal[32] = cv[8]; 
    crystal[33] = cv[6]; crystal[34] = cv[1]; crystal[35] = cv[8]; 
    crystal[36] = cv[7]; crystal[37] = cv[0]; crystal[38] = cv[8]; 
    crystal[39] = cv[0]; crystal[40] = cv[6]; crystal[41] = cv[8]; 
    crystal[42] = cv[12]; crystal[43] = cv[11]; crystal[44] = cv[13]; 
    crystal[45] = cv[11]; crystal[46] = cv[10]; crystal[47] = cv[13]; 
    crystal[48] = cv[9]; crystal[49] = cv[12]; crystal[50] = cv[13]; 
    crystal[51] = cv[10]; crystal[52] = cv[9]; crystal[53] = cv[13]; 
    crystal[54] = cv[7]; crystal[55] = cv[1]; crystal[56] = cv[12]; 
    crystal[57] = cv[12]; crystal[58] = cv[1]; crystal[59] = cv[4]; 
    crystal[60] = cv[11]; crystal[61] = cv[4]; crystal[62] = cv[1]; 
    crystal[63] = cv[1]; crystal[64] = cv[6]; crystal[65] = cv[11]; 
    crystal[66] = cv[0]; crystal[67] = cv[10]; crystal[68] = cv[6]; 
    crystal[69] = cv[0]; crystal[70] = cv[7]; crystal[71] = cv[9];
    
    for (int i = 0; i < 24; ++i)
    {
        crystal[i*3] = crystalScale * crystal[i*3];
        crystal[i*3+1] = crystalScale * crystal[i*3+1];
        crystal[i*3+2] = crystalScale * crystal[i*3+2];
    }
}

struct RayHit
{
	float t;
    vec3 rayDir;
    vec3 n;
    vec2 uv;
    float mirror;	// mirroring factor
    int material;
};
    
struct TriangleHit
{
	float t;
    vec2 uv;
    vec3 n;
};

// (Slightly modified) GLSL ray-triangle intersection code 
// from http://undernones.blogspot.fi/2010/12/gpu-ray-tracing-with-glsl.html
TriangleHit intersectTriangle(vec3 rayPos, vec3 rayDir, vec3 v0, vec3 v1, vec3 v2)
{
    TriangleHit hit;
    vec3 u, v, n; // triangle vectors
    vec3 w0, w;  // ray vectors
    float r, a, b; // params to calc ray-plane intersect

    // get triangle edge vectors and plane normal
    u = v1 - v0;
    v = v2 - v0;
    n = cross(u, v);

    w0 = rayPos - v0;
    a = -dot(n, w0);
    b = dot(n, rayDir);
    if (abs(b) < 1e-5)
    {
        // ray is parallel to triangle plane, and thus can never intersect.
        hit.t = INF;
        return hit;
    }

    // get intersect point of ray with triangle plane
    r = a / b;
    if (r < 0.0)
    {
        hit.t = INF;
        return hit; // ray goes away from triangle.
    }

    vec3 I = rayPos + r * rayDir;
    float uu, uv, vv, wu, wv, D;
    uu = dot(u, u);
    uv = dot(u, v);
    vv = dot(v, v);
    w = I - v0;
    wu = dot(w, u);
    wv = dot(w, v);
    D = uv * uv - uu * vv;

    // get and test parametric coords
    float s, t;
    s = (uv * wv - vv * wu) / D;
    if (s < 0.0 || s > 1.0)
    {
        hit.t = INF;
        return hit;
    }
    t = (uv * wu - uu * wv) / D;
    if (t < 0.0 || (s + t) > 1.0)
    {
        hit.t = INF;
        return hit;
    }

    hit.uv = vec2(s, t);
    hit.n = n;
    hit.t = (r > 1e-5) ? r : INF;
    return hit;
}

TriangleHit intersectPlane(vec3 rayPos, vec3 rayDir, vec3 planeNormal, vec3 planePoint)
{
    TriangleHit hit;
    float nl = dot(planeNormal, rayDir);
    if (abs(nl) < 0.001)
        hit.t = INF;
    else
        hit.t = dot(planePoint - rayPos, planeNormal) / nl;
    return hit;
}

// Shader specific functions
RayHit traceRay(vec3 rayPos, vec3 rayDir)
{
    RayHit hit;
    hit.rayDir = rayDir;
    hit.mirror = 0.0;
    TriangleHit triHit;
    hit.material = OBJECT_NONE;
    float tMin = INF;
    float t;
    
    // Trace the ice
    vec3 planeNormal = normalize(vec3(0.0, 1.0, 0.0));
    vec3 planePoint = vec3(0.0, 0.0, 0.0);	// any point on the plane
    triHit = intersectPlane(rayPos, rayDir, planeNormal, planePoint);
    vec3 p = rayPos + triHit.t * rayDir;
    if (triHit.t >= 0.0 && triHit.t < tMin && abs(p.x) < 0.8 && abs(p.z) < 0.8)
    {
    	tMin = triHit.t;
        hit.uv = (rayPos + triHit.t * rayDir).xz; // todo: account for plane_n != 0,1,0
        hit.n = planeNormal;
        hit.material = OBJECT_ICE;
        hit.mirror = 0.5;
    }
    
    // Trace crystal triangles
    for (int i = 0; i < 24; ++i)
    {
        triHit = intersectTriangle(rayPos, rayDir, crystal[i*3], crystal[i*3+1], crystal[i*3+2]);
        if (triHit.t < tMin)
        {
        	tMin = triHit.t;
            hit.uv = triHit.uv;
            hit.n = triHit.n;
            hit.mirror = 0.0;
            hit.material = OBJECT_CRYSTAL;
        }
    }
    hit.n = normalize(hit.n);
    hit.t = tMin;
    return hit;
}

float uvDistanceFromEdge(vec2 uv)
{
	return min(uv.x, min(uv.y, 1.0 - uv.x - uv.y));
}

vec3 shadeCrystal(RayHit hit)
{
    vec3 c = vec3(0.5, 0.1, 0.3) * 1.25;
    float nl = max(dot(hit.n, -hit.rayDir), 0.0);
    c = nl * c;
    
    return c;
}

vec3 shadeIce(RayHit hit)
{
    vec3 c;
	vec3 blue = vec3(0.2, 0.4, 0.86) * 1.85;
    
    // Create the procedural texture
    c = blue;
    float angle = PI / 6.0;
    vec2 coords = hit.uv;
    coords.x = cos(angle) * coords.x - sin(angle) * coords.y;
    coords.y = sin(angle) * coords.x + cos(angle) * coords.y;
    coords = vec2(5.0 * coords.x, 1.4 * coords.y);
    float p = perlin(coords, 6, 0.5, 1.0 / 256.0, 0.5);
    p += perlin(coords, 10, 0.5, 1.0 / 256.0, 0.5);
    p *= 0.5;
    c *= p;
    c *= 2.5;
    c += 0.2;
    float nl = max(dot(hit.n, -hit.rayDir), 0.0);
    c = nl * c;
    
    return c;
}

vec3 shadeMaterial(RayHit hit)
{
    vec3 shade;
    if (hit.material == OBJECT_NONE)
    {
    	shade = vec3(0.0, 0.0, 0.0);
    }
    else if (hit.material == OBJECT_CRYSTAL)
    {
    	shade = shadeCrystal(hit); 	   
    }
    else if (hit.material == OBJECT_ICE)
    {
        shade = shadeIce(hit);
    }
    return shade;
}

float distPointRay(vec3 p, vec3 rayPos, vec3 rayDir)
{
    return length(cross(rayDir, p - rayPos));
}

vec3 getColor(vec3 rayPos, vec3 rayDir)
{
    vec3 color = vec3(0.0, 0.0, 0.0);
    vec3 origRayPos = rayPos;
    vec3 origRayDir = rayDir;
    RayHit hit = traceRay(rayPos, rayDir);
    float mirror = hit.mirror;
    vec3 shade = shadeMaterial(hit);
    color += shade;
    if (hit.material == OBJECT_ICE)
    {
        rayPos = rayPos + hit.t * rayDir;
        rayPos += 0.001 * hit.n;
        rayDir = reflect(rayDir, hit.n);
        hit = traceRay(rayPos, rayDir);
        shade = shadeMaterial(hit);
        color *= 1.0;
        color += 0.8 * shade;
    }
    // Glow
    float glow = 0.0;
    float d;
    float a = 100.0;
    float b = 10.0;
    float c = 10.0;
    float g;
    for (int i = 0; i < 14; ++i)
    {
        d = distPointRay(crystalScale * cv[i], origRayPos, origRayDir);
        g = 1.0 / (a*d*d + b*d + c);
        glow += g;
    }
    color += glow * vec3(0.5, 0.1, 0.3);
    
    return color;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float aspect = iResolution.x / iResolution.y;
    uv -= .5;
    uv.x *= aspect;
    
    float time = iGlobalTime;
    float camDistance = 1.2;
    if (iMouse.z > 0.0 || iMouse.w > 0.0) camDistance = 1.5;
    float camSpeed = 0.4;
    vec3 camDir = normalize(vec3(sin(time * camSpeed), -0.3, cos(time * camSpeed)));
    vec3 camTarget = vec3(0.0, 0.4, 0.0);
    vec3 camPos = camTarget - camDir * camDistance;
    vec3 camUp = vec3(0.0, 1.0, 0.0);
    vec3 camRight = normalize(cross(camUp, camDir));
    camUp = normalize(cross(camDir, camRight));
    
    vec3 rayPos = camPos;
    vec3 rayDir = normalize(camDir + uv.x * camRight + uv.y * camUp);
    
    initCrystalGeometry();
    
    vec3 c;
    c = getColor(rayPos, rayDir);
    
    if (debug)	// Debug activated during getColor
    {
        if (fract(iGlobalTime * 4.0) < 0.5)
        	c = vec3(0.0);
        else
        	c = vec3(1.0);
    }
    
    fragColor = vec4(c, 1.0);
}